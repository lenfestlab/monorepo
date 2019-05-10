import UIKit
import UserNotifications

class NotificationViewController: UIViewController, UNUserNotificationCenterDelegate {

  @IBOutlet weak var doneButton: UIButton!
  @IBOutlet weak var skipButton: UIButton!
  @IBOutlet weak var stepLabel: UILabel!
  @IBOutlet weak var headerLabel: UILabel!
  @IBOutlet weak var descriptionLabel: UILabel!

  private let analytics: AnalyticsManager
  let notificationManager: NotificationManager

  init(
    analytics: AnalyticsManager,
    notificationManager: NotificationManager
    ) {
    self.analytics = analytics
    self.notificationManager = notificationManager
    super.init(nibName: nil, bundle: nil)
    navigationItem.hidesBackButton = true
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    stepLabel.text = "Step 1 of 3:"

    self.navigationController?.styleController()

    doneButton.setBackgroundImage(UIColor.lightGreyBlue.pixelImage(), for: .normal)
    doneButton.layer.cornerRadius = 5.0
    doneButton.clipsToBounds = true

    stepLabel.font = .headerBook
    headerLabel.font = .headerMedium
    descriptionLabel.font = .onboardingLight
    doneButton.titleLabel?.font = .onboardingLight
    skipButton.titleLabel?.font = .skipFont
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
      DispatchQueue.main.async {
        self.analytics.log(.selectsNotificationPermissions(authorizationStatus: status))
      }
    }

  }

}
