import UIKit
import UserNotifications

class NotificationViewController: UIViewController, UNUserNotificationCenterDelegate {

  @IBOutlet weak var doneButton: UIButton!
  @IBOutlet weak var stepLabel: UILabel!

  private let analytics: AnalyticsManager
  let notificationManager = NotificationManager.shared

  init(analytics: AnalyticsManager) {
    self.analytics = analytics
    super.init(nibName: nil, bundle: nil)
    navigationItem.hidesBackButton = true
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    let steps = MotionManager.isActivityAvailable() ? 4 : 3
    stepLabel.text = "Step 1 of \(steps):"

    let env = Env()
    self.title = env.appName
    if let fontStyle = UIFont(name: "WorkSans-Medium", size: 18) {
      navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.font: fontStyle]
    }
    navigationController?.navigationBar.barTintColor =  UIColor.beige()
    navigationController?.navigationBar.isTranslucent =  false

    doneButton.layer.cornerRadius = 5.0
    doneButton.clipsToBounds = true
  }

  @IBAction func skip(sender: UIButton) {
    self.analytics.log(.tapsSkipNotifificationsButton)
    let application = UIApplication.shared
    let appDelegate = application.delegate as? AppDelegate
    appDelegate?.showPermissions()
  }

  @IBAction func done(sender: UIButton) {
    self.analytics.log(.tapsGetNotifiedButton)
    let application = UIApplication.shared
    let appDelegate = application.delegate as? AppDelegate
    self.requestAuthorization(application, completionHandler: { (_, _) in
      DispatchQueue.main.async {
        appDelegate?.showPermissions()
      }
    })
  }

  func requestAuthorization(_ application: UIApplication, completionHandler: @escaping (UNAuthorizationStatus, Error?) -> Void) {
    notificationManager.requestAuthorization() { (status, error) in
      completionHandler(status, error)
      self.analytics.log(.selectsNotificationPermissions(authorizationStatus: status))
    }

  }

}
