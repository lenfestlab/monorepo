import UIKit
import CoreLocation
import CoreMotion

class MotionViewController: UIViewController, MotionManagerAuthorizationDelegate {

  // MARK: - Motion manager authorization delegate

  func authorized(_ motionManager: MotionManager, status: CMAuthorizationStatus) {
    self.analytics.log(.selectsMotionTrackingPerfmissions(status: status))
    next()
  }

  func notAuthorized(_ motionManager: MotionManager, status: CMAuthorizationStatus) {
    self.analytics.log(.selectsMotionTrackingPerfmissions(status: status))
    next()
  }

  var motionManager = MotionManager.shared

  @IBOutlet weak var doneButton: UIButton!

  private let analytics: AnalyticsManager

  init(analytics: AnalyticsManager) {
    self.analytics = analytics
    super.init(nibName: nil, bundle: nil)
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

    motionManager.authorizationDelegate = self

    doneButton.layer.cornerRadius = 5.0
    doneButton.clipsToBounds = true
    // Do any additional setup after loading the view.
  }

  func next() {
    UserDefaults.standard.set(true, forKey: "onboarding-completed")
    let application = UIApplication.shared
    let appDelegate = application.delegate as? AppDelegate
    appDelegate?.showHomeScreen()
  }

  @IBAction func skip(sender: UIButton) {
    self.analytics.log(.tapsSkipMotionButton)
    next()
  }

  @IBAction func done(sender: UIButton) {
    self.analytics.log(.tapsEnableMotionButton)
    self.motionManager.enableMotionDetection()
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
}

