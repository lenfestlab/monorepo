import UIKit

class SettingsRowManager : NSObject {
  var tableViewCell : UITableViewCell
  var path: String?
  var selectionBlock: (() -> Void)? = nil

  init(tableViewCell: UITableViewCell, path: String? = nil, selectionBlock: (() -> Void)? = nil) {
    self.tableViewCell = tableViewCell
    self.path = path
    self.selectionBlock = selectionBlock
    super.init()
  }
}

class SettingsSectionManager : NSObject {
  var title: String
  var rows : [SettingsRowManager]

  init(title: String, rows: [SettingsRowManager]) {
    self.title = title
    self.rows = rows
    super.init()
  }
}

class BaseSettingsViewController: UITableViewController {

  var sections : [SettingsSectionManager] = []

  override func viewDidLoad() {
    self.title = "Settings"
  }

  func loadSettings() {
    self.sections = self.loadData()
    self.tableView.reloadData()
  }

  func loadData() -> [SettingsSectionManager] {
    let data : [SettingsSectionManager] = []
    return data
  }

  // MARK: - Table view data source

  override func numberOfSections(in tableView: UITableView) -> Int {
    return sections.count
  }

  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    let section = sections[section]
    return section.rows.count
  }

  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let section = sections[indexPath.section]
    let row = section.rows[indexPath.row]
    return row.tableViewCell
  }

  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let section = sections[indexPath.section]
    let rows = section.rows
    let row = rows[indexPath.row]
    row.selectionBlock?()
  }

  override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    let section = sections[section]
    let title = section.title
    return title
  }

}
