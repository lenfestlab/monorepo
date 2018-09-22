import Reachability
import UIKit

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

    return true
  }
  
  func showIntro() {
    let introController = IntroViewController()
    let navigationController = UINavigationController(rootViewController: introController)
    window!.rootViewController = navigationController
  }
  
  func showPermissions() {
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
