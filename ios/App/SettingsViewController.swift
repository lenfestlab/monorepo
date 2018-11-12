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
  private let motionManager = MotionManager.shared

  init(analytics: AnalyticsManager) {
    self.analytics = analytics
    self.env = Env()
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
      } else if let url = URL(string: UIApplicationOpenSettingsURLString) {
        // If general location settings are enabled then open location settings for the app
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
      }

    case 1:
      print("Access Location")
      analytics.log(.changeLocationSettings(enabled: sender.isOn))
      if CLLocationManager.authorizationStatus() == .notDetermined {
        locationManager.enableBasicLocationServices()
      } else if let url = URL(string: UIApplicationOpenSettingsURLString) {
        // If general location settings are enabled then open location settings for the app
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
      }

    case 2:
      print("Access Motion")
      analytics.log(.changeMotionSettings(enabled: sender.isOn))
      if motionManager.hasStatus(.notDetermined) {
        motionManager.enableMotionDetection(analytics)
      } else if let url = URL(string: UIApplicationOpenSettingsURLString) {
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
        "path":"about",
        ],
      [
        "identifier": "default",
        "title":"Privacy Policy",
        "path":"privacy",
        ],
      [
        "identifier": "default",
        "title":"Terms of Service",
        "path":"tos",
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

    if MotionManager.isActivityAvailable() {
      toggleRows.append(
        [
          "identifier": "setting",
          "title": "Enable Motion Detection",
          "description": "This app monitors your motion so you don’t get notifications while you are driving.",
          "toggle": motionManager.isAuthorized
        ]
      )
    }

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

    self.settings = [
      [
        "title": "PERMISSIONS",
        "rows": toggleRows
      ],
      [
        "title": "GENERAL",
        "rows": rows
      ]
    ]

  }

  var settings:[[String:Any?]] = [[:]]

  override func viewDidLoad() {
    super.viewDidLoad()

    self.tableView.separatorColor = UIColor.init(red: 241/255, green: 221/255, blue: 187/255, alpha: 1)

    loadSettings()
    notification = NotificationCenter.default.addObserver(forName: .UIApplicationWillEnterForeground, object: nil, queue: .main) {
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

    tableView.rowHeight = UITableViewAutomaticDimension
    tableView.estimatedRowHeight = 125

    let nib = UINib.init(nibName: "SettingsToggleCell", bundle: nil)
    tableView.register(nib, forCellReuseIdentifier: "setting")

    tableView.register(UITableViewCell.self, forCellReuseIdentifier: "default")
  }

  override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
    guard section == (settings.count - 1) else { return nil }

    let feedbackButton = UIButton(type: .custom)
    feedbackButton.layer.cornerRadius = 5.0
    feedbackButton.clipsToBounds = true
    feedbackButton.backgroundColor = UIColor.ziggurat
    feedbackButton.setTitleColor(.black, for: .normal)
    feedbackButton.titleLabel?.font = UIFont(name: "WorkSans-Regular", size: 19)
    feedbackButton.setTitle("Share Your Feedback", for: .normal)
    feedbackButton
      .rx.tap
      .asDriver()
      .drive(onNext: { [unowned self] _ in
        self.sendFeedback(
          to: ["sarah.schmalbach@gmail.com"],
          subject: "Feedback for \(self.env.appName)")
      })
      .disposed(by: self.rx.disposeBag)

    let footerView = UIView()
    footerView.addSubview(feedbackButton)
    feedbackButton.snp.makeConstraints { (make) in
      make.centerX.equalToSuperview()
      make.height.equalTo(45)
      make.width.equalTo(280)
      make.topMargin.equalToSuperview().inset(24)
      make.bottomMargin.equalToSuperview().inset(15)
    }

    footerView.isHidden = !MFMailComposeViewController.canSendMail()

    return footerView
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
    label.textColor = UIColor.gray
    label.font =  UIFont(name: "WorkSans-Medium", size: 16)
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
      cell.descriptionLabel.text = row["description"] as? String
      cell.permissionSwitch.isOn = row["toggle"] as? Bool == true
      cell.permissionSwitch.tag = indexPath.row
      cell.delegate = self
      cell.selectionStyle = .none
      return cell
    } else {
      let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath)
      cell.textLabel?.text = row["title"] as? String
      cell.textLabel?.font = UIFont(name: "WorkSans-Medium", size: 16)
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
      let url = URL(string: "\(env.apiBaseUrlString)/\(path)")
      let svc = SFSafariViewController(url: url!)
      self.present(svc, animated: true)
    }
  }

}

import MessageUI

extension SettingsViewController: MFMailComposeViewControllerDelegate {

  func sendFeedback(to: [String], subject: String) {
    let mailComposerVC = MFMailComposeViewController()
    mailComposerVC.mailComposeDelegate = self
    mailComposerVC.setToRecipients(to)
    mailComposerVC.setSubject(subject)
    mailComposerVC.setMessageBody("", isHTML: false)
    present(mailComposerVC, animated: true, completion: nil)
  }

  func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
    controller.dismiss(animated: true, completion: nil)
  }

}
