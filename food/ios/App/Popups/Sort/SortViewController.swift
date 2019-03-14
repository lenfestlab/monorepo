import UIKit

enum SortMode : String {
  case distance = "Distance"
  case rating = "Rating"
  case latest = "Latest"
}

protocol SortViewControllerDelegate: class {
  func sortUpdated(_ viewController: SortViewController, sort: SortMode)
}

class SortViewController: UITableViewController {

  init(sortMode: SortMode) {
    self.sortMode = sortMode
    super.init(style: .plain)
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  weak var sortDelegate: SortViewControllerDelegate?

  var sortMode : SortMode {
    willSet {
      if let row = self.array.index(of: sortMode) {
        let selectedIndexPath = IndexPath(row: row, section: 0)
        let cell = tableView.cellForRow(at: selectedIndexPath)
        cell?.accessoryType  = .none
      }
    }

    didSet {
      if let row = self.array.index(of: sortMode) {
        let selectedIndexPath = IndexPath(row: row, section: 0)
        let cell = tableView.cellForRow(at: selectedIndexPath)
        cell?.accessoryType  = .checkmark
      }

      self.sortDelegate?.sortUpdated(self, sort: sortMode)
    }
  }

  let array : [SortMode] = [.distance, .rating, .latest]

  override func viewDidLoad() {
    super.viewDidLoad()

    self.title = "Sort"
    self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "reuseIdentifier")
    self.tableView.allowsMultipleSelection = false
  }

  // MARK: - Table view data source

  override func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }

  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return array.count
  }

  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
    cell.textLabel?.text = array[indexPath.row].rawValue
    return cell
  }

  override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    let sort = array[indexPath.row]
    cell.accessoryType  = (sort == sortMode) ? .checkmark : .none
  }

  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let sort = array[indexPath.row]
    self.sortMode = sort
  }

  override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
    let cell = tableView.cellForRow(at: indexPath)
    cell?.accessoryType  = .none
  }

}
