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
    return "guides / \(category.name)"
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    self.listViewController.controllerIdentifierKey = "guide"
    self.mapViewController.controllerIdentifierKey = "guide"
  }

}
