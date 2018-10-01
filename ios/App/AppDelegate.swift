import Reachability
import UIKit
import Firebase
import FirebaseAnalytics
import Crashlytics
import Fabric

typealias LaunchOptions = [UIApplicationLaunchOptionsKey: Any]?

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?

  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: LaunchOptions) -> Bool {
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
    let introController = IntroViewController()
    let navigationController = UINavigationController(rootViewController: introController)
    window!.rootViewController = navigationController
  }

  func showPermissions() {
    Analytics.logEvent("viewed_location_permission_pitch", parameters: [:])
    let permissionsController = PermissionsViewController()
    let navigationController = UINavigationController(rootViewController: permissionsController)
    window!.rootViewController = navigationController
  }

  func showNotifications() {
    let notificationsController = NotificationViewController()
    let navigationController = UINavigationController(rootViewController: notificationsController)
    window!.rootViewController = navigationController
  }

  func showHomeScreen() {
    let mapController = MapViewController()
    window!.rootViewController = mapController
  }

}
