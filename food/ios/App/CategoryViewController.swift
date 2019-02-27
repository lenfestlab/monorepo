import UIKit

protocol CategoryViewControllerDelegate: class {
  func categoriesUpdated(_ viewController: CategoryViewController, categories: [Category])
}

class CategoryViewController: UITableViewController {

  weak var categoryFilterDelegate: CategoryViewControllerDelegate?

  var categories = [Category]()
  private let analytics: AnalyticsManager

  init(analytics: AnalyticsManager) {
    self.analytics = analytics
    super.init(nibName: nil, bundle: nil)
    navigationItem.hidesBackButton = true
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()

    self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "reuseIdentifier")
    self.style()
    self.title = "Guides"
    self.view.backgroundColor = UIColor.beige()

    let store = CategoryDataStore()
    store.retrieveCategories { (success, categories, count) in
      if let categories = categories {
        self.categories = categories
      }
      self.tableView.reloadData()
    }
  }

  @objc func dismissFilter() {
    self.dismiss(animated: true, completion: nil)
  }

  @objc func applyFilter() {
    var selectedCategories = [Category]()

    for indexPath in self.tableView?.indexPathsForSelectedRows ?? [] {
      let category = self.categories[indexPath.row]
      selectedCategories.append(category)
    }

    self.categoryFilterDelegate?.categoriesUpdated(self, categories: selectedCategories)
  }
  // MARK: - Table view data source

  override func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }

  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return self.categories.count
  }

   override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
   let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

    let category = self.categories[indexPath.row]

    let selected = tableView.indexPathsForSelectedRows?.contains(indexPath) ?? false

    cell.textLabel?.text = category.name
    cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 15)
    cell.selectionStyle = .none
    cell.accessoryType  = selected ? .checkmark : .none
    return cell
   }

  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let category = self.categories[indexPath.row]
    let mapViewController = MapViewController(analytics: self.analytics)
    mapViewController.title = category.name
    self.navigationController?.pushViewController(mapViewController, animated: true)
  }

}
