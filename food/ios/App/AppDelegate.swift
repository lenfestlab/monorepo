import UIKit
import Firebase
import FirebaseMessaging
import SafariServices
import AlamofireNetworkActivityLogger
import RxSwift
import SwiftDate
import CoreLocation

typealias Result<T> = Swift.Result<T, Error>
typealias LaunchOptions = [UIApplication.LaunchOptionsKey: Any]?
let gcmMessageIDKey = "gcm.message_id"

struct Scheduler {
  static let main = MainScheduler.instance
  static let background = ConcurrentDispatchQueueScheduler(qos: .background)
}

struct Context {
  let api: Api
  let analytics: AnalyticsManager
  let cache: Cache
  let env: Env
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var context: Context!

  var lastViewedURL: URL?
  var window: UIWindow?
  var analytics: AnalyticsManager!
  var env: Env!
  var api: Api!
  var locationManager: LocationManager!
  var notificationManager: NotificationManager!
  var mainController: MainController!
  var tabController: TabBarViewController!
  let bag = DisposeBag()

  class func shared() -> AppDelegate {
    return UIApplication.shared.delegate as! AppDelegate
  }

  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: LaunchOptions) -> Bool {
    self.env = Env()
    if !env.isRemote {
      NetworkActivityLogger.shared.level = .debug
      NetworkActivityLogger.shared.startLogging()
    }

    FirebaseApp.configure()
    Messaging.messaging().delegate = self
    application.registerForRemoteNotifications()
    InstanceID.instanceID().instanceID { (result, error) in
      if let error = error {
        print("gcm: Error fetching remote instange ID: \(error)")
      } else if let result = result {
        print("gcm: Remote instance ID token: \(result.token)")
      }
    }

    let cache = Cache()
    self.api = Api(env: env, cache: cache)
    self.analytics = AnalyticsManager(env)
    self.context = Context(api: api, analytics: analytics, cache: cache, env: env)

    self.locationManager = LocationManager.sharedWith(analytics: analytics)

    self.notificationManager =
      NotificationManager(api: api,
                          analytics: analytics,
                          cache: cache,
                          locationManager: locationManager)
    window = UIWindow(frame: UIScreen.main.bounds)
    let onboardingCompleted = UserDefaults.standard.bool(forKey: "onboarding-completed")

    let introController = IntroViewController(analytics: self.analytics)
    self.mainController = MainController(rootViewController: introController)
    self.notificationManager.delegate = self

    if !onboardingCompleted {
      window!.rootViewController = self.mainController
      window!.makeKeyAndVisible()
      return true
    }

    if Installation.authToken() != nil {
      self.showHomeScreen()
      window!.makeKeyAndVisible()
    } else {
      let cloudViewController = CloudViewController()
      window!.rootViewController = cloudViewController
      window!.makeKeyAndVisible()
      iCloudUserIDAsync() { cloudId, error in
        if let cloudId = cloudId {
          print("received iCloudID \(cloudId)")

          Installation.register(cloudId: cloudId, completion: { (success, accessToken) in
            DispatchQueue.main.async { [unowned self] in
              self.showHomeScreen()
            }
          })

        } else {
          print("Fetched iCloudID was nil")
          DispatchQueue.main.async { [unowned self] in
            self.showHomeScreen()
          }
        }
      }
    }

    guard let window = self.window else { return true }
    let notificationResponse$ =
      notificationManager.notificationResponse$
    let anyTouch$ =
      window.rx.methodInvoked(#selector(UIView.hitTest(_:with:)))
    anyTouch$.withLatestFrom(notificationResponse$)
      .take(1)
      .subscribe(onNext: { [unowned self] response in
        self.analytics.log(.appLaunched((response != nil)
          ? .notification
          : .direct))
      }).disposed(by: bag)


    return true
  }

  func showPermissions() {
    mainController.pushViewController(
      PermissionsViewController(analytics: self.analytics),
      animated: false)
  }

  func showNotifications() {
    mainController.pushViewController(
      NotificationViewController(
        analytics: analytics,
        notificationManager: notificationManager),
      animated: false)
  }

  func showHomeScreen() {
    self.tabController =
      TabBarViewController(
        context: context,
        notificationManager: notificationManager)
    window!.rootViewController = self.tabController
  }

  func showEmailRegistration(cloudId: String) {
    mainController.pushViewController(
      EmailViewController(analytics: self.analytics, cloudId: cloudId),
      animated: false)
  }


  enum RemoteNotificationType: String {
    case location
    case visitCheck = "visit_check"
  }

  enum VisitError: Error {
    case PlaceLocationMIA
    case TooFarAway
    case SelfMIA
  }

  func application(
    _ application: UIApplication,
    didReceiveRemoteNotification
    userInfo: [AnyHashable : Any],
    fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult
    ) -> Void) {
    print("didReceiveRemoteNotification userInfo: \(userInfo)")
    guard
      let typeString  = userInfo["type"] as? String,
      let type = RemoteNotificationType(rawValue: typeString)
      else {
        print("MIA: 'type' or its value")
        return completionHandler(.noData) }
    switch type {
    case .location:
      let locationManager = LocationManager.shared
      // NOTE: wait long enough for location update ...
      let queue = DispatchQueue.main
      queue.asyncAfter(deadline: 3.seconds.fromNow, execute: {
        guard let location = locationManager.latestLocation
          else { return completionHandler(.noData) }
        locationManager.logLocationChange(location)
        // NOTE: wait long enough for GA request too complete
        queue.asyncAfter(deadline: 3.seconds.fromNow, execute: {
          completionHandler(.newData)
        })
      })
    case .visitCheck:
      guard let placeId = userInfo["place_id"] as? String
        else { print("MIA: `place_id`"); return completionHandler(.failed) }
      let place$ = self.api.getPlace$(placeId)
      let latestLocation$ = self.locationManager.location$
      Observable.combineLatest(place$, latestLocation$)
        .flatMapFirst({ [weak self] (result, currentLocation) -> Observable<Result<Bookmark>> in
          guard let `self` = self else { throw VisitError.SelfMIA }
          switch result {
          case let .failure(error): throw error
          case let .success(place):
            guard let placeLocation = place.location?.nativeLocation
              else { throw VisitError.PlaceLocationMIA }
            let distance = currentLocation.distance(from: placeLocation)
            print(distance)
            guard distance.isLess(than: place.visitRadiusMax) else {
              throw VisitError.TooFarAway }
            self.analytics.log(.visited(place: place, location: currentLocation.coordinate))
            return self.api.recordVisit$(placeId)
          }
        })
        .subscribe({ [weak self] event in
          guard let `self` = self else { return completionHandler(.failed) }
          switch event {
          case let .next(result):
            // if API recorded visit, display local notification (stag only)
            switch result {
            case let .success(bookmark):
              if self.env.isPreProduction,
                let placeName = bookmark.place?.name,
                let center = self.notificationManager.notificationCenter {
                let content = UNMutableNotificationContent()
                content.categoryIdentifier = "visiting"
                content.sound = UNNotificationSound.default
                content.title = "Visit: \(placeName)"
                let request =
                  UNNotificationRequest(
                    identifier: UUID().uuidString,
                    content: content,
                    trigger: nil)
                center.add(request, withCompletionHandler: { (error) in
                  if let error = error { print(error) }
                })
              }
            case let .failure(error):
              print(error)
            }
          case let .error(error):
            print(error)
            completionHandler(.failed)
          case .completed:
            completionHandler(.newData)
          }
        })
        .disposed(by: bag)

    }
  }

}

