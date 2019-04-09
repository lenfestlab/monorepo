import UIKit
import MapKit
import UserNotifications
import UPCarouselFlowLayout
import CoreMotion
import RxSwift
import RxCocoa

private let mapPinIdentifier = "pin"

fileprivate let sectionInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)

extension MapViewController: UICollectionViewDataSource {

  func numberOfSections(in collectionView: UICollectionView) -> Int {
    return 1
  }

  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return self.placeStore.placesFiltered.count
  }

  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! PlaceCell

    // Configure the cell
    let mapPlace:MapPlace = self.placeStore.placesFiltered[indexPath.row]
    let place = mapPlace.place
    cell.setPlace(place: place, index: indexPath.row, showIndex: self.showIndex)
    return cell
  }
}

extension MapViewController: UICollectionViewDelegate {

  func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
    if indexOfMajorCell() == indexPath.row {
      let mapPlace:MapPlace = self.placeStore.placesFiltered[indexPath.row]
      let place:Place = mapPlace.place
      analytics.log(.tapsOnViewArticle(post: place.post, currentLocation: self.lastCoordinate))
      openPlace(place)
    } else {
      scrollToItem(at: indexPath)
      let mapPlace:MapPlace = self.placeStore.placesFiltered[indexPath.row]
      self.currentPlace = mapPlace
    }
    return true
  }

  func openPlace(_ place: Place) {
    let detailViewController = DetailViewController(place: place)
    self.navigationController?.pushViewController(detailViewController, animated: true)
  }
}

extension MapViewController : MKMapViewDelegate {

  func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
    let renderer = MKPolygonRenderer(polygon: overlay as! MKPolygon)
    renderer.fillColor = UIColor.black.withAlphaComponent(0.5)
    renderer.strokeColor = UIColor.red
    renderer.lineWidth = 10
    return renderer
  }

  func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
    let coordinate = userLocation.coordinate
    self.locationManager.latestLocation = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
  }

  func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
    if annotation is MKUserLocation {
      //return nil so map view draws "blue dot" for standard user location
      return nil
    }

    let index = (annotation as! ABPointAnnotation).index

    let  pinView = ABAnnotationView(annotation: annotation, reuseIdentifier: mapPinIdentifier)
    pinView.tag = index
    pinView.isSelected = (annotation.title == currentPlace?.place.name)
    pinView.showsIndex = self.showIndex
    pinView.setIndex(index)
    let btn = UIButton(type: .detailDisclosure)
    pinView.rightCalloutAccessoryView = btn

    return pinView
  }

  func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
    let indexPath = IndexPath(row: view.tag, section: 0)
    let mapPlace:MapPlace = self.placeStore.placesFiltered[indexPath.row]
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

class MapViewController: UIViewController {

  let padding = placeCellPadding
  let env: Env
  let locationManager = LocationManager.shared
  let placeStore : PlaceStore!
  var topPadding = CGFloat(64)

  var showIndex = false {
    didSet {
      self.collectionView.reloadData()
      self.reloadMap()
    }
  }

  func updateAnnotations() {
    var annotations:[MKAnnotation] = []
    for (index, place) in self.placeStore.placesFiltered.enumerated() {
      if let annotation = place.annotation {
        annotation.index = index
        annotations.append(annotation)
      }
    }
    self.annotations = annotations
  }

  private var _currentPlace:MapPlace? {
    didSet {
      NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(centerToCurrentPlaceIfNotVisible), object: nil)
      self.perform(#selector(centerToCurrentPlaceIfNotVisible), with: nil, afterDelay: 0.5)
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

  var lastCoordinate: CLLocationCoordinate2D? {
    return locationManager.latestCoordinate
  }

  @IBOutlet weak var collectionView:UICollectionView!
  @IBOutlet weak var mapView:MKMapView!
  @IBOutlet weak var locationButton:UIButton!

  private let analytics: AnalyticsManager
  @IBOutlet weak var settingsButton:UIButton!

  init(analytics: AnalyticsManager, placeStore: PlaceStore) {
    env = Env()
    self.analytics = analytics
    self.placeStore = placeStore
    super.init(nibName: nil, bundle: nil)
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

  func fetchedMapData() {
    if (self.placeStore.placesFiltered.count > 0) {
      let mapPlace = self.placeStore.placesFiltered.first
      self.currentPlace = mapPlace
    }

    self.collectionView.contentOffset = CGPoint.zero
    self.collectionView.reloadData()
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    self.collectionView.delegate = self
    self.collectionView.dataSource = self

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

    self.navigationController?.styleController()

//    self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Filter", style: .plain, target: self, action: #selector(showFilter))

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
    mapPlace = self.placeStore.placesFiltered[snapToIndex]
    let place = mapPlace.place

    analytics.log(.swipesCarousel(post: place.post, currentLocation: self.lastCoordinate))
    self.currentPlace = mapPlace
  }

  func scrollToItem(at indexPath:IndexPath) {
    collectionViewFlowLayout.collectionView!.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
  }

  @objc func centerToCurrentPlaceIfNotVisible() {
    DispatchQueue.main.async {
      if let coordinate = self.currentPlace?.place.coordinate() {
        let visibleMapRect = self.mapView.visibleMapRect
        let scale = visibleMapRect.width / Double(self.mapView.frame.width)
        let downBy = 250 + self.topPadding
        let x = visibleMapRect.origin.x + 0 * scale
        let y = visibleMapRect.origin.y + Double(downBy) * scale
        let pixelWidth = self.locationButton.frame.minX
        let width = scale * Double(pixelWidth)
        let pixelHeight = self.mapView.frame.height - self.collectionView.frame.height - downBy - self.view.safeAreaInsets.bottom
        let height = scale * Double(pixelHeight)
        let remainderRect = MKMapRect(x: x, y: y, width: width, height: height)

//        var remPoints = [MKMapPoint]()
//        remPoints.append(remainderRect.origin) // topLeft
//        remPoints.append(MKMapPoint(x: remainderRect.origin.x + remainderRect.size.width, y: remainderRect.origin.y))
//        remPoints.append(MKMapPoint(x: remainderRect.origin.x + remainderRect.size.width, y: remainderRect.origin.y + remainderRect.size.height))
//        remPoints.append(MKMapPoint(x: remainderRect.origin.x, y: remainderRect.origin.y + remainderRect.size.height)) // topRight
//        let remPoly = MKPolygon.init(points: remPoints, count: 4)
//        self.mapView.addOverlay(remPoly)

        if(!remainderRect.contains(MKMapPoint(coordinate))){
          self.centerMap(coordinate, span: self.mapView.region.span)
        }
      }
    }
  }

  func centerMap(_ center: CLLocationCoordinate2D,
                 span: MKCoordinateSpan = MKCoordinateSpan(latitudeDelta: 0.04, longitudeDelta: 0.04)) {
    let region:MKCoordinateRegion = MKCoordinateRegion(center: center, span: span)
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
    bottomLayoutConstraint.constant = max(0, view.bounds.maxY - convertedKeyboardEndFrame.minY - view.safeAreaInsets.bottom)
    self.view.layoutIfNeeded()
  }

}
