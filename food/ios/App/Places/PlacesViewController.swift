import UIKit
import CoreLocation
import SVProgressHUD
import RxRealm

extension PlacesViewController: PlaceStoreDelegate {
  // functions defined in class, else compiler error:
  // > Overriding declarations in extensions is not supported.
}

class PlacesViewController: UIViewController, Contextual {

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
    let topBar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 175, height: 64))
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

  var context: Context
  let analytics: AnalyticsManager

  let target: Api.Target

  init(target: Api.Target = .placesAll, context: Context, categories: [Category] = []) {
    self.target = target
    self.context = context
    self.analytics = context.analytics

    self.placeStore = PlaceStore(target: target, context: context)
    self.placeStore.filterModule.categories = categories

    self.mapViewController = MapViewController(context: context, placeStore: self.placeStore)
    self.listViewController = ListViewController(context: context, placeStore: self.placeStore)

    self.viewControllers = [self.mapViewController, self.listViewController]

    super.init(nibName: nil, bundle: nil)

    self.placeStore.delegate = self
    self.placeStore.beginObservingPlaces() // MUST be called after delegate set
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
    return target.path.contains("bookmark") ? "my-list" : "all-restaurant"
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

    if let location = self.locationManager.latestLocation {
      initialMapDataFetch(coordinate: location.coordinate)
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
//    self.mapViewController.centerMap(coordinate)
    self.refresh(coordinate: coordinate)
  }

  func refresh(coordinate: CLLocationCoordinate2D? = nil, completionBlock: (([Place]) -> (Void))? = nil) {
    // restrict post-launch data fetches to Home view; rest observe cache only.
    guard case .placesAll = target else { return }

    let showLoadingIndicator = viewIfLoaded?.window != nil

    if showLoadingIndicator {
      HUD.change(.show)
    }

    if let coordinate = coordinate {
      self.placeStore.lastCoordinateUsed = coordinate
    }
    self.placeStore.refresh(completionBlock: { (places) -> (Void) in
      if showLoadingIndicator {
        DispatchQueue.main.async { [weak self] in
          HUD.change(.hide)
        }
      }
      completionBlock?(places)
    })
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    self.navigationController?.view.setNeedsLayout() // force update layout
    self.navigationController?.view.layoutIfNeeded() // to fix height of the navigation bar
  }

  override func viewWillLayoutSubviews() {
    super.viewWillLayoutSubviews()
    let vc = viewControllers[self.selectedIndex]
    vc.view.frame = self.view.bounds
    self.topBar.frame = CGRect(x: 0, y: -5, width: self.view.frame.width, height: 54)
    self.filterBar.frame = CGRect(x: -1, y: 42, width: self.view.frame.width+2, height: 34)
  }

  func isEmpty() -> Bool {
    return self.placeStore.places.isEmpty
  }


  // PlaceStoreDelegate
  //

  func fetchedData(_ changeset: PlacesChangeset, _ setData: PlacesChangesetClosure) {
    if !_initalDataFetched {
      _initalDataFetched = true
      self.initalDataFetched()
    }
    self.mapViewController.fetchedData(changeset, setData)
    self.listViewController.fetchedData(changeset, setData)
  }

  func didSetPlaceFiltered() {
    // NO-OP
  }

  func filterText() -> String? {
    return nil
  }

}