extension AppDelegate: MessagingDelegate {

  func messaging(_ messaging: Messaging, didReceiveRegistrationToken gcmToken: String) {
    print("gcm: registration token: \(gcmToken)")

    // sync latest GCM token w/ server
    iCloudUserIDAsync() { cloudId, error in
      guard let id = cloudId else { return }
      let params = ["gcm_token": gcmToken]
      Installation.patch(cloudId: id, params: params, completion: { (success, _) in
        if success {
          print("synced GCM token")
        } else {
          print("FAIL: sync GCM token")
        }
      })
    }

    // NOTE: shared topic for all notification types; fork behavior on payload
    let topic = "all"
    Messaging.messaging().subscribe(toTopic: topic) { error in
      if let errorDesc: String = error?.localizedDescription {
        print("ERROR: gcm: failed to subscribe to topic \(topic) - \(errorDesc)")
      } else {
        print("gcm: subscribed to topic: \(topic)")
      }
    }

  }

}

extension AppDelegate: NotificationManagerDelegate {

  func present(_ vc: UIViewController, animated: Bool) {
    guard let presentingVC = self.window?.rootViewController else {
      return print("MIA: rootVC")
    }
    if let currentlyPresentedVC = presentingVC.presentedViewController  {
      currentlyPresentedVC.dismiss(animated: animated) {
        presentingVC.present(vc, animated: animated, completion: nil)
      }
    } else {
      presentingVC.present(vc, animated: animated, completion: nil)
    }
  }

  func openInSafari(url: URL) {
    self.lastViewedURL = url
    if let presented = self.mainController.presentedViewController {
      presented.dismiss(animated: false, completion: { [unowned self] in
        let svc = SFSafariViewController(url: url)
        self.mainController.present(svc, animated: true, completion: nil)
      })
    } else {
      let svc = SFSafariViewController(url: url)
      self.tabController.present(svc, animated: true, completion: nil)
    }
  }

  func push(_ vc: UIViewController, animated: Bool) {
    // TODO: refactor VC routing arch, else:
    // > Warning: Attempt to present <App.DetailViewController...> on <App.MainController...> whose view is not in the window hierarchy!
    guard
      let rootVC = self.window?.rootViewController
      else { return print("MIA: root VC") }
    if let targetVC = rootVC as? UINavigationController {
      targetVC.pushViewController(vc, animated: animated)
    } else if let targetVC = rootVC as? UITabBarController {
      guard let selVC = targetVC.selectedViewController else { return print("MIA: tab selected VC") }
      if let selVCisNavVC = selVC as? UINavigationController {
        selVCisNavVC.pushViewController(vc, animated: animated)
      } else {
        guard let selNavVC = selVC.navigationController else { return print("MIA: tab selected vc nav vc") }
        selNavVC.pushViewController(vc, animated: animated)
      }
    } else {
      print("error: unknown root VC class")
    }
  }

}

// https://gist.github.com/Thomvis/b378f926b6e1a48973f694419ed73aca
extension Int {
  var seconds: DispatchTimeInterval {
    return DispatchTimeInterval.seconds(self)
  }
  var second: DispatchTimeInterval {
    return seconds
  }
  var milliseconds: DispatchTimeInterval {
    return DispatchTimeInterval.milliseconds(self)
  }
  var millisecond: DispatchTimeInterval {
    return milliseconds
  }
}
extension DispatchTimeInterval {
  var fromNow: DispatchTime {
    return DispatchTime.now() + self
  }
}


