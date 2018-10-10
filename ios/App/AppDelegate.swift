import Reachability
import UIKit
import Firebase
import FirebaseAnalytics
import Crashlytics
import Fabric
import AlamofireNetworkActivityLogger

typealias LaunchOptions = [UIApplicationLaunchOptionsKey: Any]?

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  private let analytics: AnalyticsManager = AnalyticsManager(engine: LocalLogAnalyticsEngine())

  var window: UIWindow?

  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: LaunchOptions) -> Bool {
    NetworkActivityLogger.shared.startLogging()

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
    Analytics.logEvent("viewed_location_permission_pitch", parameters: [:])
    let permissionsController = PermissionsViewController(analytics: self.analytics)
    let navigationController = UINavigationController(rootViewController: permissionsController)
    window!.rootViewController = navigationController
  }

  func showNotifications() {
    let notificationsController = NotificationViewController(analytics: self.analytics)
    let navigationController = UINavigationController(rootViewController: notificationsController)
    window!.rootViewController = navigationController
  }

  func showHomeScreen() {
    let mapController = MapViewController(analytics: self.analytics)
    let navigationController = UINavigationController(rootViewController: mapController)
    window!.rootViewController = navigationController
  }

}
