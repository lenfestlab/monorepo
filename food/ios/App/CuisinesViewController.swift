import UIKit

protocol CuisinesViewControllerDelegate: class {
  func categoriesUpdated(_ viewController: CuisinesViewController, categories: [Category])
}

class CuisinesViewController: UITableViewController {

  weak var delegate: CuisinesViewControllerDelegate?

  @objc func applyFilter() {
    var selectedCategories = [Category]()

    for indexPath in self.tableView?.indexPathsForSelectedRows ?? [] {
      let category = self.categories[indexPath.row]
      selectedCategories.append(category)
    }

    self.delegate?.categoriesUpdated(self, categories: selectedCategories)
  }

  @objc func dismissFilter() {
    self.dismiss(animated: true, completion: nil)
  }

  var categories = [Category]()
  private let analytics: AnalyticsManager
  var isCuisine = false

  init(analytics: AnalyticsManager) {
    self.isCuisine = true
    self.analytics = analytics
    super.init(nibName: nil, bundle: nil)
    navigationItem.hidesBackButton = true
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    self.tableView.allowsMultipleSelection = true

    self.title = "Cuisines"
    self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(dismissFilter))
    self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Apply", style: .plain, target: self, action: #selector(applyFilter))

    self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "reuseIdentifier")
    self.style()
    self.view.backgroundColor = UIColor.beige()

    let store = CategoryDataStore()
    store.retrieveCategories(isCuisine: self.isCuisine) { (success, categories, count) in
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
    let cell = tableView.cellForRow(at: indexPath)
    cell?.accessoryType  = .checkmark
  }

  override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
    let cell = tableView.cellForRow(at: indexPath)
    cell?.accessoryType  = .none
  }

}
