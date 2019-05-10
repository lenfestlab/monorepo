import UIKit
import MapKit
import UserNotifications
import UPCarouselFlowLayout
import CoreMotion
import RxSwift
import RxCocoa

extension MKMapView {
  func center(_ center: CLLocationCoordinate2D,
                 span: MKCoordinateSpan = MKCoordinateSpan(latitudeDelta: 0.04, longitudeDelta: 0.04)) {
    let region:MKCoordinateRegion = MKCoordinateRegion(center: center, span: span)
    self.setRegion(region, animated: true)
  }
}

extension UICollectionView {

  var collectionViewFlowLayout: UICollectionViewFlowLayout {
    return self.collectionViewLayout as! UICollectionViewFlowLayout
  }

  func indexOfMajorCell() -> Int {
    let itemWidth = self.collectionViewFlowLayout.itemSize.width
    let offset = self.collectionViewFlowLayout.collectionView!.contentOffset.x
    let proportionalOffset = offset / itemWidth
    let index = Int(round(proportionalOffset))
    let numberOfItems = self.numberOfItems(inSection: 0)
    let safeIndex = max(0, min(numberOfItems - 1, index))
    return safeIndex
  }

}

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
    cell.setPlace(context: context, place: place, index: indexPath.row, showIndex: self.showIndex)
    return cell
  }
}

extension MapViewController: UICollectionViewDelegate {

