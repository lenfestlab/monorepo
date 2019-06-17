import UIKit

class UpdateEmailViewController: UIViewController, UITextFieldDelegate, Contextual {


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

  init(context: Context) {
    self.context = context
    super.init(nibName: nil, bundle: nil)
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    self.title = "Email"

    self.textField.delegate = self

    self.textField.text = api.email

    self.navigationController?.styleController()

    self.submitButton.setBackgroundImage(UIColor.lightGreyBlue.pixelImage(), for: .normal)
    self.submitButton.layer.cornerRadius = 5.0
    self.submitButton.clipsToBounds = true

    self.textView.layer.borderWidth = 1
    self.textView.layer.cornerRadius = 10
    self.textView.clipsToBounds = true
    self.textField.becomeFirstResponder()
  }

  func next() {
    self.navigationController?.popViewController(animated: true)
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

    self.analytics.log(.tapsSubmitEmailButton)

    api.updateEmail$(email: emailAddress)
      .subscribe(onNext: { [weak self] _ in
        self?.next()
        }, onError: { [weak self] error in
          self?.submitButton.isEnabled = true
      }).disposed(by: rx.disposeBag)

  }

}
