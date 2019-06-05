import UIKit
import UserNotifications
import UPCarouselFlowLayout
import CoreMotion
import RxSwift
import RxCocoa
import MapKit

fileprivate let sectionInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)

extension MapViewController: UIGestureRecognizerDelegate {

  func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
    return true
  }

}

class MapViewController: UIViewController, Contextual {

  var controllerIdentifierKey = "unknown"
  let padding = placeCellPadding
  let placeStore : PlaceStore!
  var topPadding = CGFloat(64)

  var showIndex = false {
    didSet {
      self.collectionView?.reloadData()
      self.reloadMap()
    }
  }

  func updateAnnotations() {
    var annotations: [MKAnnotation] = []
    for (index, place) in mapPlaces.enumerated() {
      if let annotation = place.annotation {
        annotation.index = index
        annotations.append(annotation)
      }
    }
    self.annotations = annotations
  }

  private var _currentPlace: MapPlace? {
    didSet {
      NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(centerToCurrentPlaceIfNotVisible), object: nil)
      self.perform(#selector(centerToCurrentPlaceIfNotVisible), with: nil, afterDelay: 0.0)
    }
  }

  var currentPlace: MapPlace? {
    set {
      for annotation in annotations {
        if
          let view = mapView?.view(for: annotation) as? ABAnnotationView,
          view.isSelected {
          view.isSelected = false
        }
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

  @IBOutlet weak var collectionView:UICollectionView!
  @IBOutlet weak var mapView:MKMapView?
  @IBOutlet weak var locationButton:UIButton!

  var context: Context
  @IBOutlet weak var settingsButton:UIButton!

  init(context: Context, placeStore: PlaceStore) {
    self.context = context
    self.placeStore = placeStore
    super.init(nibName: nil, bundle: nil)
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  @objc func updateLocationButton() {
    self.locationButton.isSelected = self.locationManager.authorized()
    mapView?.showsUserLocation = self.locationManager.authorized()
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    updateLocationButton()
    AppDelegate.shared().lastViewedURL = nil
  }

  var mapPlaces: [MapPlace] = []

  let mapPlacesChangeset$$ = ReplaySubject<PlacesChangeset>.create(bufferSize: 4)
  lazy var mapPlacesChangeset$ = { () -> Observable<PlacesChangeset> in
    // NOTE: fetchedData can be called before collectionView is ready,
    // so we buffer changesets until the view is ready for data.
    let collectionViewReady$ =
      rx.methodInvoked(#selector(UIViewController.viewDidAppear(_:)))
        .mapTo(true)
        .startWith(false)
        .distinctUntilChanged()
        .share()
    return mapPlacesChangeset$$
      .pausableBuffered(collectionViewReady$, limit: nil, flushOnCompleted: true, flushOnError: true)
      .distinctUntilChanged() // skip redundant empty changeset events
      .share()
  }()

  func fetchedData(_ changeset: PlacesChangeset, _ _: PlacesChangesetClosure) {
    mapPlacesChangeset$$.onNext(changeset)
  }


  override func viewDidLoad() {
    super.viewDidLoad()

    detailAnimating$
      .subscribe(onNext: { [weak self] isAnimating in
        guard let `self` = self else { return print("MIA: self") }
        let isEnabled = !isAnimating
        self.collectionView.isUserInteractionEnabled = isEnabled
        self.mapView?.showsUserLocation = (self.locationManager.authorized() && isEnabled)
      })
      .disposed(by: rx.disposeBag)

    NotificationCenter.default.addObserver(self, selector: #selector(updateLocationButton), name: .locationAuthorizationUpdated, object: nil)

    // collectionView layout
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
      view.register(nib, forCellWithReuseIdentifier: PlaceCell.reuseIdentifier)
    }

    // render buffered changesets
    mapPlacesChangeset$
      .subscribe(onNext: { [weak self] changeset in
        guard let view = self?.collectionView else { return }
        view.reload(using: changeset, setData: { [weak self] latestPlaces in
          guard let `self` = self else { return print("MIA: self") }
          let mapPlaces = latestPlaces.map({ MapPlace(place: $0) })
          self.mapPlaces = mapPlaces
          self.updateAnnotations()
          if mapPlaces.isNotEmpty {
            // scale map to encompass 5 nearest places and user's location
            self.scaleMapToEncompassNearestPlaces(latestPlaces)
          }
        })
      })
      .disposed(by: rx.disposeBag)

    self.navigationController?.styleController()
  }

  func scaleMapToEncompassNearestPlaces(_ latestPlaces: [Place], maximumNearestPlaces: Int = 5) {
    guard
      let mapView = self.mapView,
      let firstPlace = latestPlaces.first,
      let firstLocation = firstPlace.location?.nativeLocation
      else {
        self.mapView?.center(self.locationManager.defaultCoordinate)
        return print("MIA: firstPlace") }
    var visibleCoordinates: [CLLocationCoordinate2D] = []
    if let currentLocation = self.locationManager.latestLocation {
      visibleCoordinates.append(currentLocation.coordinate)
    }
    let sortedPlaces =
      latestPlaces.sorted(by: { (p1,p2) -> Bool in
        guard
          let d1 = p1.distanceFrom(firstLocation),
          let d2 = p2.distanceFrom(firstLocation)
          else { return false }
        return d1 < d2
      })
    let nearestPlaces = sortedPlaces.prefix(maximumNearestPlaces)
    let nearestCoordinates = nearestPlaces.compactMap({ $0.coordinate })
    visibleCoordinates.append(contentsOf: nearestCoordinates)
    let rect = self.rectCovering(visibleCoordinates)
    let carouselHeight = self.collectionView.frame.height
    let filterBarHeight: CGFloat = 34
    let padding: CGFloat = 30
    let edgePadding =
      UIEdgeInsets(
        top: padding + filterBarHeight + 250.0,
        left: padding,
        bottom: padding + carouselHeight,
        right: padding)
    mapView.setVisibleMapRect(rect, edgePadding: edgePadding, animated: false)
    // setting `self.currentPlace` moves the mapview
    // instead, just select/highlight the first annotation
    let firstCoordinate = firstLocation.coordinate
    let firstAnnotation =
      self.annotations.first(where: { annotation -> Bool in
        let coordinate = annotation.coordinate
        let lat = coordinate.latitude; let lng = coordinate.longitude
        return (lat == firstCoordinate.latitude) && (lng == firstCoordinate.longitude)
      })
    guard let annotation = firstAnnotation
      else { return print("MIA: firstAnnotation") }
    if let view = mapView.view(for: annotation) as? ABAnnotationView {
      view.isSelected = true
    }
  }


  // https://stackoverflow.com/a/11862786
  private func rectCovering(_ coordinates: [CLLocationCoordinate2D]) -> MKMapRect {
    var rect: MKMapRect = MKMapRect.null
    for coordinate in coordinates {
      let point = MKMapPoint(coordinate)
      rect = rect.union(MKMapRect(x: point.x, y: point.y, width:0, height:0))
    }
    return rect
  }
  private func regionCovering(_ coordinates: [CLLocationCoordinate2D]) -> MKCoordinateRegion {
    let rect = self.rectCovering(coordinates)
    return MKCoordinateRegion(rect)
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
    let snapToIndex = self.collectionView?.indexOfMajorCell() ?? 0
    let mapPlace = mapPlaces[snapToIndex]
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
      if let coordinate = self.currentPlace?.place.coordinate {
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
