import UIKit
import Firebase
import FirebaseMessaging
import SafariServices
import AlamofireNetworkActivityLogger
import RxSwift
import RxSwiftExt
import SwiftDate
import CoreLocation
import NSObject_Rx
import Sentry

typealias Result<T> = Swift.Result<T, Error>
typealias LaunchOptions = [UIApplication.LaunchOptionsKey: Any]?

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var context: Context!

  var lastViewedURL: URL?
  var window: UIWindow?
  var analytics: AnalyticsManager!
  var env: Env!
  var api: Api!
  var cache: Cache!
  var locationManager: LocationManager!
  var notificationManager: NotificationManager!
  var mainController: MainController!
  var tabController: TabBarViewController!

  class func shared() -> AppDelegate {
    return UIApplication.shared.delegate as! AppDelegate
  }

  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: LaunchOptions) -> Bool {
    self.env = Env()
    if !env.isRemote {
      NetworkActivityLogger.shared.level = .off
      NetworkActivityLogger.shared.startLogging()
    }
    self.addCrashReporting(env: env)

    FirebaseApp.configure()
    Messaging.messaging().delegate = self
    application.registerForRemoteNotifications()
    InstanceID.instanceID().instanceID { (result, error) in
      if let error = error {
        print("gcm: Error fetching remote instange ID: \(error)")
      }
    }

    self.cache = Cache()
    self.locationManager = LocationManager(env: env)
    self.analytics = AnalyticsManager(env: env, locationManager: locationManager)
    self.api =
      Api(
        env: env,
        cache: cache,
        locationManager: locationManager)
    self.context =
      Context(
        api: api,
        analytics: analytics,
        cache: cache,
        env: env,
        locationManager: locationManager)
    self.notificationManager = NotificationManager(context: context)

    window = UIWindow(frame: UIScreen.main.bounds)
    let onboardingCompleted = UserDefaults.standard.bool(forKey: "onboarding-completed")

    let introController = IntroViewController(analytics: self.analytics)
    self.mainController = MainController(rootViewController: introController)
    self.notificationManager.delegate = self

    self.syncData()
    self.observeFirstTouch()
    self.observeBookmarkedPlaces()

    if !onboardingCompleted {
      window!.rootViewController = self.mainController
    } else {
      self.showHomeScreen()
    }
    window!.makeKeyAndVisible()
    return true
  }

  private func observeBookmarkedPlaces() -> Void {
    // sync bookmarked places with monitored regions for nearby alerts
    self.cache.bookmarkedPlaces$
      .map({ $0.map({ $0.region }) })
      .observeOn(Scheduler.background)
      .distinctUntilChanged()
      .subscribe(onNext: { [weak self] regions in
        self?.locationManager.resetRegionMonitoring(latestRegions: regions)
      })
      .disposed(by: rx.disposeBag)
  }

  func showPermissions() {
    mainController.pushViewController(
      PermissionsViewController(context: context),
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

  func showEmailRegistration() {
    mainController.pushViewController(
      EmailViewController(context: self.context),
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
      // NOTE: wait long enough for location update ...
      let queue = DispatchQueue.main
      queue.asyncAfter(deadline: 3.seconds.fromNow, execute: { [weak self] in
        guard
          let `self` = self,
          let latestLocation = self.locationManager.latestLocation
          else { return completionHandler(.noData) }
        self.analytics.logLocationChange(latestLocation)
        // NOTE: wait long enough for GA request too complete
        queue.asyncAfter(deadline: 3.seconds.fromNow, execute: {
          completionHandler(.newData)
        })
      })
    case .visitCheck:
      guard let placeId = userInfo["place_id"] as? String
        else { print("MIA: `place_id`"); return completionHandler(.failed) }
      let place$ = self.api.getPlace$(placeId)
      let location$ = self.locationManager.significantLocation$
      Observable.combineLatest(place$, location$)
        .flatMapFirst({ [weak self] (result, currentLocation) -> Observable<Bookmark> in
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
          guard let `self` = self
            else { return completionHandler(.failed) }
          switch event {
          case .next(let bookmark):
            // if API recorded visit, display local notification (stag only)
            guard self.env.isPreProduction,
              let placeName = bookmark.place?.name,
              let center = self.notificationManager.notificationCenter
              else { return }
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
          case let .error(error):
            print(error)
            completionHandler(.failed)
          case .completed:
            completionHandler(.newData)
          }
        })
        .disposed(by: rx.disposeBag)

    }
  }

  private func addCrashReporting(env: Env) -> Void {
    do {
      Client.shared = try Client(dsn: env.get(.sentryDSN))
      Client.shared?.environment =  env.name.full
      try Client.shared?.startCrashHandler()
    } catch let error {
      print("\(error)")
    }
  }

  private func syncData() -> Void {
    let register$ =
      api.registerInstall$()
        .mapTo(true)

    let updateDefaultPlaces$ =
      locationManager.latestOrDefaultLocation$
        .flatMapLatest({ [unowned self] location -> Observable<[Place]> in
          let coordinate = location.coordinate
          let lat = coordinate.latitude
          let lng = coordinate.longitude
          return self.api.updateDefaultPlaces$(lat: lat, lng: lng)
        })
        .mapTo(true)

    let updateBookmarks$ =
      api.updateBookmarks$()
        .mapTo(true)

    Observable.zip([
      register$,
      updateDefaultPlaces$,
      updateBookmarks$,
      ])
      .subscribe()
      .disposed(by: rx.disposeBag)
  }

  private func observeFirstTouch() -> Void {
    guard let window = self.window else { return }
    let notificationResponse$ = notificationManager.notificationResponse$
    let anyTouch$ = window.rx.methodInvoked(#selector(UIView.hitTest(_:with:)))
    anyTouch$.withLatestFrom(notificationResponse$)
      .take(1)
      .subscribe(onNext: { [unowned self] response in
        self.analytics.log(.appLaunched((response != nil)
          ? .notification
          : .direct))
      }).disposed(by: rx.disposeBag)
  }

}


extension AppDelegate: MessagingDelegate {

  func messaging(_ messaging: Messaging, didReceiveRegistrationToken gcmToken: String) {
    api.updateGcmToken$(gcmToken)
      .subscribe(onError: { error in
        print("FAIL: sync GCM token \(error)")
      })
      .disposed(by: rx.disposeBag)

    // NOTE: shared topic for all notification types; fork behavior on payload
    let topic = "all"
    Messaging.messaging().subscribe(toTopic: topic) { error in
      if let errorDesc: String = error?.localizedDescription {
        print("ERROR: gcm: failed to subscribe to topic \(topic) - \(errorDesc)")
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

  func openInlineBrowser(url: URL) {
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


