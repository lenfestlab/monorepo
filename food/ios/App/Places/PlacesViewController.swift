import UIKit
import CoreLocation

extension PlacesViewController : PlaceStoreDelegate {
  func fetchedMapData() {
    if !_initalDataFetched {
      _initalDataFetched = true
      self.initalDataFetched()
    }
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
    self.placeStore.fetchMapData(path: self.path, coordinate: coordinate)
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
    self.placeStore.fetchMapData(path: self.path, coordinate: coordinate)
  }

}

extension PlacesViewController : FilterViewControllerDelegate {
  func filterUpdated(_ viewController: FilterViewController, filter: FilterModule) {
    viewController.dismiss(animated: true, completion: nil)

    let defaultCoordinate = CLLocationCoordinate2D(latitude: 39.9526, longitude: -75.1652)
    let coordinate = LocationManager.shared.latestLocation?.coordinate ?? defaultCoordinate
    self.placeStore.fetchMapData(path: self.path, coordinate: coordinate)
  }

}

class PlacesViewController: UIViewController {

  let locationManager = LocationManager.shared

  func initalDataFetched() {

  }

  func displayContentController(_ content: UIViewController) {
    addChild(content)
    self.view.insertSubview(content.view, at: 0)
    content.didMove(toParent: self)
  }

  func hideContentController(_ content: UIViewController) {
    content.willMove(toParent: nil)
    content.view.removeFromSuperview()
    content.removeFromParent()
  }

  var mapViewController: MapViewController!
  var listViewController: ListViewController!
  var viewControllers: [UIViewController]! = []

  private var _selectedIndex: Int = 0
  var selectedIndex: Int {
    set {
      hideContentController(self.viewControllers[selectedIndex])
      displayContentController(self.viewControllers[newValue])
      _selectedIndex = newValue
      if selectedIndex == 1 {
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Map", style: .plain, target: self, action: #selector(map))
      } else {
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "List", style: .plain, target: self, action: #selector(list))
      }
    }
    get {
      return _selectedIndex
    }
  }

  var topBar : UIToolbar! = {
    let topBar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 175, height: 44))
    topBar.isTranslucent = false

    let one = UIBarButtonItem(title: "Filter", style: .plain, target: self, action: #selector(showFilter))
    let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
    let two = UIBarButtonItem(title: "Cusines", style: .plain, target: self, action: #selector(showCategories))
    let three = UIBarButtonItem(title: "Sort", style: .plain, target: self, action: #selector(showSort))

    topBar.setItems([space, one, space, two, space, three, space], animated: false)
    topBar.barTintColor = UIColor.navigationColor()
    topBar.tintColor =  UIColor.iconColor()
    return topBar
  }()

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

  let path : String!

  init(path: String = "places.json", analytics: AnalyticsManager, categories: [Category] = []) {
    self.path = path
    self.analytics = analytics

    self.placeStore = PlaceStore()
    self.placeStore.filterModule.categories = categories

    self.mapViewController = MapViewController(analytics: self.analytics, placeStore: self.placeStore)
    self.listViewController = ListViewController(analytics: self.analytics, placeStore: self.placeStore)

    self.viewControllers = [self.mapViewController, self.listViewController]

    super.init(nibName: nil, bundle: nil)
    self.selectedIndex = 0

    self.placeStore.delegate = self
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  @IBAction func list(sender: UIButton) {
    if let viewControllers = self.viewControllers {
      let index = viewControllers.index(of: self.listViewController)
      self.selectedIndex = index ?? 0
    }
  }

  @IBAction func map(sender: UIButton) {
    if let viewControllers = self.viewControllers {
      let index = viewControllers.index(of: self.mapViewController)
      self.selectedIndex = index ?? 0
    }
  }

  @objc func onLocationUpdated(_ notification: Notification) {
    if let location = notification.object as? CLLocation {
      DispatchQueue.main.async {
        self.initialMapDataFetch(coordinate: location.coordinate)
      }
    }
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    NotificationCenter.default.addObserver(self, selector: #selector(onLocationUpdated(_:)), name: .locationUpdated, object: nil)

    self.topBar.isHidden = self.topBarIsHidden
    self.view.addSubview(self.topBar)

    self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "List", style: .plain, target: self, action: #selector(list))

    if let location = self.locationManager.latestLocation {
      initialMapDataFetch(coordinate: location.coordinate)
    } else {
      let coordinate = CLLocationCoordinate2D(latitude: 39.9526, longitude: -75.1652)
      self.mapViewController.centerMap(coordinate)
      self.placeStore.fetchMapData(path: self.path, coordinate: coordinate)
    }

  }

  var _initalDataFetched = false

  func refresh() {
    self.placeStore.refresh()
  }

  func initialMapDataFetch(coordinate: CLLocationCoordinate2D) {
    if _initalDataFetched {
      return
    }
    self.mapViewController.centerMap(coordinate)
    self.placeStore.fetchMapData(path: self.path, coordinate: coordinate)
  }

  override func viewWillLayoutSubviews() {
    super.viewWillLayoutSubviews()
    let vc = viewControllers[self.selectedIndex]
    vc.view.frame = self.view.bounds
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
    navigationController.popUpHeight = 600
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
