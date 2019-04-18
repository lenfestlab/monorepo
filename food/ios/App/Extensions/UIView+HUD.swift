import UIKit
import SVProgressHUD

extension UIView {

  static func flashHUD(_ status: String) {
    SVProgressHUD.showSuccess(withStatus: status)
    SVProgressHUD.dismiss(withDelay: 0.5)
  }

}
