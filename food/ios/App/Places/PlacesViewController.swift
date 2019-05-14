import UIKit
import CoreLocation
import SVProgressHUD

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
    return nil
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
      if self.isViewLoaded {
        hideContentController(self.viewControllers[selectedIndex])
        displayContentController(self.viewControllers[newValue])
      }
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
    filterBar.layer.borderWidth = 1
    filterBar.layer.borderColor = UIColor.slate.withAlphaComponent(0.3).cgColor
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

  private let context: Context
  let analytics: AnalyticsManager

  let path : String!

  init(path: String = "places.json", context: Context, categories: [Category] = []) {
    self.path = path
    self.context = context
    self.analytics = context.analytics

    self.placeStore = PlaceStore(context: context)
    self.placeStore.filterModule.categories = categories

    self.mapViewController = MapViewController(context: context, placeStore: self.placeStore)
    self.listViewController = ListViewController(context: context, placeStore: self.placeStore)

    self.viewControllers = [self.mapViewController, self.listViewController]

    super.init(nibName: nil, bundle: nil)

    self.placeStore.delegate = self
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  @IBAction func list(sender: UIButton) {
    if let viewControllers = self.viewControllers {
      let index = viewControllers.firstIndex(of: self.listViewController)
      self.selectedIndex = index ?? 0
    }
    self.analytics.log(.switchesViewCarouselToList(page: self.page()))
  }

  func page() -> String {
    return path.contains("bookmark") ? "my-list" : "all-restaurant"
  }

  @IBAction func map(sender: UIButton) {
    if let viewControllers = self.viewControllers {
      let index = viewControllers.firstIndex(of: self.mapViewController)
      self.selectedIndex = index ?? 0
    }
    self.analytics.log(.switchesViewListToCarousel(page: self.page()))
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
    // Trigger adding required children views
    self.selectedIndex = _selectedIndex

    NotificationCenter.default.addObserver(self, selector: #selector(onLocationUpdated(_:)), name: .locationUpdated, object: nil)

    self.topBar.isHidden = self.topBarIsHidden
    self.filterBarIsHidden = true

    self.view.addSubview(self.topBar)
    self.view.addSubview(self.filterBar)

    let defaultCoordinate = CLLocationCoordinate2D(latitude: 39.9526, longitude: -75.1652)

    if let location = self.locationManager.latestLocation {
      initialMapDataFetch(coordinate: location.coordinate)
    } else {
      self.refresh(coordinate: defaultCoordinate)
    }

  }

  var _initalDataFetched = false

  func initialMapDataFetch(coordinate: CLLocationCoordinate2D) {
    if _initalDataFetched {
      return
    }
    if self.placeStore.loading {
      return
    }
    print(self.placeStore.loading)
//    self.mapViewController.centerMap(coordinate)
    self.refresh(coordinate: coordinate)
  }

  func refresh(coordinate: CLLocationCoordinate2D? = nil, completionBlock: (([MapPlace]) -> (Void))? = nil) {
    let showLoadingIndicator = self.viewIfLoaded?.window != nil

    if showLoadingIndicator {
      SVProgressHUD.show()
      SVProgressHUD.setForegroundColor(UIColor.slate)
    }

    self.placeStore.path = self.path
    if let coordinate = coordinate {
      self.placeStore.lastCoordinateUsed = coordinate
    }
    self.placeStore.refresh(completionBlock: { (places) -> (Void) in
      if showLoadingIndicator {
        DispatchQueue.main.async {
          SVProgressHUD.dismiss()
        }
      }
      completionBlock?(places)
    })
  }

  override func viewWillLayoutSubviews() {
    super.viewWillLayoutSubviews()
    let vc = viewControllers[self.selectedIndex]
    vc.view.frame = self.view.bounds
    self.topBar.frame = CGRect(x: 0, y: -12, width: self.view.frame.width, height: 54)
    self.filterBar.frame = CGRect(x: -1, y: 42, width: self.view.frame.width+2, height: 34)
  }

  func isEmpty() -> Bool {
    return self.placeStore.placesFiltered.count == 0
  }

}
