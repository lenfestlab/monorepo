import UIKit
import CoreLocation

class GuideViewController: PlacesViewController {

  var category : Category!

  init(analytics: AnalyticsManager, category: Category) {
    super.init(path: "places.json?categories=\(category.identifier)", analytics: analytics)
    self.category = category
    self.selectedIndex = 1 // default to list view instead of map
  }

  override func page() -> String {
    return "guides / \(category.name ?? "unknown")"
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    self.listViewController.controllerIdentifierKey = "guide"
    self.mapViewController.controllerIdentifierKey = "guide"
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    // TODO: hotfix only, refactor - guide default map center/span
    let coordinate = CLLocationCoordinate2D(latitude: 39.9526, longitude: -75.1652)
    self.mapViewController.centerMap(coordinate)
  }

}
