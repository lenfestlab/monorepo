import UIKit
import UserNotifications

class NotificationViewController: UIViewController, UNUserNotificationCenterDelegate {

  @IBOutlet weak var doneButton: UIButton!

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
    appDelegate?.showHomeScreen()
    UserDefaults.standard.set(true, forKey: "onboarding-completed")
  }

  @IBAction func done(sender: UIButton) {
    let application = UIApplication.shared
    let appDelegate = application.delegate as? AppDelegate
    self.setupRemoteNotifications(application, completionHandler: { (_, _) in
      DispatchQueue.main.async {
        UserDefaults.standard.set(true, forKey: "onboarding-completed")
        appDelegate?.showHomeScreen()
      }
    })
  }

  func setupRemoteNotifications(_ application: UIApplication, completionHandler: @escaping (Bool, Error?) -> Swift.Void) {
    UNUserNotificationCenter.current().delegate = self

    let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
    UNUserNotificationCenter.current().requestAuthorization(options: authOptions) { (success, error) in
      completionHandler(success, error)
    }
  }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
