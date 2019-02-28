import UIKit

class TabBarViewController: UITabBarController {

  var mapViewController: MapViewController!
  var guideViewController: CategoryViewController!

  private let analytics: AnalyticsManager

  init(analytics: AnalyticsManager) {
    self.analytics = analytics

    self.mapViewController = MapViewController(analytics: self.analytics)
    let mapNavigationController = UINavigationController(rootViewController: self.mapViewController)
    mapNavigationController.tabBarItem.title = "All Restaurants"

    self.guideViewController = CategoryViewController(analytics: self.analytics, isCuisine: false)
    let guideNavigationController = UINavigationController(rootViewController: self.guideViewController)
    guideNavigationController.tabBarItem.title = "Guides"

    super.init(nibName: nil, bundle: nil)


    self.navigationController?.isNavigationBarHidden = true

    self.viewControllers = [mapNavigationController, guideNavigationController]

    navigationItem.hidesBackButton = true

  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  @IBAction func settings(sender: UIButton) {
    let settingsController = SettingsViewController(analytics: self.analytics)
    navigationController?.pushViewController(settingsController, animated: true)
    // https://stackoverflow.com/a/23133995
    navigationItem.backBarButtonItem =
      UIBarButtonItem(
        title: "Back",
        style: .plain,
        target: nil,
        action: nil)
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    self.navigationController?.isNavigationBarHidden = true

    self.mapViewController.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "settings-button"), style: .plain, target: self, action: #selector(settings))
    self.mapViewController.navigationItem.titleView =  self.mapViewController.searchBar

  }

}
