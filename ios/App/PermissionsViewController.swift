import UIKit
import CoreLocation

class PermissionsViewController: UIViewController, LocationManagerAuthorizationDelegate {
  
  var locationManager = LocationManager.shared

  @IBOutlet weak var doneButton: UIButton!
  @IBOutlet weak var stepLabel: UILabel!

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

    let steps = MotionManager.isActivityAvailable() ? 3 : 2
    stepLabel.text = "Step 2 of \(steps):"

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
    locationManager.startMonitoringSignificantLocationChanges()
    self.analytics.log(.selectsLocationTrackingPermissions(status: status))
    next()
  }

  func notAuthorized(_ locationManager: LocationManager, status: CLAuthorizationStatus) {
    self.analytics.log(.selectsLocationTrackingPermissions(status: status))
    next()
  }
  
  func next() {
    let application = UIApplication.shared
    let appDelegate = application.delegate as? AppDelegate
    if MotionManager.isActivityAvailable() {
      appDelegate?.showMotionPermissions()
    } else {
      UserDefaults.standard.set(true, forKey: "onboarding-completed")
      appDelegate?.showHomeScreen()
    }
  }

  @IBAction func skip(sender: UIButton) {
    self.analytics.log(.tapsSkipLocationButton)
    next()
  }

  @IBAction func done(sender: UIButton) {
    self.analytics.log(.tapsEnableLocationButton)
    let env = Env()

    let alertController = UIAlertController(
      title: "Allow \"\(env.appName)\" to access your location?",
      message: "\(env.appName) uses your location to send you news about places you go. Please Always Allow access.",
      preferredStyle: .alert)

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

    let grayH: CGFloat = 267.5 // from view hierarchy debugger
    let gray = UIView(frame: CGRect.init(x: 0, y: 0, width: 270, height: grayH))
    gray.backgroundColor = UIColor.black.withAlphaComponent(0.1)
    gray.layer.cornerRadius = 11.0
    gray.isUserInteractionEnabled = false
    alertController.view.addSubview(gray)

    let maskY: CGFloat = 179 // eyeballed
    let maskH: CGFloat = 44
    let maskW: CGFloat = 270
    let maskRect = CGRect(x: 0, y: maskY, width: maskW, height: maskH)
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

    // arrows
    let arrowsContainerView = UIView(frame: gray.frame)
    arrowsContainerView.isUserInteractionEnabled = false
    arrowsContainerView.backgroundColor = .clear
    alertController.view.addSubview(arrowsContainerView)
    ["Left", "Right"].forEach { imageNameSuffix in
      let arrowImageName = "arrow\(imageNameSuffix)"
      let arrowImage = UIImage(named: arrowImageName)!
      let arrowImageView = UIImageView(image: arrowImage)
      arrowImageView.isUserInteractionEnabled = false

      arrowsContainerView.addSubview(arrowImageView)

      let size = arrowImage.size
      let width = size.width
      let widthHalf = width / 2
      let center: CGPoint
      let centerY: CGFloat = (maskY + (maskH / 2))
      let imageSuperviewInset: CGFloat = 40 // eyeballed
      center = (imageNameSuffix == "Left")
        ? CGPoint(x: widthHalf - imageSuperviewInset, y: centerY)
        : CGPoint(x: (maskW - widthHalf) + imageSuperviewInset, y: centerY)
      arrowImageView.center = center

    }

  }

}

