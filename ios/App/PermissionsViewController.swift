import UIKit
import CoreLocation

class PermissionsViewController: UIViewController, LocationManagerAuthorizationDelegate {
  
  var locationManager = LocationManager()

  @IBOutlet weak var doneButton: UIButton!

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

  func authorized(_ locationManager: LocationManager) {
    next()
  }

  func notAuthorized(_ locationManager: LocationManager) {
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

