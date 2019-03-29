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

    var controllers : [UIViewController] = []

    self.placesViewController = PlacesViewController(analytics: self.analytics)
    let mapNavigationController = UINavigationController(rootViewController: self.placesViewController)
    mapNavigationController.styleController()
    mapNavigationController.tabBarItem.title = "All Restaurants"
    mapNavigationController.tabBarItem.image = UIImage(named: "tab-restaurant-icon")
    mapNavigationController.tabBarItem.selectedImage = UIImage(named: "tab-restaurant-icon-selected")
    controllers.append(mapNavigationController)

    self.guideViewController = GuidesViewController(analytics: self.analytics, isCuisine: false)
    let guideNavigationController = UINavigationController(rootViewController: self.guideViewController)
    guideNavigationController.tabBarItem.title = "Guides"
    guideNavigationController.tabBarItem.image = UIImage(named: "tab-guides-icon")
    guideNavigationController.tabBarItem.selectedImage = UIImage(named: "tab-guides-icon-selected")
    controllers.append(guideNavigationController)

    if Installation.authToken() != nil {
      self.favoritesViewController = FavoritesViewController(analytics: self.analytics)
      self.favoritesViewController.selectedIndex = 1
      let favoritesNavigationController = UINavigationController(rootViewController: self.favoritesViewController)
      favoritesNavigationController.styleController()
      favoritesNavigationController.tabBarItem.title = "My List"
      favoritesNavigationController.tabBarItem.image = UIImage(named: "tab-list-icon")
      favoritesNavigationController.tabBarItem.selectedImage = UIImage(named: "tab-list-icon-selected")
      controllers.append(favoritesNavigationController)
    }

    self.viewControllers = controllers

    self.tabBar.tintColor = UIColor.slate
    self.tabBar.barTintColor = UIColor.white
    self.navigationController?.isNavigationBarHidden = true

    self.placesViewController.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "settings-button"), style: .plain, target: self, action: #selector(settings))
    self.placesViewController.navigationItem.titleView =  self.placesViewController.searchBar

    self.extendedLayoutIncludesOpaqueBars = true
  }

}
