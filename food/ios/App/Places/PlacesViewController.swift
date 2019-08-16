import UIKit
import CoreLocation
import SVProgressHUD
import RxRealm
import RxGesture
import RxSwift
import SwiftDate

extension PlacesViewController: PlaceStoreDelegate {
  // functions defined in class, else compiler error:
  // > Overriding declarations in extensions is not supported.
}

class PlacesViewController: UIViewController, Contextual {

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

      let mapButton = UIButton(frame: CGRect(x: 0, y: 0, width: 39, height: 20))
      mapButton.setTitle("Map", for: .normal)
      mapButton.setTitleColor(.darkRed, for: .normal)
      mapButton.addTarget(self, action: #selector(map), for: .touchUpInside)

      let listButton = UIButton(frame: CGRect(x: 0, y: 0, width: 39, height: 20))
      listButton.setTitle("List", for: .normal)
      listButton.setTitleColor(.darkRed, for: .normal)
      listButton.addTarget(self, action: #selector(list), for: .touchUpInside)

      if selectedIndex == 1 {
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: mapButton)
      } else {
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: listButton)
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

  var telemetryView: UILabel = {
    let label = UILabel(frame: .zero)
    label.backgroundColor = .white
    label.numberOfLines = 0
    label.font = UIFont.monospacedDigitSystemFont(ofSize: 14, weight: .regular)
    label.isHidden = true
    return label
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

    self.filterBarIsHidden = true
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

  override func viewDidLoad() {
    super.viewDidLoad()
    // Trigger adding required children views
    self.selectedIndex = _selectedIndex

    self.topBar.isHidden = self.topBarIsHidden
    self.filterBar?.isHidden = self.filterBarIsHidden

    self.view.addSubview(self.topBar)
    self.view.addSubview(self.filterBar)

    self.placeStore.delegate = self
    self.placeStore.beginObservingPlaces() // MUST be called after delegate set


    // Place events telemetry

    view.addSubview(telemetryView)
    telemetryView.snp.makeConstraints { [unowned self] make in
      make.top.equalTo(topBar.snp.bottom)
      make.left.equalTo(self.view)
      make.right.equalTo(self.view)
    }

    topBar.rx.swipeGesture([.up, .down]).when(.ended)
      .map({ [unowned self] _ in
        return !self.telemetryView.isHidden
      })
      .bind(to: telemetryView.rx.isHidden)
      .disposed(by: rx.disposeBag)

    let latestPlaceEvent$: Observable<PlaceEvent?> =
      cache.recentPlaceEvents$.map { $0.first }

    let telemetryText$: Observable<String> =
      latestPlaceEvent$.map({ [unowned self] placeEvent in
        let text = "  Last nearby place: \n"
        let notAvailable = "n/a"
        let formatDate = { (ts: Date?) -> String in
          let region =
            Region(
              calendar: Calendars.gregorian,
              zone: Zones.autoUpdating,
              locale: Locale.autoupdatingCurrent)
          guard let ts = ts else { return "-" }
          let localTs = ts.in(region: region)
          return localTs.toFormat("MMM dd hh:mm:s a")
        }
        guard
          let event = placeEvent,
          let place: Place = self.cache.get(event.placeId),
          let placeName = place.name
          else { return text.appending(notAvailable) }
        return text.appending("""
          \(placeName)
          viewed:  \(formatDate(event.lastViewedAt))
          entered: \(formatDate(event.lastEnteredAt))
          exited:    \(formatDate(event.lastExitedAt))
          visited:   \(formatDate(event.lastVisitedAt))
          inside? \(event.isRegionActive)
        """)
      })

    telemetryText$
      .bind(to: telemetryView.rx.text)
      .disposed(by: rx.disposeBag)

  }


  func refresh(completionBlock: (([Place]) -> (Void))? = nil) {
    // restrict post-launch data fetches to Home view; rest observe cache only.
    guard case .placesAll = target else { return }

    let showLoadingIndicator = viewIfLoaded?.window != nil

    if showLoadingIndicator {
      HUD.change(.show)
    }

    self.placeStore.refresh(completionBlock: { places in
      if showLoadingIndicator {
        HUD.change(.hide)
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
    mapViewController.fetchedData(changeset, setData)
    listViewController.fetchedData(changeset, setData)
  }

  func didSetPlaceFiltered() {
    // NO-OP
  }

  func filterText() -> String? {
    return nil
  }

}

