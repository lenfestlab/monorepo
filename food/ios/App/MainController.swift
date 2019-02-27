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

extension MainController: NotificationManagerDelegate {

  func present(_ vc: UIViewController, animated: Bool) {
    present(vc, animated: animated, completion: nil)
  }

  func openInSafari(url: URL) {
    AppDelegate.shared().lastViewedURL = url
    if let presented = self.presentedViewController {
      presented.dismiss(animated: false, completion: { [unowned self] in
        let svc = SFSafariViewController(url: url)
        self.present(svc, animated: true, completion: nil)
      })
    } else {
      let svc = SFSafariViewController(url: url)
      self.present(svc, animated: true, completion: nil)
    }
  }

}
