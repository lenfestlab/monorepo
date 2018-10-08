import UIKit
import CoreLocation
import UserNotifications
import SafariServices

class SettingsViewController: UITableViewController, SettingsToggleCellDelegate, LocationManagerAuthorizationDelegate {
  
  let locationManager = LocationManager()
  private var notification: NSObjectProtocol?
  
  deinit {
    // make sure to remove the observer when this view controller is dismissed/deallocated
    
    if let notification = notification {
      NotificationCenter.default.removeObserver(notification)
    }
  }
  
  func authorized(_ locationManager: LocationManager) {
    self.loadSettings()
    self.tableView.reloadData()
  }
  
  func notAuthorized(_ locationManager: LocationManager) {
    self.loadSettings()
    self.tableView.reloadData()
  }
  
  func switchTriggered(sender: UISwitch) {
    switch sender.tag {
    case 0:
      print("Enable Notifications")
      
      if NotificationManager.shared.authorizationStatus == .notDetermined {
        NotificationManager.shared.requestAuthorization() { (success, error) in
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
      if CLLocationManager.authorizationStatus() == .notDetermined {
        locationManager.enableBasicLocationServices()
      } else if let url = URL(string: UIApplicationOpenSettingsURLString) {
        // If general location settings are enabled then open location settings for the app
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
      }
    default:
      print("unknown switch")
    }
  }
  
  func loadSettings() {
    
    self.settings =
      [
        [
          "title":"PERMISSIONS",
          "rows":[
            [
              "identifier": "setting",
              "title":"Enable Notifications",
              "description":"This App uses push notifications to send you related articles based on where you are.",
              "toggle": NotificationManager.shared.authorizationStatus == .authorized
            ],
            [
              "identifier": "setting",
              "title":"Access Location",
              "description":"This App serves best with access to your location. Map and notification features uses your location to display and send content from your nearby locations.",
              "toggle": CLLocationManager.authorizationStatus() == .authorizedAlways
            ]
          ]
        ],
        [
          "title":"GENERAL",
          "rows":[
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
              "title":"Term of Service",
              "path":"tos",
              ],
            [
              "identifier": "button",
              "title":"Leave Your Feedback",
              "action":"feedback"
              ]
          ]
        ]
        
    ]
    
  }
  
  override init(style: UITableViewStyle) {
    super.init(style: style)
    
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  var settings:[[String:Any?]] = [[:]]
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.tableView.separatorColor = UIColor.init(red: 241/255, green: 221/255, blue: 187/255, alpha: 1)
    
    locationManager.authorizationDelegate = self
    
    loadSettings()
    notification = NotificationCenter.default.addObserver(forName: .UIApplicationWillEnterForeground, object: nil, queue: .main) {
      [unowned self] notification in
      NotificationManager.shared.refreshAuthorizationStatus {
        self.loadSettings()
        DispatchQueue.main.async {
          self.tableView.reloadData()
        }
      }
    }
    
    self.title = "Settings"
    if let fontStyle = UIFont(name: "WorkSans-Medium", size: 18) {
      navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.font: fontStyle]
    }
    navigationController?.navigationBar.barTintColor =  UIColor.beige()
    navigationController?.navigationBar.tintColor =  UIColor.offRed()
    navigationController?.navigationBar.isTranslucent =  false
    
    self.tableView.backgroundColor = UIColor.white
    
    tableView.rowHeight = UITableViewAutomaticDimension
    tableView.estimatedRowHeight = 125
    
    let nib = UINib.init(nibName: "SettingsToggleCell", bundle: nil)
    tableView.register(nib, forCellReuseIdentifier: "setting")
    
    let buttonNib = UINib.init(nibName: "ButtonCell", bundle: nil)
    tableView.register(buttonNib, forCellReuseIdentifier: "button")
    
    tableView.register(UITableViewCell.self, forCellReuseIdentifier: "default")
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
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
    return CGFloat(55);
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
    } else if identifier == "button" {
      let cell:ButtonCell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! ButtonCell
      cell.button.titleLabel?.text = row["title"] as? String
      cell.selectionStyle = .none
      return cell
    } else {
      let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath)
      cell.textLabel?.text = row["title"] as? String
      cell.textLabel?.font = UIFont(name: "WorkSans-Medium", size: 16)
      cell.detailTextLabel?.text = row["description"] as? String
      cell.accessoryView = UIImageView(image: UIImage(named: "disclosure-indicator"))
      return cell
    }
  }
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let section = settings[indexPath.section]
    let rows = section["rows"] as! [Any]
    let row = rows[indexPath.row] as! [String:Any]
    if let path = row["path"] as? String {
      let bundle = Bundle(for: type(of: self))
      let envName = bundle.object(forInfoDictionaryKey: "ENV_NAME") as! String
      let prot = (envName == "prod") ? "https" : "http"
      let apiHost = bundle.object(forInfoDictionaryKey: "API_HOST") as! String
      let url = URL(string: "\(prot)://\(apiHost)/\(path)")
      let svc = SFSafariViewController(url: url!)
      self.present(svc, animated: true)
    } else if let action = row["action"] as? String {
      if action == "feedback" {
        sendFeedback(to: ["sarah.schmalbach@gmail.com"], subject: "Feedback for Here")
      }
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
