import UIKit

extension UIViewController {

  func styleViewController() {
    if let fontStyle = UIFont(name: "WorkSans-Medium", size: 18) {
      navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: fontStyle]
    }

    navigationController?.navigationBar.barTintColor =  UIColor.beige()
    navigationController?.navigationBar.tintColor =  UIColor.offRed()
    navigationController?.navigationBar.isTranslucent = false
  }

}
