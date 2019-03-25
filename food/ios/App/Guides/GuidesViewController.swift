import UIKit

class GuidesViewController: UITableViewController {

  var categories = [Category]()
  private let analytics: AnalyticsManager
  var isCuisine = false

  init(analytics: AnalyticsManager, isCuisine: Bool) {
    self.isCuisine = isCuisine
    self.analytics = analytics
    super.init(nibName: nil, bundle: nil)
    navigationItem.hidesBackButton = true
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    let nib = UINib.init(nibName: "GuideCell", bundle: nil)
    self.tableView.register(nib, forCellReuseIdentifier: "reuseIdentifier")
    self.navigationController?.styleController()
    self.navigationItem.title = "Guides"

    CategoryDataStore.retrieve(isCuisine: self.isCuisine) { (success, categories, count) in
      if let categories = categories {
        self.categories = categories
      }
      self.tableView.reloadData()
    }
  }

  // MARK: - Table view data source

  override func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }

  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return self.categories.count
  }

  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath) as! GuideCell

    let category = self.categories[indexPath.row]

    cell.setCategory(category: category)

    return cell
  }

  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let category = self.categories[indexPath.row]
    let placeController = PlacesViewController(analytics: self.analytics, categories: [category])
    placeController.title = category.name
    placeController.topBarIsHidden = true
    placeController.hidesBottomBarWhenPushed = true
    self.navigationController?.pushViewController(placeController, animated: true)
  }

}