  func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
    if collectionView.indexOfMajorCell() == indexPath.row {
      let mapPlace:MapPlace = self.placeStore.placesFiltered[indexPath.row]
      let place:Place = mapPlace.place
      analytics.log(.tapsOnCard(place: place, controllerIdentifierKey: self.controllerIdentifierKey))
      openPlace(place)
    } else {
      scrollToItem(at: indexPath)
      let mapPlace:MapPlace = self.placeStore.placesFiltered[indexPath.row]
      self.currentPlace = mapPlace
    }
    return true
  }

  func openPlace(_ place: Place) {
    let detailViewController =
      DetailViewController(
        context: context,
        place: place)
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
    analytics.log(.tapsOnPin(place: place))
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

  var controllerIdentifierKey = "unknown"
  let padding = placeCellPadding
  let env: Env
  let locationManager = LocationManager.shared
  let placeStore : PlaceStore!
  var topPadding = CGFloat(64)

  var showIndex = false {
    didSet {
      self.collectionView?.reloadData()
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
      if let annotation = currentPlace?.annotation, let view = mapView?.view(for: annotation) as? ABAnnotationView {
        view.isSelected = false
      }
      if let annotation = newValue?.annotation, let view = mapView?.view(for: annotation) as? ABAnnotationView {
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

  @IBOutlet weak var collectionView:UICollectionView?
  @IBOutlet weak var mapView:MKMapView?
  @IBOutlet weak var locationButton:UIButton!

  private let context: Context
  private let analytics: AnalyticsManager
  @IBOutlet weak var settingsButton:UIButton!

  init(context: Context, placeStore: PlaceStore) {
    env = Env()
    self.context = context
    self.analytics = context.analytics
    self.placeStore = placeStore
    super.init(nibName: nil, bundle: nil)
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  @objc func updateLocationButton() {
    self.locationButton.isSelected = self.locationManager.authorized()
    self.mapView?.showsUserLocation = self.locationManager.authorized()
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    updateLocationButton()
    AppDelegate.shared().lastViewedURL = nil
  }

  func fetchedMapData() {
    if (self.placeStore.placesFiltered.count > 0) {
      let mapPlace = self.placeStore.placesFiltered.first
      self.currentPlace = mapPlace
    }

    if let view = self.collectionView {
      view.contentOffset = CGPoint.zero
      view.reloadData()
    }

  }

  override func viewDidLoad() {
    super.viewDidLoad()

    NotificationCenter.default.addObserver(self, selector: #selector(updateLocationButton), name: .locationAuthorizationUpdated, object: nil)

    if let view = self.collectionView {
      let layout = UPCarouselFlowLayout()
      layout.scrollDirection = .horizontal
      let width = view.frame.size.width - 2*padding
      layout.spacingMode = .fixed(spacing: 0)
      layout.sideItemScale = 1.0
      layout.itemSize = CGSize(width: width, height: view.frame.size.height)
      view.collectionViewLayout = layout

      // Register cell classes
      let nib = UINib(nibName: "PlaceCell", bundle:nil)
      view.register(nib, forCellWithReuseIdentifier: reuseIdentifier)
    }



    self.navigationController?.styleController()

//    self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Filter", style: .plain, target: self, action: #selector(showFilter))

    self.mapView?.center(locationManager.defaultCoordinate)
    self.reloadMap()
  }

  @IBAction func centerCurrentLocation() {
    if self.locationManager.authorizationStatus == .denied {

      let alertController = UIAlertController(
        title: "Want to Enable Location?",
        message: "This app uses your location to recommend restaurants around you.\nPlease select \"Always\" in Settings.",
        preferredStyle: .alert)

      let cancel = UIAlertAction(title: "Nevermind", style: .default) { (action:UIAlertAction) in
      }
      alertController.addAction(cancel)

      let action1 = UIAlertAction(title: "Enable", style: .cancel) { (action:UIAlertAction) in
        if let url = URL(string: UIApplication.openSettingsURLString) {
          // If general location settings are enabled then open location settings for the app
          UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
      }
      alertController.addAction(action1)

      self.present(alertController, animated: true, completion: nil)

      return
    }
    if self.locationManager.authorizationStatus == .notDetermined {
      self.locationManager.enableBasicLocationServices()
      return
    }

    if self.locationManager.authorized() {
      let showsUserLocation = locationButton.isSelected
      if showsUserLocation, let map = self.mapView {
        map.setCenter(map.userLocation.coordinate, animated: true)
      }
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
    if let map = self.mapView {
      map.removeAnnotations(map.annotations)
      map.addAnnotations(self.annotations)
    }
  }

  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    configureCollectionViewLayoutItemSize()
  }

  private func configureCollectionViewLayoutItemSize() {
    if let view = collectionView {
      view.collectionViewFlowLayout.sectionInset = UIEdgeInsets(top: 0, left: padding, bottom: 0, right: padding)
      let width = view.frame.size.width - 2*padding
      view.collectionViewFlowLayout.itemSize = CGSize(width: width, height: view.frame.size.height)
    }
  }

  func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
    var mapPlace:MapPlace
    let snapToIndex = self.collectionView?.indexOfMajorCell() ?? 0
    mapPlace = self.placeStore.placesFiltered[snapToIndex]
    let place = mapPlace.place

    analytics.log(.swipesCarousel(place: place, currentLocation: self.lastCoordinate))
    self.currentPlace = mapPlace
  }

  func scrollToItem(at indexPath:IndexPath) {
    self.collectionView?.collectionViewFlowLayout.collectionView!.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
  }

  @objc func centerToCurrentPlaceIfNotVisible() {
    guard let map = self.mapView else {
      return
    }
    DispatchQueue.main.async {
      if let coordinate = self.currentPlace?.place.coordinate() {
        let visibleMapRect = map.visibleMapRect
        let scale = visibleMapRect.width / Double(map.frame.width)
        let downBy = 250 + self.topPadding
        let x = visibleMapRect.origin.x + 0 * scale
        let y = visibleMapRect.origin.y + Double(downBy) * scale
        let pixelWidth = self.locationButton.frame.minX
        let width = scale * Double(pixelWidth)
        let collectionViewFrameHeight = self.collectionView?.frame.height ?? 0
        let pixelHeight = map.frame.height - collectionViewFrameHeight - downBy - self.view.safeAreaInsets.bottom
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
          self.mapView?.center(coordinate, span: map.region.span)
        }
      }
    }
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
