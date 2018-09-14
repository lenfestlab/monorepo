import Reachability
import UIKit

typealias LaunchOptions = [UIApplicationLaunchOptionsKey: Any]?

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?
  var navController: UINavigationController?

  func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: LaunchOptions
    ) -> Bool {

    window = UIWindow(frame: UIScreen.main.bounds)
    let viewController = VenuesController()
    navController = UINavigationController(rootViewController: viewController)
    window?.rootViewController = navController
    window?.makeKeyAndVisible()

    return true
  }

}
