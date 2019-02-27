import UIKit
import MapKit
import UserNotifications
import UPCarouselFlowLayout
import CoreMotion
import RxSwift
import RxCocoa
import NSObject_Rx

private let reuseIdentifier = "PlaceCell"
private let mapPinIdentifier = "pin"

fileprivate let sectionInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)

extension MapViewController: UICollectionViewDataSource {

  func numberOfSections(in collectionView: UICollectionView) -> Int {
    return 1
  }

  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return placesFiltered.count
  }

  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! PlaceCell

    // Configure the cell
    let mapPlace:MapPlace = self.placesFiltered[indexPath.row]
    let place = mapPlace.place
    cell.setPlace(place: place)
    return cell
  }
}

extension MapViewController: UICollectionViewDelegate {

  func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
    if indexOfMajorCell() == indexPath.row {
      let mapPlace:MapPlace = self.placesFiltered[indexPath.row]
      let place:Place = mapPlace.place
      analytics.log(.tapsOnViewArticle(post: place.post, currentLocation: self.lastCoordinate))
      let mainVC = self.navigationController as! MainController
      if let link = place.post?.link {
        mainVC.openInSafari(url: link)
      }
    } else {
      scrollToItem(at: indexPath)
      let mapPlace:MapPlace = self.placesFiltered[indexPath.row]
      self.currentPlace = mapPlace
    }
    return true
  }
}

extension MapViewController: LocationManagerAuthorizationDelegate {

  func locationUpdated(_ locationManager: LocationManager, location: CLLocation) {
    DispatchQueue.main.async {
      self.initialMapDataFetch(coordinate: location.coordinate)
    }
  }

  func authorized(_ locationManager: LocationManager, status: CLAuthorizationStatus) {
    print("locationManagerDelegate authorized")
  }

  func notAuthorized(_ locationManager: LocationManager, status: CLAuthorizationStatus) {
    print("locationManagerDelegate notAuthorized")
  }

}

extension MapViewController : MKMapViewDelegate {

  func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
    let coordinate = userLocation.coordinate
    self.locationManager.latestLocation = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
  }

  func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
    if annotation is MKUserLocation {
      //return nil so map view draws "blue dot" for standard user location
      return nil
    }

    let  pinView = ABAnnotationView(annotation: annotation, reuseIdentifier: mapPinIdentifier)
    pinView.tag = (annotation as! ABPointAnnotation).index

    pinView.isSelected = (annotation.title == currentPlace?.place.name)

    pinView.accessibilityLabel = "hello"
    let btn = UIButton(type: .detailDisclosure)
    pinView.rightCalloutAccessoryView = btn
    return pinView
  }

  func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
    let indexPath = IndexPath(row: view.tag, section: 0)
    let mapPlace:MapPlace = self.places[indexPath.row]
    let place = mapPlace.place
    analytics.log(.tapsOnPin(post: place.post, currentLocation: self.lastCoordinate))
    scrollToItem(at: indexPath)

    self.currentPlace = mapPlace
  }

}

extension MapViewController: UIGestureRecognizerDelegate {

  func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
    return true
  }

}

extension MapViewController: UISearchBarDelegate {

