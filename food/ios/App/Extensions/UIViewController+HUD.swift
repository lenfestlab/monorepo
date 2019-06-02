import UIKit
import SVProgressHUD

enum HUD {

  enum ChangeHUDAction { case show, hide }
  static func change(_ action: ChangeHUDAction) {
    switch action {
    case .show:
      SVProgressHUD.show()
      SVProgressHUD.setForegroundColor(UIColor.slate)
    case .hide:
      SVProgressHUD.dismiss()
    }
  }

}
