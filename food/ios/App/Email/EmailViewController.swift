import UIKit

class EmailViewController: UIViewController, UITextFieldDelegate, Contextual {

  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    textField.resignFirstResponder()
    submit(nil)
    return true
  }

  var context: Context

  @IBOutlet weak var submitButton : UIButton!
  @IBOutlet weak var textField : UITextField!
  @IBOutlet weak var textView : UIView!
  @IBOutlet weak var errorLabel : UILabel!

  @IBOutlet weak var skipButton: UIButton!
  @IBOutlet weak var stepLabel: UILabel!
  @IBOutlet weak var headerLabel: UILabel!

  init(context: Context) {
    self.context = context
    super.init(nibName: nil, bundle: nil)
    navigationItem.hidesBackButton = true
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    self.textField.delegate = self

    self.navigationController?.styleController()

    self.textView.layer.borderWidth = 1
    self.textView.layer.cornerRadius = 10
    self.textView.clipsToBounds = true
    self.textField.font = .textFieldFont
//    self.textField.becomeFirstResponder()

    stepLabel.font = .headerBook
    headerLabel.font = .headerMedium
    errorLabel.font = .onboardingLight
    submitButton.titleLabel?.font = .onboardingLight
    skipButton.titleLabel?.font = .skipFont

    submitButton.layer.cornerRadius = 5.0
    submitButton.clipsToBounds = true
    submitButton.setBackgroundImage(UIColor.lightGreyBlue.pixelImage(), for: .normal)

  }

  @IBAction func skip(sender: UIButton) {
    self.analytics.log(.tapsSkipEmailButton)
    next()
  }

  func next() {
    UserDefaults.standard.set(true, forKey: "onboarding-completed")
    let application = UIApplication.shared
    let appDelegate = application.delegate as? AppDelegate
    appDelegate?.showHomeScreen()
  }

  func isValidEmail(string: String) -> Bool {
    let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"

    let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
    return emailTest.evaluate(with: string)
  }


  @IBAction func submit(_ sender: Any?) {
    guard let button = self.submitButton else {
      return
    }

    guard let text = self.textField.text else {
      errorLabel.text = "Missing email address"
      return
    }

    let emailAddress = text.trimmingCharacters(in: .whitespacesAndNewlines)

    if emailAddress.count == 0 {
      errorLabel.text = "Missing email address"
      return
    }

    if !isValidEmail(string: emailAddress) {
      errorLabel.text = "Invalid email address"
      return
    }

    errorLabel.text = ""

    button.isEnabled = false

    analytics.log(.tapsSubmitEmailButton)

    api.updateEmail$(email: emailAddress)
      .subscribe(onNext: { [weak self] _ in
          self?.next()
        }, onError: { [weak self] error in
          self?.submitButton.isEnabled = true
      }).disposed(by: rx.disposeBag)

  }

}
