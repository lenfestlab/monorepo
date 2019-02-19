import UIKit
import CoreLocation
import CoreMotion

class MotionViewController: UIViewController, MotionManagerAuthorizationDelegate {

  // MARK: - Motion manager authorization delegate

  func authorized(_ motionManager: MotionManager, status: CMAuthorizationStatus) {
    print("MotionViewController authorized status: \(status.description)")
    self.analytics.log(.selectsMotionTrackingPermissions(status: status))
    next()
  }

  func notAuthorized(_ motionManager: MotionManager, status: CMAuthorizationStatus) {
    print("MotionViewController notAuthorized status: \(status.description)")
    self.analytics.log(.selectsMotionTrackingPermissions(status: status))
    next()
  }

  var motionManager = MotionManager.shared

  @IBOutlet weak var doneButton: UIButton!

  private let analytics: AnalyticsManager

  init(analytics: AnalyticsManager) {
    self.analytics = analytics
    super.init(nibName: nil, bundle: nil)
    navigationItem.hidesBackButton = true
    motionManager.authorizationDelegate = self
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    let env = Env()
    self.title = env.appName
    if let fontStyle = UIFont(name: "WorkSans-Medium", size: 18) {
      navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.font: fontStyle]
    }
    navigationController?.navigationBar.barTintColor =  UIColor.beige()
    navigationController?.navigationBar.isTranslucent =  false

    doneButton.layer.cornerRadius = 5.0
    doneButton.clipsToBounds = true
    // Do any additional setup after loading the view.
  }

  func next() {
    let application = UIApplication.shared
    let appDelegate = application.delegate as? AppDelegate

    iCloudUserIDAsync() { cloudId, error in
      DispatchQueue.main.async {
        if let cloudId = cloudId {
          print("received iCloudID \(cloudId)")
          appDelegate?.showEmailRegistration(cloudId: cloudId)
        } else {
          print("Fetched iCloudID was nil")
          UserDefaults.standard.set(true, forKey: "onboarding-completed")
          let appDelegate = application.delegate as? AppDelegate
          appDelegate?.showHomeScreen()
        }
      }
    }
  }

  @IBAction func skip(sender: UIButton) {
    self.analytics.log(.tapsSkipMotionButton)
    next()
  }

  @IBAction func done(sender: UIButton) {
    self.analytics.log(.tapsEnableMotionButton)
    self.motionManager.enableMotionDetection(analytics)
  }

}

