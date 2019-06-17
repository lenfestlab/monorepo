import UIKit
import CoreLocation
import UserNotifications
import SafariServices
import RxSwift
import RxCocoa
import SnapKit

class SettingsViewController: BaseSettingsViewController, LocationManagerAuthorizationDelegate, Contextual {
  
  var context: Context
  private let notificationManager: NotificationManager

  private var notification: NSObjectProtocol?

  init(
    context: Context,
    notificationManager: NotificationManager
    ) {
    self.context = context
    self.notificationManager = notificationManager
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

  @objc func notificationSwitchTriggered(sender: UISwitch) {
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
  }

  @objc func locationSwitchTriggered(sender: UISwitch) {
    print("Access Location")
    analytics.log(.changeLocationSettings(enabled: sender.isOn))
    if CLLocationManager.authorizationStatus() == .notDetermined {
      locationManager.enableBasicLocationServices()
    } else if let url = URL(string: UIApplication.openSettingsURLString) {
      // If general location settings are enabled then open location settings for the app
      UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
  }

  @objc func clearHistorySwitchTriggered(sender: UISwitch) {
    print("Clear History [DEPRECATED]")
  }

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

    self.tableView.backgroundColor = UIColor.white
    self.navigationItem.backBarButtonItem  = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)

    tableView.rowHeight = UITableView.automaticDimension
    tableView.estimatedRowHeight = 125

    let nib = UINib.init(nibName: "SettingsToggleCell", bundle: nil)
    tableView.register(nib, forCellReuseIdentifier: "setting")
  }

  override func loadData() -> [SettingsSectionManager] {
    var data : [SettingsSectionManager] = []

    let apiBaseUrlString = self.env.apiBaseUrlString

    let aboutCell = UITableViewCell(style: UITableViewCell.CellStyle.value1, reuseIdentifier: nil)
    aboutCell.accessoryView = UIImageView(image: UIImage(named: "disclosure-indicator"))
    aboutCell.textLabel?.text = "About Us"
    aboutCell.textLabel?.font = .mediumLarge

    let aboutManager = SettingsRowManager(tableViewCell: aboutCell) {
      let url = URL(string: "\(apiBaseUrlString)/about")
      let svc = SFSafariViewController(url: url!)
      self.present(svc, animated: true)
    }

    let privacyCell = UITableViewCell(style: UITableViewCell.CellStyle.value1, reuseIdentifier: nil)
    privacyCell.accessoryView = UIImageView(image: UIImage(named: "disclosure-indicator"))
    privacyCell.textLabel?.text = "Privacy Policy"
    privacyCell.textLabel?.font = .mediumLarge

    let privacyManager = SettingsRowManager(tableViewCell: privacyCell) {
      let url = URL(string: "\(apiBaseUrlString)/privacy")
      let svc = SFSafariViewController(url: url!)
      self.present(svc, animated: true)
    }

    let termsCell = UITableViewCell(style: UITableViewCell.CellStyle.value1, reuseIdentifier: nil)
    termsCell.accessoryView = UIImageView(image: UIImage(named: "disclosure-indicator"))
    termsCell.textLabel?.text = "Terms of Service"
    termsCell.textLabel?.font = .mediumLarge

    let termsManager = SettingsRowManager(tableViewCell: termsCell) { [weak self] in
      let url = URL(string: "\(apiBaseUrlString)/tos")
      let svc = SFSafariViewController(url: url!)
      self?.present(svc, animated: true)
    }

    let feedbackCell = UITableViewCell(style: UITableViewCell.CellStyle.value1, reuseIdentifier: nil)
    feedbackCell.accessoryView = UIImageView(image: UIImage(named: "disclosure-indicator"))
    feedbackCell.textLabel?.text = " Share Your Feedback"
    feedbackCell.textLabel?.font = .mediumLarge
    feedbackCell.separatorInset = .zero

    let feedbackManager = SettingsRowManager(tableViewCell: feedbackCell) {
      let url = URL(string: "https://goo.gl/forms/rJzeBGvAs5vDxCnP2")
      let svc = SFSafariViewController(url: url!)
      self.present(svc, animated: true)
    }

    let rows = [
      aboutManager,
      privacyManager,
      termsManager,
      feedbackManager
    ]

    let notificationsCell = SettingsToggleCell.fromNib()
    notificationsCell.titleLabel.text = "Enable notifications"
    notificationsCell.titleLabel.font = .mediumLarge
    notificationsCell.descriptionLabel.text = "This app sends push notifications."
    notificationsCell.descriptionLabel.font = .lightLarge
    notificationsCell.permissionSwitch.isOn = notificationManager.authorizationStatus == .authorized
    notificationsCell.permissionSwitch.tag = 0
    notificationsCell.permissionSwitch.onTintColor = .lightGreyBlue
    notificationsCell.permissionSwitch.addTarget(self, action: #selector(notificationSwitchTriggered(sender:)), for: .valueChanged)
    notificationsCell.selectionStyle = .none

    let locationCell = SettingsToggleCell.fromNib()
    locationCell.titleLabel.text = "Enable location"
    locationCell.titleLabel.font = .mediumLarge
    locationCell.descriptionLabel.text = "Map and notification features use your location to display and send you articles."
    locationCell.descriptionLabel.font = .lightLarge
    locationCell.permissionSwitch.isOn = CLLocationManager.authorizationStatus() == .authorizedAlways
    locationCell.permissionSwitch.tag = 1
    locationCell.permissionSwitch.onTintColor = .lightGreyBlue
    locationCell.permissionSwitch.addTarget(self, action: #selector(locationSwitchTriggered(sender:)), for: .valueChanged)
    locationCell.selectionStyle = .none

    let toggleRows: [SettingsRowManager] = [
      SettingsRowManager(tableViewCell: notificationsCell),
      SettingsRowManager(tableViewCell: locationCell)
    ]

    let general = SettingsSectionManager(title: "GENERAL", rows: rows)

    data.append(SettingsSectionManager(title: "PERMISSIONS", rows: toggleRows))

    if let _ = api.authToken {
      let emailCell = UITableViewCell(style: UITableViewCell.CellStyle.value1, reuseIdentifier: nil)
      api.email$
        .bind { email in
          emailCell.textLabel?.text = email ?? "Email Address"
        }.disposed(by: rx.disposeBag)
      emailCell.textLabel?.font = .lightLarge
      emailCell.separatorInset = .zero
      emailCell.detailTextLabel?.text = "Edit"

      let emailManager = SettingsRowManager(tableViewCell: emailCell) {
        self.navigationController?.pushViewController(UpdateEmailViewController(context: self.context), animated: true)
      }

      data.append(SettingsSectionManager(title: "EMAIL", rows: [emailManager]))
    }

    data.append(general)

    return data
  }

  override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    let section = self.sections[section]
    let title = section.title
    let label = UILabel(frame: .zero)
    label.text = "    \(title)"
    label.textColor = .darkGray
    label.font =  .largeBook
    return label
  }

  override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return CGFloat(45);
  }

}
