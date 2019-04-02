import UIKit

extension UINavigationController {

  func styleController() {
    self.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont.titleFont]

    self.navigationBar.barTintColor =  UIColor.navigationColor()
    self.navigationBar.tintColor =  UIColor.darkRed
    self.navigationBar.isTranslucent = false
  }

}
