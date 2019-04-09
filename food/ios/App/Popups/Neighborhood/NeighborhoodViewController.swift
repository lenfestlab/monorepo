import UIKit

protocol NeighborhoodViewControllerDelegate: class {
  func neighborhoodsUpdated(_ viewController: NeighborhoodViewController, neighborhoods: [Neighborhood])
}

class NeighborhoodViewController: UITableViewController {

  weak var delegate: NeighborhoodViewControllerDelegate?

  let alphabet = ["A","B","C","D", "E", "F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z"]

  override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
    return self.alphabet
  }

  @objc func applyFilter() {
    self.delegate?.neighborhoodsUpdated(self, neighborhoods: self.selected)
  }

  @IBAction func clearAll() {
    self.delegate?.neighborhoodsUpdated(self, neighborhoods: [])
  }


  var sorted = [Character : [Neighborhood]]()
  var selected = [Neighborhood]()
  private let analytics: AnalyticsManager
  var isCuisine = false

  init(analytics: AnalyticsManager, selected: [Neighborhood]) {
    self.analytics = analytics
    self.selected = selected
    super.init(nibName: nil, bundle: nil)
    navigationItem.hidesBackButton = true
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    self.tableView.allowsMultipleSelection = true
    self.tableView.sectionIndexColor = .lightGreyBlue

    self.title = "Neighborhood"

    let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
    let clear = UIBarButtonItem(title: "Clear All", style: .plain, target: self, action: #selector(clearAll))
    let apply = UIBarButtonItem(title: "Apply", style: .done, target: self, action: #selector(applyFilter))
    self.toolbarItems = [clear, space, apply]

    self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "reuseIdentifier")
    self.navigationController?.styleController()

    for string in self.alphabet {
      if let character = string.first {
        self.sorted[character] = [Neighborhood]()
      }
    }

    NeighborhoodDataStore.retrieve { (success, neighborhoods, count) in
      if let neighborhoods = neighborhoods {
        for nabe in neighborhoods {
          if let character = nabe.name.uppercased().first {
            self.sorted[character]?.append(nabe)
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

    if let nabe = self.neigborhoodAtIndexPath(indexPath) {
      cell.textLabel?.text = nabe.name
    }

    cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 15)
    cell.selectionStyle = .none
    cell.textLabel?.font = UIFont.largeBook

    return cell
  }

  func neigborhoodAtIndexPath(_ indexPath: IndexPath) -> Neighborhood? {
    if let character = self.alphabet[indexPath.section].first {
      if let categories = self.sorted[character] {
        let category = categories[indexPath.row]
        return category
      }
    }
    return nil
  }

  override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    guard let nabe = self.neigborhoodAtIndexPath(indexPath)  else {
      return
    }

    let categoryIds = self.selected.map { $0.identifier }
    let selected = categoryIds.contains(nabe.identifier)
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

    if let nabe = self.neigborhoodAtIndexPath(indexPath) {
      self.selected.append(nabe)
    }
  }

  override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
    let cell = tableView.cellForRow(at: indexPath)
    cell?.accessoryType  = .none

    if let category = self.neigborhoodAtIndexPath(indexPath) {
      let categoryIds = self.selected.map { $0.identifier }
      if let index = categoryIds.index(of: category.identifier) {
        self.selected.remove(at: index)
      }
    }
  }

}
