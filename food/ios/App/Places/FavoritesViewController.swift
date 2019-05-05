import UIKit

extension Notification.Name {
  static let favoritesUpdated = Notification.Name("favoritesUpdate")
}

class FavoritesViewController : PlacesViewController {
  override func initalDataFetched() {
    let places = self.placeStore.placesFiltered.map({ $0.place })
    Bookmark.cacheLatest(places: places)
  }

  init(context: Context) {
    super.init(path: "places.json?bookmarked=1", context: context)
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  @objc func onFavoritesUpdated(_ notification: Notification) {
    self.placeStore.refresh()
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    self.listViewController.controllerIdentifierKey = "my-list"
    self.mapViewController.controllerIdentifierKey = "my-list"

    NotificationCenter.default.addObserver(self, selector: #selector(onFavoritesUpdated(_:)), name: .favoritesUpdated, object: nil)

    self.title = "My List"

    self.topBarIsHidden = true

    self.emptyView.isHidden = true
    self.view.addSubview(self.emptyView)
  }

  lazy var emptyView : EmptyView = {
    let view = EmptyView()
    view.emptyImageView.image = UIImage(named: "no-favorites")
    view.emptyTitleLabel.text = "Your plate is empty!"
    view.backgroundColor = .white
    return view
  }()

  override func viewWillLayoutSubviews() {
    super.viewWillLayoutSubviews()

    self.emptyView.frame = self.view.bounds
  }

  override func fetchedMapData() {
    super.fetchedMapData()

    self.emptyView.isHidden = !isEmpty()
  }

}
