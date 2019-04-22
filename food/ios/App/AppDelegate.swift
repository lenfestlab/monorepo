import UIKit
import Firebase
import FirebaseMessaging
import Schedule
import SafariServices
import AlamofireNetworkActivityLogger
import RxSwift

typealias LaunchOptions = [UIApplication.LaunchOptionsKey: Any]?
let gcmMessageIDKey = "gcm.message_id"

struct Scheduler {
  static let main = MainScheduler.instance
  static let background = ConcurrentDispatchQueueScheduler(qos: .background)
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var lastViewedURL: URL?
  var window: UIWindow?
  var analytics: AnalyticsManager!
  var locationManager: LocationManager!
  var notificationManager: NotificationManager!
  var mainController: MainController!
  var tabController: TabBarViewController!

  class func shared() -> AppDelegate {
    return UIApplication.shared.delegate as! AppDelegate
  }

  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: LaunchOptions) -> Bool {
    let env = Env()
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

    self.analytics = AnalyticsManager(env)
    self.locationManager = LocationManager.sharedWith(analytics: analytics)

    let api = Api(env: env)
    self.notificationManager =
      NotificationManager(api: api,
                          analytics: analytics,
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

    self.analytics.log(.appLaunched)

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
        analytics: analytics,
        notificationManager: notificationManager)
    window!.rootViewController = self.tabController
  }

  func showEmailRegistration(cloudId: String) {
    mainController.pushViewController(
      EmailViewController(analytics: self.analytics, cloudId: cloudId),
      animated: false)
  }

  func application(
    _ application: UIApplication,
    didReceiveRemoteNotification
    userInfo: [AnyHashable : Any],
    fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult
    ) -> Void) {
    print("didReceiveRemoteNotification userInfo: \(userInfo)")

    if let notificationType: String = userInfo["type"] as? String,
      notificationType == "location" {
      let locationManager = LocationManager.shared
      // wait for location update
      let _ = Plan.after(3.seconds).do {
        if let latestLocation = locationManager.latestLocation {
          locationManager.logLocationChange(latestLocation)
          let _ = Plan.after(3.seconds).do { // wait for GA to fire
            completionHandler(.newData)
          }
        } else {
          print("ERROR: MIA latestLocation")
          completionHandler(.noData)
        }
      }
    } else {
      completionHandler(.noData)
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
