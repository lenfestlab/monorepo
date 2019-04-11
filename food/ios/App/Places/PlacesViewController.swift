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
    self.analytics.log(.searchForRestaurant(searchTerm: searchBar.text ?? ""))
    clearSearch()
  }

  func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
    self.analytics.log(.searchForRestaurant(searchTerm: searchBar.text ?? ""))
    searchBarTextDidChange(searchText: searchBar.text ?? "")
    searchBar.resignFirstResponder()
  }

}

extension PlacesViewController : FilterModuleDelegate {
  func filterUpdated(_ viewController: UIViewController, filter: FilterModule) {
    viewController.dismiss(animated: true, completion: nil)

    self.placeStore.filterModule = filter

    if let labelText = filter.labelText() {
      self.filterBar.attributedText = labelText
      self.filterBarIsHidden = false
    } else {
      self.filterBar.attributedText = nil
      self.filterBarIsHidden = true
    }

    let authorsFiltered = filter.authors.count > 0
    let pricesFiltered = filter.prices.count > 0
    let nabesFiltered = filter.nabes.count > 0
    let cuisinesFiltered = filter.categories.count > 0
    let ratingsFiltered = filter.ratings.count > 0
    let sort = filter.sortMode

    let filtered = authorsFiltered || pricesFiltered || nabesFiltered || ratingsFiltered
    let active = cuisinesFiltered || filtered

    self.filterButton.isSelected = filtered
    self.cuisineButton.isSelected = cuisinesFiltered
    self.sortButton.isSelected = sort != .distance

    self.mapViewController.showIndex = active
    self.listViewController.showIndex = active

    let defaultCoordinate = CLLocationCoordinate2D(latitude: 39.9526, longitude: -75.1652)
    let coordinate = LocationManager.shared.latestLocation?.coordinate ?? defaultCoordinate
    self.placeStore.fetchMapData(path: self.path, showLoadingIndicator: self.viewIfLoaded?.window != nil, coordinate: coordinate)
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
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "map-view"), style: .plain, target: self, action: #selector(map))
      } else {
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "list-view"), style: .plain, target: self, action: #selector(list))
      }
    }
    get {
      return _selectedIndex
    }
  }

  lazy var searchBar: UISearchBar! = {
    let searchBar = UISearchBar(frame: CGRect(x: 0, y: 0, width: 600, height: 60))
    searchBar.setSearchFieldBackgroundImage(UIImage(named: "search-bar"), for: .normal)

    let placeholderAppearance = UILabel.appearance(whenContainedInInstancesOf: [UISearchBar.self])
    placeholderAppearance.font = UIFont.lightSmall

    let searchTextAppearance = UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self])
    searchTextAppearance.font = UIFont.lightSmall

    searchBar.searchTextPositionAdjustment = UIOffset(horizontal: -10, vertical: 0)
    searchBar.setImage(UIImage(), for: UISearchBar.Icon.search, state: .normal)
    searchBar.placeholder = "Type a restaurant name"
    searchBar.delegate = self
    searchBar.tintColor = .oceanBlue
    return searchBar
  }()

  lazy var filterButton: UIButton! = {
    let filterButton = UIButton(frame: .zero)
    filterButton.setImage(UIImage(named: "filter-button"), for: .normal)
    filterButton.setImage(UIImage(named: "filter-button-selected"), for: .selected)
    filterButton.setImage(UIImage(named: "filter-button-selected"), for: .highlighted)
    filterButton.addTarget(self, action: #selector(showFilter), for: .touchUpInside)
    return filterButton
  }()

  lazy var sortButton : UIButton! = {
    let sortButton = UIButton(frame: .zero)
    sortButton.setImage(UIImage(named: "sort-button"), for: .normal)
    sortButton.setImage(UIImage(named: "sort-button-selected"), for: .selected)
    sortButton.setImage(UIImage(named: "sort-button-selected"), for: .highlighted)
    sortButton.addTarget(self, action: #selector(showSort), for: .touchUpInside)
    return sortButton
  }()

  lazy var cuisineButton : UIButton! = {
    let cuisineButton = UIButton(frame: .zero)
    cuisineButton.setImage(UIImage(named: "cuisine-button"), for: .normal)
    cuisineButton.setImage(UIImage(named: "cuisine-button-selected"), for: .selected)
    cuisineButton.setImage(UIImage(named: "cuisine-button-selected"), for: .highlighted)
    cuisineButton.addTarget(self, action: #selector(showCategories), for: .touchUpInside)
    return cuisineButton
  }()


  var topBar : UIToolbar! = {
    let topBar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 175, height: 44))
    topBar.isTranslucent = false
    topBar.barTintColor = UIColor.navigationColor()
    topBar.tintColor =  UIColor.iconColor()
    return topBar
  }()

  var filterBar : UILabel! = {
    let filterBar = UILabel(frame: CGRect(x: 0, y: 0, width: 175, height: 34))
    filterBar.backgroundColor = UIColor.grey
    filterBar.textAlignment = .center
    return filterBar
  }()


  var topBarIsHidden = false {
    didSet {
      self.topBar?.isHidden = topBarIsHidden
      self.listViewController.topPadding = 20 + (self.topBarIsHidden ? 0 : 44) + (self.filterBarIsHidden ? 0 : 34)
      self.mapViewController.topPadding = (self.topBarIsHidden ? 0 : 44) + (self.filterBarIsHidden ? 0 : 34)
    }
  }

  var filterBarIsHidden = false {
    didSet {
      self.filterBar?.isHidden = filterBarIsHidden
      self.listViewController.topPadding = 20 + (self.topBarIsHidden ? 0 : 44) + (self.filterBarIsHidden ? 0 : 34)
      self.mapViewController.topPadding = (self.topBarIsHidden ? 0 : 44) + (self.filterBarIsHidden ? 0 : 34)
    }
  }


  let placeStore : PlaceStore!

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
    self.filterBarIsHidden = true

    let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
    let one = UIBarButtonItem(customView: self.filterButton)
    let two = UIBarButtonItem(customView: self.sortButton)
    let three = UIBarButtonItem(customView: self.cuisineButton)

    self.topBar.setItems([space, space, space, one, space, two, space, three, space, space, space], animated: false)

    self.view.addSubview(self.topBar)
    self.view.addSubview(self.filterBar)

    self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "List", style: .plain, target: self, action: #selector(list))

    if let location = self.locationManager.latestLocation {
      initialMapDataFetch(coordinate: location.coordinate)
    } else {
      let coordinate = CLLocationCoordinate2D(latitude: 39.9526, longitude: -75.1652)
      self.mapViewController.centerMap(coordinate)
      self.placeStore.fetchMapData(path: self.path, showLoadingIndicator: self.viewIfLoaded?.window != nil, coordinate: coordinate)
    }

  }

  var _initalDataFetched = false

  func refresh() {
    self.placeStore.refresh(showLoadingIndicator: self.viewIfLoaded?.window != nil)
  }

  func initialMapDataFetch(coordinate: CLLocationCoordinate2D) {
    if _initalDataFetched {
      return
    }
    if self.placeStore.loading {
      return
    }
    print(self.placeStore.loading)
//    self.mapViewController.centerMap(coordinate)
    self.placeStore.fetchMapData(path: self.path, showLoadingIndicator: self.viewIfLoaded?.window != nil, coordinate: coordinate)
  }

  override func viewWillLayoutSubviews() {
    super.viewWillLayoutSubviews()
    let vc = viewControllers[self.selectedIndex]
    vc.view.frame = self.view.bounds
    self.topBar.frame = CGRect(x: 0, y: -12, width: self.view.frame.width, height: 54)
    self.filterBar.frame = CGRect(x: 0, y: 40, width: self.view.frame.width, height: 34)
  }

  @IBAction func dismissSearch(sender: UIButton) {
    self.searchBar.resignFirstResponder()
  }

  @IBAction func showCategories() {
    self.analytics.log(.tapsCuisineButton())
    let cuisineFilter = CuisinesViewController(analytics: self.analytics, filter: self.placeStore.filterModule)
    cuisineFilter.delegate = self
    let navigationController = PopupViewController(rootViewController: cuisineFilter)
    let screenHeight = AppDelegate.shared().window?.frame.size.height ?? 568
    navigationController.popUpHeight = max(screenHeight - 130 - 122, 568 - 20 - 40)
    navigationController.modalPresentationStyle = .overFullScreen
    navigationController.modalTransitionStyle = .crossDissolve
    self.navigationController?.present(navigationController, animated: true, completion: nil)
  }

  @IBAction func showFilter() {
    self.analytics.log(.tapsFilterButton())
    clearSearch()
    let filter = FilterViewController(analytics: self.analytics, filter: self.placeStore.filterModule)
    filter.filterDelegate = self
    let navigationController = PopupViewController(rootViewController: filter)
    let screenHeight = AppDelegate.shared().window?.frame.size.height ?? 568
    navigationController.popUpHeight = max(screenHeight - 81 - 74, 568 - 20 - 40)
    navigationController.modalPresentationStyle = .overFullScreen
    navigationController.modalTransitionStyle = .crossDissolve
    self.navigationController?.present(navigationController, animated: true, completion: nil)
  }


  @IBAction func showSort() {
    self.analytics.log(.tapsSortButton())
    clearSearch()
    let sort = SortViewController(analytics: self.analytics, filter: self.placeStore.filterModule)
    sort.sortDelegate = self
    let navigationController = PopupViewController(rootViewController: sort)
    navigationController.popUpHeight = 238
    navigationController.modalPresentationStyle = .overFullScreen
    navigationController.modalTransitionStyle = .crossDissolve
    self.navigationController?.present(navigationController, animated: true, completion: nil)
  }

}
