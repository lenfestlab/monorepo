import UIKit

enum SortMode : String {
  case distance = "Distance"
  case rating = "Rating"
  case latest = "Latest"
}

class SortViewController: UITableViewController {

  private let filterModule: FilterModule
  var analytics: AnalyticsManager!

  init(analytics: AnalyticsManager, filter: FilterModule) {
    self.analytics = analytics
    self.filterModule = filter
    self.sortMode = filter.sortMode
    super.init(style: .plain)
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  weak var sortDelegate: FilterModuleDelegate?

  var sortMode : SortMode {
    willSet {
      if let row = self.array.index(of: sortMode) {
        let selectedIndexPath = IndexPath(row: row, section: 0)
        let cell = tableView.cellForRow(at: selectedIndexPath)
        cell?.accessoryType  = .none
      }
    }

    didSet {
      self.filterModule.sortMode = sortMode
      self.analytics.log(.selectsSortFromFilter(mode: sortMode, category: .navigation))
      self.sortDelegate?.filterUpdated(self, filter: self.filterModule)
    }
  }

  let array : [SortMode] = [.distance, .rating, .latest]

  override func viewDidLoad() {
    super.viewDidLoad()

    self.title = "Sort"
    self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "reuseIdentifier")
    self.tableView.allowsMultipleSelection = false
    self.tableView.rowHeight = 56
    self.tableView.isScrollEnabled = false
    self.tableView.separatorInset = .zero
    self.popUpViewController?.isToolbarHidden = true
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

    let sort = array[indexPath.row]
    if sort == .distance {
      cell.textLabel?.text = "DISTANCE"
    } else if sort == .latest {
      cell.textLabel?.text = "LATEST"
    } else if sort == .rating {
      cell.textLabel?.text = "RATING"
    }

    cell.textLabel?.textAlignment = .center
    return cell
  }

  override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    let sort = array[indexPath.row]
    cell.backgroundColor  = (sort == sortMode) ? .slate : .white
    cell.textLabel?.textColor  = (sort == sortMode) ? .white : .black
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
