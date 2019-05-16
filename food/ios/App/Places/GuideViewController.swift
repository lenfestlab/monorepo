import UIKit
import CoreLocation

class GuideViewController: PlacesViewController {

  var category : Category!

  init(context: Context, category: Category) {
    super.init(target: .placesCategorizedIn(category.identifier), context: context)
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
    let coordinate = locationManager.defaultCoordinate
    self.mapViewController.mapView?.center(coordinate)
  }

}
