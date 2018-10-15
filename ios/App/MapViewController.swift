import UIKit
import MapKit
import SafariServices
import UserNotifications
import CoreMotion

private let reuseIdentifier = "PlaceCell"
fileprivate let sectionInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)

class ABPointAnnotation : MKPointAnnotation {
  var index: Int = 0
}

class MapViewController: UIViewController, LocationManagerDelegate, LocationManagerAuthorizationDelegate, UICollectionViewDelegate, UICollectionViewDataSource, MKMapViewDelegate, NotificationManagerDelegate {

  let padding = CGFloat(45)

  let dataStore = PlaceDataStore()
  let locationManager = LocationManager()
  let notificationManager = NotificationManager.shared
  var places:[Place] = []
  var currentPlace:Place?

  var lastCoordinate:CLLocationCoordinate2D?

  @IBOutlet weak var collectionView:UICollectionView!
  @IBOutlet weak var mapView:MKMapView!
  @IBOutlet weak var locationButton:UIButton!
  @IBOutlet weak var settingsButton:UIButton!
  @IBOutlet weak var activitylabel:UILabel!

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    navigationController?.isNavigationBarHidden = true

    if MotionManager.isActivityAvailable() {
      MotionManager.shared.track { (activity) in

        var modes: Set<String> = []
        if activity.walking {
          modes.insert("🚶‍")
        }

        if activity.running {
          modes.insert("🏃‍")
        }

        if activity.cycling {
          modes.insert("🚴‍")
        }

        if activity.automotive {
          modes.insert("🚗")
        }

        print(modes.joined(separator: ", "))

        self.activitylabel.text = modes.joined(separator: ", ")
      }
    } else {
      self.activitylabel.isHidden = true
    }

  }
  
  convenience init() {
    self.init(nibName:nil, bundle:nil)

    notificationManager.delegate = self
  }

  @IBAction func settings(sender: UIButton) {
    let settingsController = SettingsViewController(style: .grouped)
    navigationController?.isNavigationBarHidden = false
    navigationController?.pushViewController(settingsController, animated: true)
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    locationButton.layer.cornerRadius = 5.0
    locationButton.clipsToBounds = true
    locationButton.layer.borderColor = UIColor.lightGray.cgColor
    locationButton.layer.borderWidth = 1

    // Register cell classes

    let nib = UINib(nibName: "PlaceCell", bundle:nil)
    self.collectionView.register(nib, forCellWithReuseIdentifier: reuseIdentifier)

    self.navigationController?.navigationBar.isTranslucent = false

    self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(title: "Settings", style: .plain, target: self, action: nil)
    self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(title: "List View", style: .plain, target: self, action: nil)

    locationManager.delegate = self
    locationManager.authorizationDelegate = self
    
    let coordinate = CLLocationCoordinate2D(latitude: 39.9526, longitude: -75.1652)
    centerMap(coordinate)
    fetchData(latitude: coordinate.latitude, longitude: coordinate.longitude)
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

      if lastCoordinate != nil {
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
    selectIndex(indexPath)
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
    
    dataStore.retrievePlaces(latitude: latitude, longitude: longitude) { (success, data, count) in
      self.places = data

      if self.places.count > 0 {
        self.currentPlace = self.places.first
        self.centerMap((self.currentPlace?.coordinate())!)
      }

      let radius = CLLocationDistance(100)
      if self.locationManager.authorized {
        PlaceManager.shared.trackPlaces(places: data, radius: radius)
      }
      for place in self.places {
        let circle = MKCircle(center: place.coordinate(), radius: radius)
        self.mapView.add(circle)
      }
      self.reloadMap()
      self.collectionView.reloadData()
    }
  }

  // MARK: - Location manager delegate

  func locationUpdated(_ locationManager: LocationManager, coordinate: CLLocationCoordinate2D) {
    fetchData(latitude: coordinate.latitude, longitude: coordinate.longitude)
  }
  
  func authorized(_ locationManager: LocationManager) {
    centerCurrentLocation()
    locationManager.startMonitoringSignificantLocationChanges()
  }

  func notAuthorized(_ locationManager: LocationManager) {
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
      openInSafari(url: place.post.link)
    } else {
      selectIndex(indexPath)
    }
    return true
  }

  private var indexOfCellBeforeDragging = 0
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
    let proportionalOffset = collectionViewFlowLayout.collectionView!.contentOffset.x / itemWidth
    let index = Int(round(proportionalOffset))
    let numberOfItems = collectionView.numberOfItems(inSection: 0)
    let safeIndex = max(0, min(numberOfItems - 1, index))
    return safeIndex
  }

  func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
    indexOfCellBeforeDragging = indexOfMajorCell()
  }

  // Logic from: https://github.com/hershalle/CollectionViewWithPaging-Finish/blob/65ac92c2db31eef7404aa1013ecc1cada45ee0c8/CollectionViewWithPaging/ViewController.swift

  func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
    // Stop scrollView sliding:
    targetContentOffset.pointee = scrollView.contentOffset

    // calculate where scrollView should snap to:
    let indexOfMajorCell = self.indexOfMajorCell()

    // calculate conditions:
    let dataSourceCount = collectionView(collectionView!, numberOfItemsInSection: 0)
    let swipeVelocityThreshold: CGFloat = 0.5 // after some trail and error
    let hasEnoughVelocityToSlideToTheNextCell = indexOfCellBeforeDragging + 1 < dataSourceCount && velocity.x > swipeVelocityThreshold
    let hasEnoughVelocityToSlideToThePreviousCell = indexOfCellBeforeDragging - 1 >= 0 && velocity.x < -swipeVelocityThreshold
    let majorCellIsTheCellBeforeDragging = indexOfMajorCell == indexOfCellBeforeDragging
    let didUseSwipeToSkipCell = majorCellIsTheCellBeforeDragging && (hasEnoughVelocityToSlideToTheNextCell || hasEnoughVelocityToSlideToThePreviousCell)

    if didUseSwipeToSkipCell {

      let spacing = CGFloat(10)
      let snapToIndex = indexOfCellBeforeDragging + (hasEnoughVelocityToSlideToTheNextCell ? 1 : -1)
      let toValue = (collectionViewFlowLayout.itemSize.width + spacing) * CGFloat(snapToIndex)

      // Damping equal 1 => no oscillations => decay animation:
      UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: velocity.x, options: .allowUserInteraction, animations: {
        scrollView.contentOffset = CGPoint(x: toValue, y: 0)
        scrollView.layoutIfNeeded()
      }, completion: nil)

      let place:Place = self.places[snapToIndex]
      self.currentPlace = place
      self.reloadMap()
      self.centerMap(place.coordinate())

    } else {
      // This is a much better way to scroll to a cell:
      let indexPath = IndexPath(row: indexOfMajorCell, section: 0)
      selectIndex(indexPath)
    }
  }

  func selectIndex(_ indexPath:IndexPath) {
    collectionViewFlowLayout.collectionView!.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
    let place:Place = self.places[indexPath.row]
    let coordinate = place.coordinate()

    self.currentPlace = place

    self.reloadMap()

    self.centerMap(coordinate)
  }

  func centerMap(_ center: CLLocationCoordinate2D) {
    let span = MKCoordinateSpanMake(0.04, 0.04);
    let region = MKCoordinateRegion(center: center, span: span)
    self.mapView.setRegion(region, animated: false)
  }

  func recievedNotification(_ notificationManager: NotificationManager, response: UNNotificationResponse) {
    if response.notification.request.content.categoryIdentifier == "POST_ENTERED" {
      let urlString = response.notification.request.content.userInfo["PLACE_URL"]
      let url = URL(string: urlString as! String)
      if response.actionIdentifier == "CHECKIN_ACTION" {
        // Check-in
      }
      else if url != nil {
        openInSafari(url: url!)
      }
    }
  }

}

