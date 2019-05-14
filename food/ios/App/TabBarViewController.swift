import UIKit

class TabBarViewController: UITabBarController {

  let restaurantsTitle = "All Restaurants"
  let guidesTitle = "Guides"
  let myListTitle = "My List"

  var placesViewController: HomeViewController!
  var favoritesViewController: FavoritesViewController!
  var listViewController: ListViewController!
  var guideViewController: GuidesViewController!

  private let context: Context
  private let notificationManager: NotificationManager

  init(
    context: Context,
    notificationManager: NotificationManager
    ) {
    self.context = context
    self.notificationManager = notificationManager
    super.init(nibName: nil, bundle: nil)
    self.navigationController?.isNavigationBarHidden = true
    navigationItem.hidesBackButton = true
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  @IBAction func settings(sender: UIButton) {
    self.context.analytics.log(.tapsSettingsButton)
    let settingsController =
      SettingsViewController(
        analytics: context.analytics,
        notificationManager: notificationManager)
    settingsController.hidesBottomBarWhenPushed = true
    self.placesViewController.navigationController?.pushViewController(settingsController, animated: true)
    // https://stackoverflow.com/a/23133995
    navigationItem.backBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: nil, action: nil)
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    self.navigationController?.styleController()

    var controllers : [UIViewController] = []

    self.placesViewController = HomeViewController(context: context)
    self.placesViewController.selectedIndex = 0
    let mapNavigationController = UINavigationController(rootViewController: self.placesViewController)
    mapNavigationController.styleController()
    mapNavigationController.tabBarItem.title = restaurantsTitle
    mapNavigationController.tabBarItem.image = UIImage(named: "tab-restaurant-icon")
    mapNavigationController.tabBarItem.selectedImage = UIImage(named: "tab-restaurant-icon-selected")
    controllers.append(mapNavigationController)

    self.guideViewController = GuidesViewController(context: context)
    let guideNavigationController = UINavigationController(rootViewController: self.guideViewController)
    guideNavigationController.tabBarItem.title = "Guides"
    guideNavigationController.tabBarItem.image = UIImage(named: "tab-guides-icon")
    guideNavigationController.tabBarItem.selectedImage = UIImage(named: "tab-guides-icon-selected")
    controllers.append(guideNavigationController)

    if Installation.authToken() != nil {
      self.favoritesViewController = FavoritesViewController(context: context)
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
    self.placesViewController.navigationController?.navigationBar.shadowImage = UIImage()

    self.extendedLayoutIncludesOpaqueBars = true
  }

  override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
    if item.title == restaurantsTitle {
      context.analytics.log(.tapsAllRestaurant)
      return
    }
    if item.title == guidesTitle {
      context.analytics.log(.tapsGuides)
      return
    }
    if item.title == myListTitle {
      context.analytics.log(.tapsMyList)
      return
    }

  }


}
