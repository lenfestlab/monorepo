import Reachability
import UIKit
import Firebase
import Crashlytics
import Fabric
import AlamofireNetworkActivityLogger
import FirebaseMessaging

typealias LaunchOptions = [UIApplicationLaunchOptionsKey: Any]?
let gcmMessageIDKey = "gcm.message_id"

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?
  var analytics: AnalyticsManager!
  var locationManager: LocationManager!
  var notificationManager: NotificationManager!
  var motionManager: MotionManager!
  var mainController: MainController!

  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: LaunchOptions) -> Bool {
    NetworkActivityLogger.shared.startLogging()

    let env = Env()

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

    Fabric.sharedSDK().debug = env.isPreProduction

    self.analytics = AnalyticsManager(env)
    self.locationManager = LocationManager.sharedWith(analytics: analytics)
    self.motionManager = MotionManager.sharedWith(analytics: analytics)
    self.notificationManager = NotificationManager.sharedWith(analytics: analytics)
    window = UIWindow(frame: UIScreen.main.bounds)
    let onboardingCompleted = UserDefaults.standard.bool(forKey: "onboarding-completed")

    let introController = IntroViewController(analytics: self.analytics)
    self.mainController = MainController(rootViewController: introController)
    self.notificationManager.delegate = self.mainController

    if onboardingCompleted {
      showHomeScreen()
    }
    window!.rootViewController = self.mainController
    window!.makeKeyAndVisible()

    return true
  }

  func showPermissions() {
    mainController.pushViewController(
      PermissionsViewController(analytics: self.analytics),
      animated: false)
  }

  func showNotifications() {
    mainController.pushViewController(
      NotificationViewController(analytics: self.analytics),
      animated: false)
  }

  func showMotionPermissions() {
    mainController.pushViewController(
      MotionViewController(analytics: self.analytics),
      animated: false)
  }

  func showHomeScreen() {
    mainController.pushViewController(
      MapViewController(analytics: self.analytics),
      animated: false)
  }

}


extension AppDelegate: MessagingDelegate {

  func messaging(_ messaging: Messaging, didReceiveRegistrationToken gcmToken: String) {
    print("gcm: registration token: \(gcmToken)")
    // sync w/ api for targeted notifications
  }

}
