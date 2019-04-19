import UIKit

class GuideViewController: PlacesViewController {

  var category : Category!

  init(analytics: AnalyticsManager, category: Category) {
    super.init(path: "places.json?categories=\(category.identifier)", analytics: analytics)
    self.category = category
  }

  override func page() -> String {
    return self.category.name ?? "Unknown Guide"
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
