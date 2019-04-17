import UIKit
import CoreLocation
import UserNotifications
import SafariServices
import RxSwift
import RxCocoa
import SnapKit

class SettingsViewController: UITableViewController, SettingsToggleCellDelegate, LocationManagerAuthorizationDelegate {

  let locationManager = LocationManager.shared
  private var notification: NSObjectProtocol?

  private let analytics: AnalyticsManager
  private let notificationManager = NotificationManager.shared
  private let env: Env
  private let disposeBag: DisposeBag

  init(analytics: AnalyticsManager) {
    self.analytics = analytics
    self.env = Env()
    self.disposeBag = DisposeBag()
    super.init(style: .grouped)
    locationManager.authorizationDelegate = self
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  deinit {
    // make sure to remove the observer when this view controller is dismissed/deallocated

    if let notification = notification {
      NotificationCenter.default.removeObserver(notification)
    }
  }

  func authorized(_ locationManager: LocationManager, status: CLAuthorizationStatus) {
    self.loadSettings()
    self.tableView.reloadData()
  }

  func notAuthorized(_ locationManager: LocationManager, status: CLAuthorizationStatus) {
    self.loadSettings()
    self.tableView.reloadData()
  }

  func switchTriggered(sender: UISwitch) {
    switch sender.tag {
    case 0:
      print("Enable Notifications")
      analytics.log(.changeNotificationSettings(enabled: sender.isOn))
      if notificationManager.authorizationStatus == .notDetermined {
        notificationManager.requestAuthorization() { (success, error) in
          self.loadSettings()
          DispatchQueue.main.async {
            self.tableView.reloadData()
          }
        }
      } else if let url = URL(string: UIApplication.openSettingsURLString) {
        // If general location settings are enabled then open location settings for the app
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
      }

    case 1:
      print("Access Location")
      analytics.log(.changeLocationSettings(enabled: sender.isOn))
      if CLLocationManager.authorizationStatus() == .notDetermined {
        locationManager.enableBasicLocationServices()
      } else if let url = URL(string: UIApplication.openSettingsURLString) {
        // If general location settings are enabled then open location settings for the app
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
      }

    case 3:
      print("Clear History")
      analytics.log(.clearHistory())
      NotificationManager.shared.saveIdentifiers([:])

    default:
      print("unknown switch")
    }
  }

  func loadSettings() {

    let rows = [
      [
        "identifier": "default",
        "title":"About Us",
        "path":"\(env.apiBaseUrlString)/about",
        ],
      [
        "identifier": "default",
        "title":"Privacy Policy",
        "path":"\(env.apiBaseUrlString)/privacy",
        ],
      [
        "identifier": "default",
        "title":"Terms of Service",
        "path":"\(env.apiBaseUrlString)/tos",
        "inset":"zero",
        ],
      [
        "identifier": "default",
        "title":"Share Your Feedback",
        "path": "https://goo.gl/forms/rJzeBGvAs5vDxCnP2",
        "inset":"zero",
        ]

    ]

    var toggleRows: [[String: Any]] = [
      [
        "identifier": "setting",
        "title": "Enable notifications",
        "description": "This app sends push notifications.",
        "toggle": notificationManager.authorizationStatus == .authorized
      ],
      [
        "identifier": "setting",
        "title": "Enable location",
        "description": "Map and notification features use your location to display and send you articles.",
        "toggle": CLLocationManager.authorizationStatus() == .authorizedAlways
      ]

    ]

    if env.isPreProduction {
      toggleRows.append(
        [
          "identifier": "setting",
          "title": "Recurring notifications",
          "description": "We remember which notifications you receive and don’t send them again. Turn this off to receive each notification again.",
          "toggle": true
        ]
      )
    }

    let general = [
      "title": "GENERAL",
      "rows": rows
      ] as [String : Any]

    self.settings = [
      [
        "title": "PERMISSIONS",
        "rows": toggleRows
      ]
    ]

    if Installation.authToken() != nil {
      let email = [
        "title": "EMAIL",
        "rows": [[
          "identifier": "default",
          "title": Installation.shared.email ?? "Email Address",
          "font": UIFont.lightLarge,
          "action": "email",
          "description" : "Edit",
          "inset":"zero",
          ]]
        ] as [String : Any]

      self.settings.append(email)
    }

    self.settings.append(general)

  }

  var settings:[[String:Any?]] = [[:]]

  override func viewDidLoad() {
    super.viewDidLoad()

    self.navigationController?.styleController()
    self.tableView.separatorColor = UIColor.slate.withAlphaComponent(0.3)

    loadSettings()
    notification =
      NotificationCenter.default.addObserver(
        forName: UIApplication.willEnterForegroundNotification,
        object: nil,
        queue: .main) {
      [unowned self] notification in
      self.notificationManager.refreshAuthorizationStatus(completionHandler: { (status) in
        self.loadSettings()
        DispatchQueue.main.async {
          self.tableView.reloadData()
        }
      })
    }

    self.title = "Settings"

    self.tableView.backgroundColor = UIColor.white
    self.navigationItem.backBarButtonItem  = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)

    tableView.rowHeight = UITableView.automaticDimension
    tableView.estimatedRowHeight = 125

    let nib = UINib.init(nibName: "SettingsToggleCell", bundle: nil)
    tableView.register(nib, forCellReuseIdentifier: "setting")
  }