  func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
    self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(dismissSearch))
  }

  func searchBarShouldEndEditing(_ searchBar: UISearchBar) -> Bool {
    self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "settings-button"), style: .plain, target: self, action: #selector(settings))
    return true
  }

  func searchBarTextDidChange(searchText: String) {
    self.updateFilter(searchText: searchText)
    self.reloadMap()

    if (self.placesFiltered.count > 0) {
      let mapPlace = self.placesFiltered.first
      self.currentPlace = mapPlace
    }

    self.collectionView.contentOffset = CGPoint.zero
    self.collectionView.reloadData()
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

class MapViewController: UIViewController, FilterViewControllerDelegate, CategoryViewControllerDelegate {
  func categoriesUpdated(_ viewController: CategoryViewController, categories: [Category]) {
    viewController.dismiss(animated: true, completion: nil)

    print(categories)

    self.categories = categories

    let center = mapView.region.center
    fetchMapData(coordinate: center)

    var title = "▼ All Restaurants"
    let count = self.categories.count
    if count > 1 {
      title = String(format: "▼ %i Categories", count)
    } else if let category = self.categories.first {
      title = String(format: "▼ %@", category.name)
    }
    titleButton?.setTitle(title, for: .normal)

  }

  func filterUpdated(_ viewController: FilterViewController, ratings: [Int], prices: [Int]) {
    viewController.dismiss(animated: true, completion: nil)

    print(ratings)
    print(prices)

    self.ratings = ratings
    self.prices = prices

    let center = mapView.region.center
    fetchMapData(coordinate: center)
  }



  var placesFiltered = [MapPlace]()
  {
    didSet
    {
      var annotations:[MKAnnotation] = []
      for (index, place) in placesFiltered.enumerated() {
        if let annotation = place.annotation {
          annotation.index = index
          annotations.append(annotation)
        }
      }
      self.annotations = annotations
    }
  }

  var places:[MapPlace] = [MapPlace]()
  {
    didSet
    {
      self.updateFilter(searchText: self.searchBar.text)
    }
  }

  func updateFilter(searchText: String?) {
    if let searchText = searchText, searchText.count > 0{
      placesFiltered = self.places.filter {
        if let title = $0.place.name?.lowercased() {
          if title.contains(searchText.lowercased()) {
            return true
          }
        }
        return false
      }
    } else {
      placesFiltered = self.places
    }
  }

  let padding = CGFloat(45)
  let spacing = CGFloat(0)
  let env: Env
  let dataStore = PlaceDataStore()
  let locationManager = LocationManager.shared
  var categoryFilter : CategoryViewController!
  var filter : FilterViewController!
  var ratings = [Int]()
  var prices = [Int]()
  var categories = [Category]()

  private var _currentPlace:MapPlace? {
    didSet {
      NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(centerToCurrentPlace), object: nil)
      self.perform(#selector(centerToCurrentPlace), with: nil, afterDelay: 0.5)
    }
  }

  var currentPlace:MapPlace? {
    set {
      if let annotation = currentPlace?.annotation, let view = mapView.view(for: annotation) as? ABAnnotationView {
        view.isSelected = false
      }
      if let annotation = newValue?.annotation, let view = mapView.view(for: annotation) as? ABAnnotationView {
        view.isSelected = true
      }
      _currentPlace = newValue
    }
    get {
     return _currentPlace
    }
  }

  var initalDataFetched = false

  class MapPlace : NSObject {
    var place: Place
    var annotation : ABPointAnnotation?

    init(place: Place) {
      self.place = place
      self.annotation = ABPointAnnotation(place: place)
    }

  }

  var lastCoordinate: CLLocationCoordinate2D? {
    return locationManager.latestCoordinate
  }

  @IBOutlet weak var collectionView:UICollectionView!
  @IBOutlet weak var mapView:MKMapView!
  @IBOutlet weak var locationButton:UIButton!
  @IBOutlet weak var topBar: UIToolbar!

  lazy var searchBar: UISearchBar! = {
    let searchBar = UISearchBar(frame: CGRect(x: 0, y: 0, width: 600, height: 60))
    searchBar.placeholder = "Search All Restaurants"
    searchBar.delegate = self
    return searchBar
  }()

  private let analytics: AnalyticsManager
  @IBOutlet weak var settingsButton:UIButton!

  init(analytics: AnalyticsManager) {
    env = Env()
    self.analytics = analytics
    super.init(nibName: nil, bundle: nil)
    locationManager.authorizationDelegate = self
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    let url: URL? = AppDelegate.shared().lastViewedURL
    // Currently we send the map viewed data regardless of whether we have the coordinates yet or not

    let state = UIApplication.shared.applicationState
    if state != .background {
      self.analytics.log(.mapViewed(currentLocation: self.lastCoordinate, source: url))
    }

    AppDelegate.shared().lastViewedURL = nil
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

  @IBAction func dismissSearch(sender: UIButton) {
    self.searchBar.resignFirstResponder()
  }


  func initialMapDataFetch(coordinate: CLLocationCoordinate2D) {
    if initalDataFetched {
      return
    }
    initalDataFetched = true
    centerMap(coordinate)
    fetchMapData(coordinate: coordinate)
  }

  @IBAction func showCategories() {
    clearSearch()
    let navigationController = UINavigationController(rootViewController: self.categoryFilter)
    self.navigationController?.present(navigationController, animated: true, completion: nil)
  }

  var titleButton : UIButton?

  override func viewDidLoad() {
    super.viewDidLoad()

    topBar.barTintColor =  UIColor.beige()
    topBar.tintColor =  UIColor.offRed()

    self.categoryFilter = CategoryViewController(analytics: self.analytics)
    self.categoryFilter?.categoryFilterDelegate = self

    self.filter = FilterViewController()
    self.filter?.filterDelegate = self

    let layout = UPCarouselFlowLayout()
    layout.scrollDirection = .horizontal
    let width = collectionView.frame.size.width - 2*padding
    layout.spacingMode = .fixed(spacing: 0)
    layout.sideItemScale = 1.0
    layout.itemSize = CGSize(width: width, height: collectionView.frame.size.height)

    self.collectionView.collectionViewLayout = layout

    // Register cell classes

    let nib = UINib(nibName: "PlaceCell", bundle:nil)
    self.collectionView.register(nib, forCellWithReuseIdentifier: reuseIdentifier)

//    self.title = env.appName
    if let fontStyle = UIFont(name: "WorkSans-Medium", size: 18) {
      navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: fontStyle]
    }
    self.style()
    let coordinate = CLLocationCoordinate2D(latitude: 39.9526, longitude: -75.1652)
    centerMap(coordinate)
    fetchMapData(coordinate: coordinate)

//    self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Filter", style: .plain, target: self, action: #selector(showFilter))

  }

  @IBAction func showFilter() {
    clearSearch()
    let navigationController = UINavigationController(rootViewController: self.filter)
    self.navigationController?.present(navigationController, animated: true, completion: nil)
  }

  @IBAction func centerCurrentLocation() {
    if self.locationManager.authorized {
      let showsUserLocation = !locationButton.isSelected
      locationButton.isSelected = showsUserLocation
      self.mapView.showsUserLocation = showsUserLocation

      if showsUserLocation && lastCoordinate != nil {
        mapView.setCenter(lastCoordinate!, animated: true)
      }
    } else {
      self.locationManager.enableBasicLocationServices()
    }
  }

  var annotations:[MKAnnotation] = [MKAnnotation]()
  {
    didSet
    {
      self.reloadMap()
    }
  }

  func reloadMap() {
    self.mapView.removeAnnotations(self.mapView.annotations)
    self.mapView.addAnnotations(self.annotations)
  }

  func fetchMapData(coordinate:CLLocationCoordinate2D, completionBlock: (() -> (Void))? = nil) {
    dataStore.retrievePlaces(coordinate: coordinate, prices: self.prices, ratings: self.ratings, categories: self.categories, limit: 1000) { (success, data, count) in
      var places = [MapPlace]()
      for place in data {
        places.append(MapPlace(place: place))
      }
      self.places = places

      if (self.placesFiltered.count > 0) {
        let mapPlace = self.placesFiltered.first
        self.currentPlace = mapPlace
      }

      self.collectionView.contentOffset = CGPoint.zero
      self.collectionView.reloadData()
      completionBlock?()
    }
  }


  private var collectionViewFlowLayout: UICollectionViewFlowLayout {
    return self.collectionView.collectionViewLayout as! UICollectionViewFlowLayout
  }

  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    configureCollectionViewLayoutItemSize()
  }

  private func configureCollectionViewLayoutItemSize() {
    collectionViewFlowLayout.sectionInset = UIEdgeInsets(top: 0, left: padding, bottom: 0, right: padding)
    let width = collectionView.frame.size.width - 2*padding
    collectionViewFlowLayout.itemSize = CGSize(width: width, height: collectionView.frame.size.height)
  }

  private func indexOfMajorCell() -> Int {
    let itemWidth = collectionViewFlowLayout.itemSize.width
    let offset = collectionViewFlowLayout.collectionView!.contentOffset.x
    let proportionalOffset = offset / itemWidth
    let index = Int(round(proportionalOffset))
    let numberOfItems = collectionView.numberOfItems(inSection: 0)
    let safeIndex = max(0, min(numberOfItems - 1, index))
    return safeIndex
  }

  func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
    var mapPlace:MapPlace
    let snapToIndex = indexOfMajorCell()
    mapPlace = self.placesFiltered[snapToIndex]
    let place = mapPlace.place

    analytics.log(.swipesCarousel(post: place.post, currentLocation: self.lastCoordinate))
    self.currentPlace = mapPlace
  }

  func scrollToItem(at indexPath:IndexPath) {
    collectionViewFlowLayout.collectionView!.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
  }

  @objc func centerToCurrentPlace() {
    DispatchQueue.main.async {
      if let coordinate = self.currentPlace?.place.coordinate() {
        self.centerMap(coordinate)
      }
    }
  }

  func centerMap(_ center: CLLocationCoordinate2D, span: MKCoordinateSpan? = MKCoordinateSpan(latitudeDelta: 0.04, longitudeDelta: 0.04)) {
    let region:MKCoordinateRegion
    if let span = span {
      region = MKCoordinateRegion(center: center, span: span)
    } else {
      region = MKCoordinateRegion(center: center, span: self.mapView.region.span)
    }
    self.mapView.setRegion(region, animated: true)
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(keyboardWillShowNotification(notification:)),
      name: UIResponder.keyboardWillShowNotification, object: nil)
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(self.keyboardWillHideNotification(notification:)),
      name: UIResponder.keyboardWillHideNotification, object: nil)
  }

  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
    NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
  }

  // MARK: - Notifications

  @objc func keyboardWillShowNotification(notification: NSNotification) {
    updateBottomLayoutConstraintWithNotification(notification: notification)
  }

  @objc func keyboardWillHideNotification(notification: NSNotification) {
    updateBottomLayoutConstraintWithNotification(notification: notification)
  }


  // MARK: - Private
  @IBOutlet weak var bottomLayoutConstraint: NSLayoutConstraint!

  func updateBottomLayoutConstraintWithNotification(notification: NSNotification) {
    let userInfo = notification.userInfo!

    let keyboardEndFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
    let convertedKeyboardEndFrame = view.convert(keyboardEndFrame, from: self.view.window)
    bottomLayoutConstraint.constant = view.bounds.maxY - convertedKeyboardEndFrame.minY
    self.view.layoutIfNeeded()
  }

}
