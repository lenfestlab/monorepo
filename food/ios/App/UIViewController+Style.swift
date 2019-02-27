import UIKit

extension UIViewController {

  func styleViewController() {
    let env = Env()

    self.title = env.appName
    if let fontStyle = UIFont(name: "WorkSans-Medium", size: 18) {
      navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: fontStyle]
    }
    self.style()
  }

  func style() {
    navigationController?.navigationBar.barTintColor =  UIColor.beige()
    navigationController?.navigationBar.tintColor =  UIColor.offRed()
    navigationController?.navigationBar.isTranslucent = false
  }

}
