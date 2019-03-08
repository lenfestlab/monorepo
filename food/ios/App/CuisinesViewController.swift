import UIKit

protocol CuisinesViewControllerDelegate: class {
  func categoriesUpdated(_ viewController: CuisinesViewController, categories: [Category])
}

class CuisinesViewController: UITableViewController {

  weak var delegate: CuisinesViewControllerDelegate?

  let alphabet = ["A","B","C","D", "E", "F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z"]

  override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
    return self.alphabet
  }

  @objc func applyFilter() {
    var selectedCategories = [Category]()

    for indexPath in self.tableView?.indexPathsForSelectedRows ?? [] {
      if let character = self.alphabet[indexPath.section].first {
        if let categories = self.sortedCategories[character] {
          let category = categories[indexPath.row]
          selectedCategories.append(category)
        }
      }
    }

    self.delegate?.categoriesUpdated(self, categories: selectedCategories)
  }

  @objc func dismissFilter() {
    self.dismiss(animated: true, completion: nil)
  }

  var sortedCategories = [Character : [Category]]()
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
    self.navigationController?.styleController()
    self.view.backgroundColor = UIColor.beige()

    for string in self.alphabet {
      if let character = string.first {
        self.sortedCategories[character] = [Category]()
      }
    }

    let store = CategoryDataStore()
    store.retrieveCategories(isCuisine: self.isCuisine) { (success, categories, count) in
      if let categories = categories {
        for category in categories {
          if let character = category.name.uppercased().first {
            self.sortedCategories[character]?.append(category)
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
      if let categories = self.sortedCategories[character] {
        return categories.count
      }
    }
    return 0
  }

   override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
   let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

    if let character = self.alphabet[indexPath.section].first {
      if let categories = self.sortedCategories[character] {
        let category = categories[indexPath.row]
        cell.textLabel?.text = category.name
      }
    }

    let selected = tableView.indexPathsForSelectedRows?.contains(indexPath) ?? false

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
