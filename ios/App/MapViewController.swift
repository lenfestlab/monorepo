import UIKit
import MapKit
import SafariServices
import UserNotifications
import UPCarouselFlowLayout

private let reuseIdentifier = "PlaceCell"
fileprivate let sectionInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)

class ABPointAnnotation : MKPointAnnotation {
  var index: Int = 0
}

class MapViewController: UIViewController, LocationManagerDelegate, LocationManagerAuthorizationDelegate, UICollectionViewDelegate, UICollectionViewDataSource, MKMapViewDelegate, NotificationManagerDelegate {

  let padding = CGFloat(45)
  let spacing = CGFloat(0)

  let dataStore = PlaceDataStore()
  let locationManager = LocationManager.shared
  let notificationManager = NotificationManager.shared
  var places:[Place] = []
  var currentPlace:Place?
  var lastViewedURL:URL?

  var lastCoordinate:CLLocationCoordinate2D?

  @IBOutlet weak var collectionView:UICollectionView!
  @IBOutlet weak var mapView:MKMapView!
  @IBOutlet weak var locationButton:UIButton!

  private let analytics: AnalyticsManager

  init(analytics: AnalyticsManager) {
    self.analytics = analytics
    super.init(nibName: nil, bundle: nil)
    notificationManager.delegate = self
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    // Currently we send the map viewed data regardless of whether we have the coordinates yet or not
    self.analytics.log(.mapViewed(currentLocation: self.lastCoordinate, source: self.lastViewedURL))
    self.lastViewedURL = nil
  }

  @IBAction func settings(sender: UIButton) {
    let settingsController = SettingsViewController(analytics: self.analytics)
    navigationController?.pushViewController(settingsController, animated: true)
  }

  override func viewDidLoad() {
    super.viewDidLoad()

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

    self.title = "Here"
    if let fontStyle = UIFont(name: "WorkSans-Medium", size: 18) {
      navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.font: fontStyle]
    }
    navigationController?.navigationBar.barTintColor =  UIColor.beige()
    navigationController?.navigationBar.tintColor =  UIColor.offRed()
    navigationController?.navigationBar.isTranslucent = false

    locationManager.delegate = self
    locationManager.authorizationDelegate = self

    let coordinate = CLLocationCoordinate2D(latitude: 39.9526, longitude: -75.1652)
    self.lastCoordinate = coordinate
    centerMap(coordinate)
    fetchMapData(latitude: coordinate.latitude, longitude: coordinate.longitude)

    self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "settings-button"), style: .plain, target: self, action: #selector(settings))

  }

  func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
    let coordinate = userLocation.coordinate
    if lastCoordinate == nil {
      mapView.setCenter(coordinate, animated: true)
    }
    lastCoordinate = coordinate
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
      let annotation = ABPointAnnotation()
      annotation.coordinate = place.coordinate()
      annotation.title = place.title
      annotation.index = index
      annotations.append(annotation)
    }
    self.mapView.removeAnnotations(self.mapView.annotations)
    self.mapView.addAnnotations(annotations)
  }

  func fetchData(latitude:CLLocationDegrees, longitude:CLLocationDegrees) {
    dataStore.retrievePlaces(latitude: latitude, longitude: longitude, limit: 10) { (success, data, count) in
      if self.locationManager.authorized {
        PlaceManager.shared.trackPlaces(places: data)
      }
    }
  }

  func fetchMapData(latitude:CLLocationDegrees, longitude:CLLocationDegrees) {
    dataStore.retrievePlaces(latitude: latitude, longitude: longitude, limit: 1000) { (success, data, count) in
      self.places = data

      if self.places.count > 0 {
        self.currentPlace = self.places.first
        self.centerMap((self.currentPlace?.coordinate())!)
      }

      self.reloadMap()
      self.collectionView.reloadData()
    }
  }


  // MARK: - Location manager delegate

  func locationUpdated(_ locationManager: LocationManager, coordinate: CLLocationCoordinate2D) {
    lastCoordinate = coordinate
    fetchData(latitude: coordinate.latitude, longitude: coordinate.longitude)
  }

  func regionEngtered(_ locationManager: LocationManager, region: CLCircularRegion) {
    let identifier = region.identifier
    var identifiers = NotificationManager.identifiers()
    let sendAgainAt = identifiers[identifier]
    let now = Date(timeIntervalSinceNow: 0)
    if sendAgainAt != nil && sendAgainAt?.compare(now) == ComparisonResult.orderedDescending  {
      print(identifiers)
    } else if let place = PlaceManager.shared.placeForIdentifier(identifier) {
      identifiers[identifier] = Date(timeIntervalSinceNow: 60 * 60 * 24 * 10000)
      NotificationManager.saveIdentifiers(identifiers)

      PlaceManager.contentForPlace(place: place) { (content) in
        self.analytics.log(.notificationShown(post: place.post, currentLocation: place.coordinate()))
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
        let center = UNUserNotificationCenter.current()
        center.add(request)
      }
    }
  }

  func authorized(_ locationManager: LocationManager, status: CLAuthorizationStatus) {
    centerCurrentLocation()
    locationManager.startMonitoringSignificantLocationChanges()
  }

  func notAuthorized(_ locationManager: LocationManager, status: CLAuthorizationStatus) {
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
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

  func openInSafari(url: URL) {
    self.lastViewedURL = url
    if self.presentedViewController != nil {
      self.presentedViewController?.dismiss(animated: false, completion: {
        let svc = SFSafariViewController(url: url)
        self.present(svc, animated: true)
      })
    } else {
      let svc = SFSafariViewController(url: url)
      present(svc, animated: true)
    }
  }

  func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
    if indexOfMajorCell() == indexPath.row {
      let place:Place = self.places[indexPath.row]
      analytics.log(.tapsOnViewArticle(post: place.post, currentLocation: self.lastCoordinate))
      openInSafari(url: place.post.link)
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

  func centerMap(_ center: CLLocationCoordinate2D) {
    let span = MKCoordinateSpanMake(0.04, 0.04);
    let region = MKCoordinateRegion(center: center, span: span)
    self.mapView.setRegion(region, animated: false)
  }

  func recievedPingMeLater(_ notificationManager: NotificationManager, identifier: String) {
    print(identifier)
    if let place = PlaceManager.shared.placeForIdentifier(identifier) {
      let post = place.post
      analytics.log(.tapsPingMeLaterInNotificationCTA(post: post, currentLocation: self.lastCoordinate))
    }
  }

  func recievedNotification(_ notificationManager: NotificationManager, response: UNNotificationResponse) {
    if response.notification.request.content.categoryIdentifier == "POST_ENTERED" {
      let urlString = response.notification.request.content.userInfo["PLACE_URL"]
      let url = URL(string: urlString as! String)
      if response.actionIdentifier == "CHECKIN_ACTION" {
        // Check-in
      }
      else if let identifier = response.notification.request.content.userInfo["identifier"] as? String {
        if let place = PlaceManager.shared.placeForIdentifier(identifier) {
          analytics.log(.tapsNotificationDefaultTapToClickThrough(post: place.post, currentLocation: self.lastCoordinate))
        }
        openInSafari(url: url!)
      }
    }
  }

}

