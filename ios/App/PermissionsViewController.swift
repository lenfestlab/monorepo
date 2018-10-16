import UIKit
import CoreLocation

class PermissionsViewController: UIViewController, LocationManagerAuthorizationDelegate {
  
  var locationManager = LocationManager.shared

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

    self.title = "Here"
    if let fontStyle = UIFont(name: "WorkSans-Medium", size: 18) {
      navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.font: fontStyle]
    }
    navigationController?.navigationBar.barTintColor =  UIColor.beige()
    navigationController?.navigationBar.isTranslucent =  false

    locationManager.authorizationDelegate = self

    doneButton.layer.cornerRadius = 5.0
    doneButton.clipsToBounds = true
    // Do any additional setup after loading the view.
  }

  func authorized(_ locationManager: LocationManager, status: CLAuthorizationStatus) {
    self.analytics.log(.selectsLocationTrackingPerfmissions(status: status))
    next()
  }

  func notAuthorized(_ locationManager: LocationManager, status: CLAuthorizationStatus) {
    self.analytics.log(.selectsLocationTrackingPerfmissions(status: status))
    next()
  }
  
  func next() {
    UserDefaults.standard.set(true, forKey: "onboarding-completed")
    let application = UIApplication.shared
    let appDelegate = application.delegate as? AppDelegate
    appDelegate?.showHomeScreen()
  }

  @IBAction func skip(sender: UIButton) {
    next()
  }

  @IBAction func done(sender: UIButton) {
    self.analytics.log(.tapsEnableLocationButton)

    let alertController = UIAlertController(title: "Hi! Please choose \"Always Allow\"", message: "This lets us send you notifications while you walk around town.", preferredStyle: .alert)

    let action1 = UIAlertAction(title: "Got it!", style: .default) { (action:UIAlertAction) in
      print("You've pressed default");
      self.locationManager.enableBasicLocationServices()
    }

    alertController.addAction(action1)
    self.present(alertController, animated: true, completion: nil)

  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
}

