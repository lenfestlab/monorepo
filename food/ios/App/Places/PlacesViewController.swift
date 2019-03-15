import UIKit
import CoreLocation

extension PlacesViewController : PlaceStoreDelegate {
  func fetchedMapData() {
    self.mapViewController.fetchedMapData()
    self.listViewController.fetchedMapData()
  }

  func didSetPlaceFiltered() {
    self.mapViewController.updateAnnotations()
  }

  func filterText() -> String? {
    return self.searchBar.text
  }
}

extension PlacesViewController : UISearchBarDelegate {

  func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
    searchBar.showsCancelButton = true
  }

  func searchBarShouldEndEditing(_ searchBar: UISearchBar) -> Bool {
    searchBar.showsCancelButton = false
    return true
  }

  func searchBarTextDidChange(searchText: String) {
    self.placeStore.updateFilter(searchText: searchText)
    self.mapViewController.reloadMap()

    fetchedMapData()
  }

  func clearSearch() {
    searchBar.text = ""
    searchBarTextDidChange(searchText: "")
    searchBar.resignFirstResponder()
  }

  func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
    clearSearch()
  }

  func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
    searchBarTextDidChange(searchText: searchBar.text ?? "")
    searchBar.resignFirstResponder()
  }

}

extension PlacesViewController : SortViewControllerDelegate {

  func sortUpdated(_ viewController: SortViewController, sort: SortMode) {
    viewController.dismiss(animated: true, completion: nil)

    print(sort)

    self.placeStore.filterModule.sortMode = sort

    let defaultCoordinate = CLLocationCoordinate2D(latitude: 39.9526, longitude: -75.1652)
    let coordinate = LocationManager.shared.latestLocation?.coordinate ?? defaultCoordinate
    self.placeStore.fetchMapData(coordinate: coordinate)
  }

}

extension PlacesViewController : CuisinesViewControllerDelegate {

  func categoriesUpdated(_ viewController: CuisinesViewController, categories: [Category]) {
    clearSearch()

    viewController.dismiss(animated: true, completion: nil)

    print(categories)

    self.placeStore.filterModule.categories = categories

    let defaultCoordinate = CLLocationCoordinate2D(latitude: 39.9526, longitude: -75.1652)
    let coordinate = LocationManager.shared.latestLocation?.coordinate ?? defaultCoordinate
    self.placeStore.fetchMapData(coordinate: coordinate)
  }

}

extension PlacesViewController : FilterViewControllerDelegate {
  func filterUpdated(_ viewController: FilterViewController, filter: FilterModule) {
    viewController.dismiss(animated: true, completion: nil)

    let defaultCoordinate = CLLocationCoordinate2D(latitude: 39.9526, longitude: -75.1652)
    let coordinate = LocationManager.shared.latestLocation?.coordinate ?? defaultCoordinate
    self.placeStore.fetchMapData(coordinate: coordinate)
  }

}


class PlacesViewController: UITabBarController {

  var mapViewController: MapViewController!
  var listViewController: ListViewController!

  var topBar : UIToolbar!

  var topBarIsHidden = false {
    didSet {
      self.topBar?.isHidden = topBarIsHidden
      self.listViewController.topPadding = self.topBarIsHidden ? 20 : 64
    }
  }

  let placeStore : PlaceStore!

  lazy var searchBar: UISearchBar! = {
    let searchBar = UISearchBar(frame: CGRect(x: 0, y: 0, width: 600, height: 60))
    searchBar.placeholder = "Search All Restaurants"
    searchBar.delegate = self
    return searchBar
  }()

  private let analytics: AnalyticsManager

  init(analytics: AnalyticsManager, categories: [Category] = []) {
    self.analytics = analytics

    self.placeStore = PlaceStore()
    self.placeStore.filterModule.categories = categories

    super.init(nibName: nil, bundle: nil)

    self.placeStore.delegate = self

    self.navigationController?.isNavigationBarHidden = true

    self.tabBar.isHidden = true
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  @IBAction func list(sender: UIButton) {
    if let viewControllers = self.viewControllers {
      let index = viewControllers.index(of: self.listViewController)
      self.selectedIndex = index ?? 0
    }
    self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Map", style: .plain, target: self, action: #selector(map))
  }

  @IBAction func map(sender: UIButton) {
    if let viewControllers = self.viewControllers {
      let index = viewControllers.index(of: self.mapViewController)
      self.selectedIndex = index ?? 0
    }
    self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "List", style: .plain, target: self, action: #selector(list))
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    self.mapViewController = MapViewController(analytics: self.analytics, placeStore: self.placeStore)
    self.listViewController = ListViewController(analytics: self.analytics, placeStore: self.placeStore)
    self.viewControllers = [mapViewController, listViewController]

    self.topBar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 175, height: 44))
    self.topBar.isTranslucent = false

    let one = UIBarButtonItem(title: "Filter", style: .plain, target: self, action: #selector(showFilter))
    let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
    let two = UIBarButtonItem(title: "Cusines", style: .plain, target: self, action: #selector(showCategories))
    let spacetwo = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
    let three = UIBarButtonItem(title: "Sort", style: .plain, target: self, action: #selector(showSort))

    self.topBar.setItems([one, space, two, spacetwo, three], animated: false)
    self.topBar.barTintColor = UIColor.beige()
    self.topBar.tintColor =  UIColor.offRed()
    self.topBar.isHidden = self.topBarIsHidden

    self.view.addSubview(self.topBar)

    self.navigationController?.isNavigationBarHidden = true

    self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "List", style: .plain, target: self, action: #selector(list))
  }

  override func viewWillLayoutSubviews() {
    super.viewWillLayoutSubviews()
    self.topBar.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 44)
  }

  @IBAction func dismissSearch(sender: UIButton) {
    self.searchBar.resignFirstResponder()
  }

  @IBAction func showCategories() {
    let cuisineFilter = CuisinesViewController(analytics: self.analytics, selected: self.placeStore.filterModule.categories)
    cuisineFilter.delegate = self
    let navigationController = PopupViewController(rootViewController: cuisineFilter)
    navigationController.popUpHeight = 500
    navigationController.modalPresentationStyle = .overFullScreen
    navigationController.modalTransitionStyle = .crossDissolve
    self.navigationController?.present(navigationController, animated: true, completion: nil)
  }

  @IBAction func showFilter() {
    clearSearch()
    let filter = FilterViewController(analytics: self.analytics, filter: self.placeStore.filterModule)
    filter.filterDelegate = self
    let navigationController = PopupViewController(rootViewController: filter)
    navigationController.popUpHeight = 550
    navigationController.modalPresentationStyle = .overFullScreen
    navigationController.modalTransitionStyle = .crossDissolve
    self.navigationController?.present(navigationController, animated: true, completion: nil)
  }


  @IBAction func showSort() {
    clearSearch()
    let sort = SortViewController(sortMode: self.placeStore.filterModule.sortMode)
    sort.sortDelegate = self
    let navigationController = PopupViewController(rootViewController: sort)
    navigationController.popUpHeight = 175
    navigationController.modalPresentationStyle = .overFullScreen
    navigationController.modalTransitionStyle = .crossDissolve
    self.navigationController?.present(navigationController, animated: true, completion: nil)
  }

}
