import UIKit

extension Notification.Name {
  static let favoritesUpdated = Notification.Name("favoritesUpdate")
}

class FavoritesViewController : PlacesViewController {
  override func initalDataFetched() {
    let placeIds = self.placeStore.placesFiltered.map { $0.place.identifier }
    Place.save(identifiers: placeIds)
    NotificationCenter.default.post(name: .favoritesUpdated, object: nil)
  }

  init(analytics: AnalyticsManager) {
    super.init(path: "places.json?bookmarked=1", analytics: analytics)
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
  }

}
