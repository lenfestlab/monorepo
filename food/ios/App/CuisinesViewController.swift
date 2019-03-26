import UIKit

class CuisinesViewController: UITableViewController {

  weak var delegate: FilterModuleDelegate?

  let alphabet = ["A","B","C","D", "E", "F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z"]

  override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
    return self.alphabet
  }

  @objc func applyFilter() {
    self.filterModule.categories = self.selected
    self.delegate?.filterUpdated(self, filter: self.filterModule)
  }

  @objc func dismissFilter() {
    self.dismiss(animated: true, completion: nil)
  }

  var sorted = [Character : [Category]]()
  private let filterModule: FilterModule
  var selected = [Category]()
  private let analytics: AnalyticsManager
  var isCuisine = false

  init(analytics: AnalyticsManager, filter: FilterModule) {
    self.isCuisine = true
    self.analytics = analytics
    self.filterModule = filter
    self.selected = filter.categories
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
    self.navigationController?.styleController()

    for string in self.alphabet {
      if let character = string.first {
        self.sorted[character] = [Category]()
      }
    }

    CategoryDataStore.retrieve(isCuisine: self.isCuisine) { (success, categories, count) in
      if let categories = categories {
        for category in categories {
          if let character = category.name.uppercased().first {
            self.sorted[character]?.append(category)
          }
        }
      }
      self.tableView.reloadData()
    }
  }

  // MARK: - Table view data source

  override func numberOfSections(in tableView: UITableView) -> Int {
    return self.alphabet.count
  }

  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if let character = self.alphabet[section].first {
      if let categories = self.sorted[character] {
        return categories.count
      }
    }
    return 0
  }

  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

    if let category = self.categoryAtIndexPath(indexPath) {
      cell.textLabel?.text = category.name
    }

    cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 15)
    cell.selectionStyle = .none

    return cell
  }

  func categoryAtIndexPath(_ indexPath: IndexPath) -> Category? {
    if let character = self.alphabet[indexPath.section].first {
      if let categories = self.sorted[character] {
        let category = categories[indexPath.row]
        return category
      }
    }
    return nil
  }

  override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    guard let category = self.categoryAtIndexPath(indexPath)  else {
      return
    }

    let categoryIds = self.selected.map { $0.identifier }
    let selected = categoryIds.contains(category.identifier)
    if selected {
      tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
      cell.accessoryType  = .checkmark
    } else {
      tableView.deselectRow(at: indexPath, animated: false)
      cell.accessoryType  = .none
    }

  }

  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let cell = tableView.cellForRow(at: indexPath)
    cell?.accessoryType  = .checkmark

    if let category = self.categoryAtIndexPath(indexPath) {
      self.selected.append(category)
    }
  }

  override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
    let cell = tableView.cellForRow(at: indexPath)
    cell?.accessoryType  = .none

    if let category = self.categoryAtIndexPath(indexPath) {
      let categoryIds = self.selected.map { $0.identifier }
      if let index = categoryIds.index(of: category.identifier) {
        self.selected.remove(at: index)
      }
    }
  }

}
