import UIKit
import SafariServices

class MainController: UINavigationController {

  override init(rootViewController: UIViewController) {
    super.init(rootViewController: rootViewController)
  }

  override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
    super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
  }
  required init?(coder aDecoder: NSCoder) {
    fatalError("storyboards are incompatible with truth and beauty")
  }
}
