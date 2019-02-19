import UIKit

class EmailViewController: UIViewController {

  private let analytics: AnalyticsManager

  @IBOutlet weak var textField : UITextField!
  @IBOutlet weak var textView : UIView!
  var cloudId : String

  init(analytics: AnalyticsManager, cloudId: String) {
    self.analytics = analytics
    self.cloudId = cloudId
    super.init(nibName: nil, bundle: nil)
    navigationItem.hidesBackButton = true
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    self.styleViewController()

    self.textView.layer.borderWidth = 1
    self.textView.layer.cornerRadius = 10
    self.textView.clipsToBounds = true
    self.textField.becomeFirstResponder()
  }

  @IBAction func skip(sender: UIButton) {
    next()
  }

  func next() {
    UserDefaults.standard.set(true, forKey: "onboarding-completed")
    let application = UIApplication.shared
    let appDelegate = application.delegate as? AppDelegate
    appDelegate?.showHomeScreen()
  }

  @IBAction func submit(_ sender: Any?) {
    guard let button = sender as? UIButton else {
      return
    }

    guard let emailAddress = self.textField.text else {
      return
    }

    button.isEnabled = false

    Installation.update(cloudId: cloudId, emailAddress: emailAddress, completion: { (success, result) in
      DispatchQueue.main.async { [unowned self] in
        if success {
          self.next()
        } else {
          button.isEnabled = true
        }
      }
    })

  }

}
