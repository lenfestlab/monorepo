import UIKit

class IntroViewController: UIViewController {

  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var descriptionLabel: UILabel!
  @IBOutlet weak var doneButton: UIButton!

  private let analytics: AnalyticsManager

  init(analytics: AnalyticsManager) {
    self.analytics = analytics
    super.init(nibName: nil, bundle: nil)
    navigationItem.hidesBackButton = true
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    self.navigationController?.styleController()

    titleLabel.font = .welcomeFont
    descriptionLabel.font = .onboardingLight

    doneButton.setBackgroundImage(UIColor.lightGreyBlue.pixelImage(), for: .normal)
    doneButton.layer.cornerRadius = 5.0
    doneButton.clipsToBounds = true
    doneButton.titleLabel?.font = .onboardingLight

    self.view.backgroundColor = UIColor.white
  }

  @IBAction func done(sender: UIButton) {
    self.analytics.log(.tapsGetStartedButton)

    let application = UIApplication.shared
    let appDelegate = application.delegate as? AppDelegate
    appDelegate?.showNotifications()
  }

}
