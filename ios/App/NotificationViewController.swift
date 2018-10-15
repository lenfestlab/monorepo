import UIKit
import UserNotifications

class NotificationViewController: UIViewController, UNUserNotificationCenterDelegate {

  @IBOutlet weak var doneButton: UIButton!

  private let analytics: AnalyticsManager
  let notificationManager = NotificationManager.shared

  init(analytics: AnalyticsManager) {
    self.analytics = analytics
    super.init(nibName: nil, bundle: nil)
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    self.title = "Here"
    if let fontStyle = UIFont(name: "WorkSans-Medium", size: 18) {
      navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.font: fontStyle]
    }
    navigationController?.navigationBar.barTintColor =  UIColor.beige()
    navigationController?.navigationBar.isTranslucent =  false

    doneButton.layer.cornerRadius = 5.0
    doneButton.clipsToBounds = true
  }

  @IBAction func skip(sender: UIButton) {
    let application = UIApplication.shared
    let appDelegate = application.delegate as? AppDelegate
    appDelegate?.showPermissions()
  }

  @IBAction func done(sender: UIButton) {
    self.analytics.log(.tapsGetNotifiedButton)
    let application = UIApplication.shared
    let appDelegate = application.delegate as? AppDelegate
    self.setupRemoteNotifications(application, completionHandler: { (_, _) in
      DispatchQueue.main.async {
        appDelegate?.showPermissions()
      }
    })
  }

  func setupRemoteNotifications(_ application: UIApplication, completionHandler: @escaping (UNAuthorizationStatus, Error?) -> Swift.Void) {
    UNUserNotificationCenter.current().delegate = self

    notificationManager.requestAuthorization() { (status, error) in
      completionHandler(status, error)
      self.analytics.log(.selectsNotificationPermissions(authorizationStatus: status))
    }
        
  }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
