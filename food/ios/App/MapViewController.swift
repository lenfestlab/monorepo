import UIKit
import MapKit
import UserNotifications
import UPCarouselFlowLayout
import CoreMotion
import RxSwift
import RxCocoa
import NSObject_Rx

private let reuseIdentifier = "PlaceCell"
fileprivate let sectionInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)

class MapViewController: UIViewController,
  LocationManagerAuthorizationDelegate,
  UICollectionViewDelegate,
  UICollectionViewDataSource,
  UIGestureRecognizerDelegate,
  MKMapViewDelegate {

  let padding = CGFloat(45)
  let spacing = CGFloat(0)
  let env: Env
  let motionManager = MotionManager.shared
  let dataStore = PlaceDataStore()
  let locationManager = LocationManager.shared
  var places:[Place] = []
  var currentPlace:Place?
  var initalDataFetched = false


  var lastCoordinate: CLLocationCoordinate2D? {
    return locationManager.latestCoordinate
  }

  @IBOutlet weak var collectionView:UICollectionView!
  @IBOutlet weak var mapView:MKMapView!
  @IBOutlet weak var locationButton:UIButton!

  private let analytics: AnalyticsManager
  @IBOutlet weak var settingsButton:UIButton!
  @IBOutlet weak var activitylabel:UILabel!

  init(analytics: AnalyticsManager) {
    env = Env()
    self.analytics = analytics
    super.init(nibName: nil, bundle: nil)
    locationManager.authorizationDelegate = self
    navigationItem.hidesBackButton = true
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    let mainController = self.navigationController as! MainController
    let url: URL? = mainController.lastViewedURL
    // Currently we send the map viewed data regardless of whether we have the coordinates yet or not

    let state = UIApplication.shared.applicationState
    if state != .background {
      self.analytics.log(.mapViewed(currentLocation: self.lastCoordinate, source: url))
    }

    mainController.lastViewedURL = nil
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

  func initialMapDataFetch(coordinate: CLLocationCoordinate2D) {
    if initalDataFetched {
      return
    }
    initalDataFetched = true
    centerMap(coordinate, span: MKCoordinateSpanMake(0.04, 0.04))
    fetchMapData(coordinate: coordinate)
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    let panRec = UIPanGestureRecognizer(target: self, action: #selector(didDragMap(gestureRecognizer:)))
    panRec.delegate = self
    self.mapView.addGestureRecognizer(panRec)

    if MotionManager.isActivityAvailable() {
      let mm = motionManager
      mm.startActivityUpdates { [unowned self] activity in

        let messages: [String] = [
          "build: \(self.env.buildVersion)",
          activity.formattedDescription,
          "isDriving: \(mm.isDriving)",
          "stoppedDrivingAt: \(mm.stoppedDrivingAtFormatted)",
          "hasBeenDriving [< \(mm.drivingThreshold) min ago]: \(mm.hasBeenDriving)",
          "=> skipNotifications: \(mm.skipNotifications)"
        ]

        self.activitylabel.text = messages.joined(separator: "\n")
      }
    }
    self.activitylabel.isHidden = !env.isPreProduction

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

    self.title = env.appName
    if let fontStyle = UIFont(name: "WorkSans-Medium", size: 18) {
      navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.font: fontStyle]
    }
    navigationController?.navigationBar.barTintColor =  UIColor.beige()
    navigationController?.navigationBar.tintColor =  UIColor.offRed()
    navigationController?.navigationBar.isTranslucent = false

    let coordinate = CLLocationCoordinate2D(latitude: 39.9526, longitude: -75.1652)
    centerMap(coordinate, span: MKCoordinateSpanMake(0.04, 0.04))
    fetchMapData(coordinate: coordinate)

    self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "settings-button"), style: .plain, target: self, action: #selector(settings))

    // simulate local notification
    if Env().isPreProduction {
      let button =
        UIBarButtonItem(
          title: "sim",
          style: .plain,
          target: nil, action: nil)
      self.navigationItem.leftBarButtonItem = button
      button.rx.tap
        .asDriver()
        .drive(onNext: { [unowned self] _ in
          guard let place = self.places.randomElement() else {
            print("MIA: place / region")
            return
          }
          self.locationManager.sendNotificationForPlace(place)
        })
        .disposed(by: self.rx.disposeBag)
    }

  }

  func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
    let coordinate = userLocation.coordinate
    mapView.setCenter(coordinate, animated: true)
    self.locationManager.latestLocation = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
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

  func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
    if annotation is MKUserLocation {
      //return nil so map view draws "blue dot" for standard user location
      return nil
    }

    let reuseId = "pin"

    let  pinView = MKAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
    pinView.tag = (annotation as! ABPointAnnotation).index

    if annotation.title == currentPlace?.title {
      pinView.image = UIImage(named: "selected-pin")
    } else {
      pinView.image = UIImage(named: "pin")
    }

    pinView.accessibilityLabel = "hello"
    let btn = UIButton(type: .detailDisclosure)
    pinView.rightCalloutAccessoryView = btn
    return pinView
  }

  func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
    let indexPath = IndexPath(row: view.tag, section: 0)
    let place:Place = self.places[indexPath.row]
    analytics.log(.tapsOnPin(post: place.post, currentLocation: self.lastCoordinate))
    scrollToItem(at: indexPath)
    updateCurrentPlace(place: place)
  }

  func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {

  }

  func reloadMap() {
    var annotations:[MKAnnotation] = []
    for (index, place) in self.places.enumerated() {
      let annotation = ABPointAnnotation(place: place)
      annotation.index = index
      annotations.append(annotation)
    }
    self.mapView.removeAnnotations(self.mapView.annotations)
    self.mapView.addAnnotations(annotations)
  }

  func fetchMapData(coordinate:CLLocationCoordinate2D, overrideCurrentPlace: Bool = true) {
    let latitude = coordinate.latitude
    let longitude = coordinate.longitude

    dataStore.retrievePlaces(latitude: latitude, longitude: longitude, limit: 1000) { (success, data, count) in
      self.places = data

      if overrideCurrentPlace && (self.places.count > 0) {
        self.currentPlace = self.places.first
        self.centerMap((self.currentPlace?.coordinate())!)
      }

      self.reloadMap()
      self.collectionView.reloadData()
    }
  }


  // MARK: - Location manager delegate

  func locationUpdated(_ locationManager: LocationManager, location: CLLocation) {
    initialMapDataFetch(coordinate: location.coordinate)
  }

  func authorized(_ locationManager: LocationManager, status: CLAuthorizationStatus) {
    print("locationManagerDelegate authorized")
    centerCurrentLocation()
  }

  func notAuthorized(_ locationManager: LocationManager, status: CLAuthorizationStatus) {
    print("locationManagerDelegate notAuthorized")
  }


  // MARK: UICollectionViewDataSource

  func numberOfSections(in collectionView: UICollectionView) -> Int {
    return 1
  }

  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return places.count
  }

  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! PlaceCell

    // Configure the cell
    let place:Place = self.places[indexPath.row]
    cell.setPlace(place: place)
    return cell
  }

  func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
    if indexOfMajorCell() == indexPath.row {
      let place:Place = self.places[indexPath.row]
      analytics.log(.tapsOnViewArticle(post: place.post, currentLocation: self.lastCoordinate))
      let mainVC = self.navigationController as! MainController
      mainVC.openInSafari(url: place.post.link)
    } else {
      scrollToItem(at: indexPath)
      let place:Place = self.places[indexPath.row]
      updateCurrentPlace(place: place)
    }
    return true
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
    var place:Place
    let snapToIndex = indexOfMajorCell()
    place = self.places[snapToIndex]
    analytics.log(.swipesCarousel(post: place.post, currentLocation: self.lastCoordinate))
    updateCurrentPlace(place: place)
  }

  func updateCurrentPlace(place: Place) {
    let coordinate = place.coordinate()
    self.currentPlace = place
    self.reloadMap()
    self.centerMap(coordinate)
  }

  func scrollToItem(at indexPath:IndexPath) {
    collectionViewFlowLayout.collectionView!.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
  }

  func centerMap(_ center: CLLocationCoordinate2D, span: MKCoordinateSpan? = nil) {
    let region:MKCoordinateRegion
    if span == nil {
      region = MKCoordinateRegion(center: center, span: self.mapView.region.span)
    } else {
      region = MKCoordinateRegion(center: center, span: span!)
    }
    self.mapView.setRegion(region, animated: true)
  }

  func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
    return true
  }

  @objc func didDragMap(gestureRecognizer: UIGestureRecognizer) {
    guard !mapView.isUserLocationVisible else { return }
    if (gestureRecognizer.state == .ended){
      let center = mapView.region.center
      fetchMapData(coordinate: center, overrideCurrentPlace: false)
    }
  }


}
