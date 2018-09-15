import UIKit

class PermissionsViewController: UIViewController, LocationManagerDelegate {
  
  let locationManager = LocationManager()

  @IBOutlet weak var doneButton: UIButton!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    locationManager.delegate = self

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
    let application = UIApplication.shared
    let appDelegate = application.delegate as? AppDelegate
    appDelegate?.showNotifications()
  }

  @IBAction func skip(sender: UIButton) {
    next()
  }

  @IBAction func done(sender: UIButton) {
    locationManager.enableBasicLocationServices()
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }

}

