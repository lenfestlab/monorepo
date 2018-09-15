import UIKit
import MapKit
import SafariServices

private let reuseIdentifier = "VenueCell"
fileprivate let sectionInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)

class MapViewController: UIViewController, LocationManagerDelegate, UICollectionViewDelegate, UICollectionViewDataSource, MKMapViewDelegate {
  
  let dataStore = VenueDataStore()
  let locationManager = LocationManager()
  let notificationManager = NotificationManager()
  var venues:[Venue] = []
  var currentVenue:Venue?

  @IBOutlet weak var collectionView:UICollectionView!
  @IBOutlet weak var mapView:MKMapView!
  @IBOutlet weak var locationButton:UIButton!
  @IBOutlet weak var settingsButton:UIButton!

  @IBAction func settings(sender: UIButton) {
    let settingsController = SettingsViewController(style: .grouped)
    let navigationController = UINavigationController(rootViewController: settingsController)
    navigationController.modalTransitionStyle = .flipHorizontal
    present(navigationController, animated: true)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    locationButton.layer.cornerRadius = 5.0
    locationButton.clipsToBounds = true
    locationButton.isSelected = true
    locationButton.layer.borderColor = UIColor.lightGray.cgColor
    locationButton.layer.borderWidth = 1

    settingsButton.layer.cornerRadius = 5.0
    settingsButton.clipsToBounds = true
    settingsButton.layer.borderColor = UIColor.lightGray.cgColor
    settingsButton.layer.borderWidth = 1

    
    let coordinate = CLLocationCoordinate2D(latitude: 39.9526, longitude: -75.1652)
    centerMap(coordinate)
    
    // Register cell classes
    
    let nib = UINib(nibName: "VenueCell", bundle:nil)
    self.collectionView.register(nib, forCellWithReuseIdentifier: reuseIdentifier)
    
    self.navigationController?.navigationBar.isTranslucent = false
    
    self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(title: "Settings", style: .plain, target: self, action: nil)
    self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(title: "List View", style: .plain, target: self, action: nil)
    
    locationManager.delegate = self
    locationManager.enableBasicLocationServices()
    notificationManager.requestAuthorization()
  }
  
  func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
    if annotation is MKUserLocation {
      //return nil so map view draws "blue dot" for standard user location
      return nil
    }
    
    let reuseId = "pin"
    let  pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
    pinView.canShowCallout = true
    pinView.animatesDrop = false
    
    if annotation.title == currentVenue?.title {
      pinView.pinTintColor = .red
    } else {
      pinView.pinTintColor = .blue
    }
    
    pinView.accessibilityLabel = "hello"
    let btn = UIButton(type: .detailDisclosure)
    pinView.rightCalloutAccessoryView = btn
    return pinView
  }
  
  func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
    
  }
  
  func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
    
  }
  
  func reloadMap() {
    self.mapView.removeAnnotations(self.mapView.annotations)
    
    for venue in self.venues {
      let annotation = MKPointAnnotation()
      annotation.coordinate = venue.coordinate()
      annotation.title = venue.title
      self.mapView.addAnnotation(annotation)
    }
  }
  
  func fetchData() {
    dataStore.retrieveVenues { (success, data, count) in
      self.venues = data
      
      if self.venues.count > 0 {
        self.currentVenue = self.venues.first
        self.centerMap((self.currentVenue?.coordinate())!)
      }
      
      if self.locationManager.authorized {
        self.notificationManager.trackVenues(venues: data)
        
        self.reloadMap()
        
      }
      self.collectionView.reloadData()
    }
  }
  
  // MARK: - Location manager delegate
  
  func authorized(_ locationManager: LocationManager) {
    fetchData()
  }
  
  func notAuthorized(_ locationManager: LocationManager) {
    fetchData()
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
    return venues.count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! VenueCell
    
    // Configure the cell
    let venue:Venue = self.venues[indexPath.row]
    cell.setVenue(venue: venue)
    return cell
  }
  
  func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
    if indexOfMajorCell() == indexPath.row {
      let venue:Venue = self.venues[indexPath.row]
      let url = venue.link
      let svc = SFSafariViewController(url: url!)
      present(svc, animated: true)
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
    let padding = CGFloat(30)
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
      
      let snapToIndex = indexOfCellBeforeDragging + (hasEnoughVelocityToSlideToTheNextCell ? 1 : -1)
      let toValue = collectionViewFlowLayout.itemSize.width * CGFloat(snapToIndex)
      
      // Damping equal 1 => no oscillations => decay animation:
      UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: velocity.x, options: .allowUserInteraction, animations: {
        scrollView.contentOffset = CGPoint(x: toValue, y: 0)
        scrollView.layoutIfNeeded()
      }, completion: nil)
      
      let venue:Venue = self.venues[snapToIndex]
      self.centerMap(venue.coordinate())
      
    } else {
      // This is a much better way to scroll to a cell:
      let indexPath = IndexPath(row: indexOfMajorCell, section: 0)
      selectIndex(indexPath)
    }
  }
  
  func selectIndex(_ indexPath:IndexPath) {
    collectionViewFlowLayout.collectionView!.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
    let venue:Venue = self.venues[indexPath.row]
    let coordinate = venue.coordinate()
    
    self.currentVenue = venue
    
    self.reloadMap()
    
    self.centerMap(coordinate)
  }
  
  func centerMap(_ center: CLLocationCoordinate2D) {
    let span = MKCoordinateSpanMake(0.010, 0.010);
    let region = MKCoordinateRegion(center: center, span: span)
    self.mapView.setRegion(region, animated: true)
  }
}

