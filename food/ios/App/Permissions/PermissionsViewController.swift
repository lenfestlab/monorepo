import UIKit
import CoreLocation

class PermissionsViewController: UIViewController, LocationManagerAuthorizationDelegate, Contextual {
  
  @IBOutlet weak var doneButton: UIButton!
  @IBOutlet weak var skipButton: UIButton!
  @IBOutlet weak var stepLabel: UILabel!
  @IBOutlet weak var headerLabel: UILabel!
  @IBOutlet weak var descriptionLabel: UILabel!

  var context: Context

  init(context: Context) {
    self.context = context
    super.init(nibName: nil, bundle: nil)
    navigationItem.hidesBackButton = true
    locationManager.authorizationDelegate = self
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    stepLabel.text = "Step 2 of 3:"

    let env = Env()
    self.title = env.appName
    if let fontStyle = UIFont(name: "WorkSans-Medium", size: 18) {
      navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: fontStyle]
    }
    navigationController?.navigationBar.barTintColor =  UIColor.navigationColor()
    navigationController?.navigationBar.isTranslucent =  false

    doneButton.layer.cornerRadius = 5.0
    doneButton.clipsToBounds = true
    doneButton.setBackgroundImage(UIColor.lightGreyBlue.pixelImage(), for: .normal)

    stepLabel.font = .headerBook
    headerLabel.font = .headerMedium
    descriptionLabel.font = .onboardingLight
    doneButton.titleLabel?.font = .onboardingLight
    skipButton.titleLabel?.font = .skipFont
  }

  func authorized(_ locationManager: LocationManager, status: CLAuthorizationStatus) {
    print("\t PermissionsViewController.authorized status: \(status)")
    self.analytics.log(.selectsLocationTrackingPermissions(status: status))
    next()
  }

  func notAuthorized(_ locationManager: LocationManager, status: CLAuthorizationStatus) {
    print("\t PermissionsViewController.notAuthorized status: \(status)")
    self.analytics.log(.selectsLocationTrackingPermissions(status: status))
    next()
  }

  func next() {
    let application = UIApplication.shared
    guard let appDelegate = application.delegate as? AppDelegate else {
      print("ERROR: MIA: PermissionViewController AppDelegate")
      return
    }
    appDelegate.showEmailRegistration()
  }


  @IBAction func skip(sender: UIButton) {
    self.analytics.log(.tapsSkipLocationButton)
    next()
  }

  @IBAction func done(sender: UIButton) {
    self.analytics.log(.tapsEnableLocationButton)

    let alertController = UIAlertController(
      title: "Allow \"\(env.appName)\" to access your location?",
      message: "\(env.appName) uses your location to send you news about places you go. Please Always Allow access.",
      preferredStyle: .alert)

    let actionTitle1: String
    let actionTitle2: String
    if #available(iOS 13.0, *) {
      actionTitle1 = "Allow While Using App"
      actionTitle2 = "Allow Once"
    } else {
      actionTitle1 = "Only While Using the App"
      actionTitle2 = "Always Allow"
    }
    let action1 = UIAlertAction(title: actionTitle1, style: .default) { (action:UIAlertAction) in
      print(actionTitle1)
      self.locationManager.enableBasicLocationServices()
    }
    alertController.addAction(action1)

    let action2 = UIAlertAction(title: actionTitle2, style: .default) { (action:UIAlertAction) in
      print(actionTitle2)
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
    let gray = UIView(frame: CGRect(x: 0, y: 0, width: 270, height: grayH))
    gray.backgroundColor = UIColor.black.withAlphaComponent(0.1)
    gray.layer.cornerRadius = 11.0
    gray.isUserInteractionEnabled = false
    alertController.view.addSubview(gray)

    let maskY: CGFloat
    let imageSuperviewInset: CGFloat
    if #available(iOS 13.0, *) {
      maskY = 134
      imageSuperviewInset = 80
    } else {
      maskY = 179
      imageSuperviewInset = 40
    }
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
      maskLayer.fillRule = CAShapeLayerFillRule.evenOdd
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
      center = (imageNameSuffix == "Left")
        ? CGPoint(x: widthHalf - imageSuperviewInset, y: centerY)
        : CGPoint(x: (maskW - widthHalf) + imageSuperviewInset, y: centerY)
      arrowImageView.center = center

    }

  }

}