  // MARK: - Table view data source

  override func numberOfSections(in tableView: UITableView) -> Int {
    return settings.count
  }

  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    let section = settings[section]
    let rows = section["rows"] as! [Any]
    return rows.count
  }

  override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return CGFloat(45);
  }

  override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    let section = settings[section]
    let title = section["title"] as! String
    let label = UILabel(frame: .zero)
    label.text = "    \(title)"
    label.textColor = .darkGray
    label.font =  .largeBook
    return label
  }

  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let section = settings[indexPath.section]
    let rows = section["rows"] as! [Any]
    let row = rows[indexPath.row] as! [String:Any]
    let identifier = row["identifier"] as! String

    if identifier == "setting" {
      let cell:SettingsToggleCell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! SettingsToggleCell
      cell.titleLabel.text = row["title"] as? String
      cell.titleLabel.font = .mediumLarge
      cell.descriptionLabel.text = row["description"] as? String
      cell.descriptionLabel.font = .lightLarge
      cell.permissionSwitch.isOn = row["toggle"] as? Bool == true
      cell.permissionSwitch.tag = indexPath.row
      cell.permissionSwitch.onTintColor = .lightGreyBlue
      cell.delegate = self
      cell.selectionStyle = .none
      return cell
    } else {
      let cell:UITableViewCell = tableView.dequeueReusableCell(withIdentifier: identifier) ?? UITableViewCell(style: UITableViewCell.CellStyle.value1, reuseIdentifier: identifier)
      cell.textLabel?.text = row["title"] as? String
      let font = row["font"] as? UIFont
      cell.textLabel?.font = font != nil ? font : .mediumLarge
      cell.detailTextLabel?.text = row["description"] as? String
      cell.accessoryView = UIImageView(image: UIImage(named: "disclosure-indicator"))
      if (row["inset"] as? String) == "zero" {
        cell.separatorInset = .zero
      }

      return cell
    }
  }

  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let section = settings[indexPath.section]
    let rows = section["rows"] as! [Any]
    let row = rows[indexPath.row] as! [String:Any]
    if let path = row["path"] as? String {
      let url = URL(string: path)
      let svc = SFSafariViewController(url: url!)
      self.present(svc, animated: true)
      return
    }

    if let action = row["action"] as? String {
      if action == "email"  {
        self.navigationController?.pushViewController(UpdateEmailViewController(analytics: self.analytics), animated: true)
        return
      }
    }

  }

}
