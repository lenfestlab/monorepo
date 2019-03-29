import UIKit

extension UINavigationController {

  func styleController() {
    if let fontStyle = UIFont(name: "WorkSans-Medium", size: 18) {
      self.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: fontStyle]
    }

    self.navigationBar.barTintColor =  UIColor.navigationColor()
    self.navigationBar.tintColor =  UIColor.darkRed
    self.navigationBar.isTranslucent = false
  }

}
