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

    let env = Env()
    self.title = env.appName
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
    self.analytics.log(.tapsSkipLocationButton)
    next()
  }

  @IBAction func done(sender: UIButton) {
    self.analytics.log(.tapsEnableLocationButton)

    let alertController = UIAlertController(title: "Allow \"HERE\" to access your location?", message: "We monitor your location to notify you when you are near interesting spots.", preferredStyle: .alert)

    let action1 = UIAlertAction(title: "Only While Using the App", style: .default) { (action:UIAlertAction) in
      print("Only While Using the App");
      self.locationManager.enableBasicLocationServices()
    }
    alertController.addAction(action1)

    let action2 = UIAlertAction(title: "Always Allow", style: .default) { (action:UIAlertAction) in
      print("You've pressed default");
      self.locationManager.enableBasicLocationServices()
    }
    alertController.addAction(action2)

    let action3 = UIAlertAction(title: "Don't Allow", style: .default) { (action:UIAlertAction) in
      print("Don't Allow");
      self.locationManager.enableBasicLocationServices()
    }
    alertController.addAction(action3)

    self.present(alertController, animated: true, completion: nil)

    let gray = UIView(frame: CGRect.init(x: 0, y: 0, width: 270, height: 252))
    gray.backgroundColor = UIColor.black.withAlphaComponent(0.1)
    gray.layer.cornerRadius = 11.0
    gray.clipsToBounds = true
    gray.isUserInteractionEnabled = false
    alertController.view.addSubview(gray)
    alertController.view.clipsToBounds = true

    let maskRect = CGRect.init(x: 0, y: 163, width: 270, height: 44)
    let invert = true
    let viewToMask = gray

    let maskLayer = CAShapeLayer()
    let path = CGMutablePath()
    if (invert) {
      path.addRect(viewToMask.bounds)
    }
    path.addRect(maskRect)

    maskLayer.path = path
    if (invert) {
      maskLayer.fillRule = kCAFillRuleEvenOdd
    }

    // Set the mask of the view.
    viewToMask.layer.mask = maskLayer;

  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
}

