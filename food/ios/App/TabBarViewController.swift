import UIKit

class TabBarViewController: UITabBarController {

  var placesViewController: PlacesViewController!
  var favoritesViewController: PlacesViewController!
  var listViewController: ListViewController!
  var guideViewController: GuidesViewController!

  private let analytics: AnalyticsManager

  init(analytics: AnalyticsManager) {
    self.analytics = analytics

    super.init(nibName: nil, bundle: nil)

    self.navigationController?.isNavigationBarHidden = true


    navigationItem.hidesBackButton = true
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  @IBAction func settings(sender: UIButton) {
    let settingsController = SettingsViewController(analytics: self.analytics)
    settingsController.hidesBottomBarWhenPushed = true
    self.placesViewController.navigationController?.pushViewController(settingsController, animated: true)
    // https://stackoverflow.com/a/23133995
    navigationItem.backBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: nil, action: nil)
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    self.navigationController?.styleController()

    self.placesViewController = PlacesViewController(analytics: self.analytics)
    let mapNavigationController = UINavigationController(rootViewController: self.placesViewController)
    mapNavigationController.styleController()
    mapNavigationController.tabBarItem.title = "All Restaurants"

    self.guideViewController = GuidesViewController(analytics: self.analytics, isCuisine: false)
    let guideNavigationController = UINavigationController(rootViewController: self.guideViewController)
    guideNavigationController.tabBarItem.title = "Guides"

    self.favoritesViewController = PlacesViewController(analytics: self.analytics)
    self.favoritesViewController.title = "My List"
    self.favoritesViewController.selectedIndex = 1
    self.favoritesViewController.topBarIsHidden = true
    let favoritesNavigationController = UINavigationController(rootViewController: self.favoritesViewController)
    favoritesNavigationController.styleController()
    favoritesNavigationController.tabBarItem.title = "My List"

    self.viewControllers = [mapNavigationController, guideNavigationController, favoritesNavigationController]

    self.tabBar.tintColor = UIColor.offRed()
    self.tabBar.barTintColor = UIColor.beige()

    self.navigationController?.isNavigationBarHidden = true

    self.placesViewController.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "settings-button"), style: .plain, target: self, action: #selector(settings))
    self.placesViewController.navigationItem.titleView =  self.placesViewController.searchBar
  }

}
