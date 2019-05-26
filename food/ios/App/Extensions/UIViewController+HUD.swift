import UIKit
import SVProgressHUD

extension UIViewController {

  enum ChangeHUDAction { case show, hide }
  func spinner(_ action: ChangeHUDAction) {
    switch action {
    case .show:
      SVProgressHUD.show()
      SVProgressHUD.setForegroundColor(UIColor.slate)
    case .hide:
      SVProgressHUD.dismiss()
    }
  }

}
