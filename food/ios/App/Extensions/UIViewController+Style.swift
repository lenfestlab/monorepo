import UIKit

extension UINavigationController {

  func styleController() {
    if let fontStyle = UIFont(name: "WorkSans-Medium", size: 18) {
      self.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: fontStyle]
    }

    self.navigationBar.barTintColor =  UIColor.beige()
    self.navigationBar.tintColor =  UIColor.offRed()
    self.navigationBar.isTranslucent = false
  }

}
