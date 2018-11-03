import Reachability
import UIKit
import Firebase
import Crashlytics
import Fabric
import AlamofireNetworkActivityLogger

typealias LaunchOptions = [UIApplicationLaunchOptionsKey: Any]?

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?
  var analytics: AnalyticsManager!

  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: LaunchOptions) -> Bool {
    NetworkActivityLogger.shared.startLogging()

    let env = Env()
    self.analytics = AnalyticsManager(env)

    window = UIWindow(frame: UIScreen.main.bounds)
    let onboardingCompleted = UserDefaults.standard.bool(forKey: "onboarding-completed")
    if onboardingCompleted {
      showHomeScreen()
    } else {
      showIntro()
    }
    window!.makeKeyAndVisible()

    FirebaseApp.configure()
    Fabric.sharedSDK().debug = true
    return true
  }

  func showIntro() {
    let introController = IntroViewController(analytics: self.analytics)
    let navigationController = UINavigationController(rootViewController: introController)
    window!.rootViewController = navigationController
  }

  func showPermissions() {
    let permissionsController = PermissionsViewController(analytics: self.analytics)
    let navigationController = UINavigationController(rootViewController: permissionsController)
    window!.rootViewController = navigationController
  }

  func showNotifications() {
    let notificationsController = NotificationViewController(analytics: self.analytics)
    let navigationController = UINavigationController(rootViewController: notificationsController)
    window!.rootViewController = navigationController
  }

  func showMotionPermissions() {
    let notificationsController = MotionViewController(analytics: self.analytics)
    let navigationController = UINavigationController(rootViewController: notificationsController)
    window!.rootViewController = navigationController
  }

  func showHomeScreen() {
    let mapController = MapViewController(analytics: self.analytics)
    let navigationController = UINavigationController(rootViewController: mapController)
    window!.rootViewController = navigationController
  }

}
