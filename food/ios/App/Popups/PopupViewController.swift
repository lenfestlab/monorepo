import UIKit

extension UIViewController {

  var popUpViewController: PopupViewController? {
    return self.parent as? PopupViewController
  }

  @objc func dismissPopUp() {
    self.dismiss(animated: true, completion: nil)
  }

}

class PopupViewController: UIViewController {

  var isToolbarHidden: Bool = false {
    didSet {
      self.toolbar.isHidden = isToolbarHidden
    }
  }

  lazy var exitButton : UIView! = {
    let exitButton = UIButton(frame: .zero)
    exitButton.setImage(UIImage(named: "exit-button"), for: .normal)
    exitButton.addTarget(self.rootViewController, action: #selector(dismissPopUp), for: .touchUpInside)
    return exitButton
  }()


  lazy var popUp : UIView! = {
    let popUp = UIView(frame: .zero)
    popUp.backgroundColor = UIColor.white
    popUp.clipsToBounds = true
    popUp.layer.cornerRadius = 5.0
    return popUp
  }()

  var rootViewController : UIViewController!
  var navigationBar : UILabel! = {
    let navigationBar = UILabel()
    navigationBar.backgroundColor = .white
    navigationBar.font = UIFont.filterTitleFont
    navigationBar.textColor = UIColor.lightGreyBlue
    navigationBar.textAlignment = .center
    return navigationBar
  }()

  lazy var toolbar : UIToolbar! = {
    let toolbar = UIToolbar(frame: .zero)
    toolbar.barTintColor = .white
    toolbar.isTranslucent = false
    return toolbar
  }()

  lazy var divider : UIView! = {
    let divider = UIView(frame: .zero)
    divider.backgroundColor = .offWhite
    return divider
  }()

  init(rootViewController: UIViewController) {
    self.rootViewController = rootViewController
    super.init(nibName: nil, bundle: nil)
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  var popUpHeight : CGFloat = 450

  override func viewDidLoad() {
    super.viewDidLoad()
    self.view.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.5)

    self.toolbar.isHidden = isToolbarHidden

    self.addChild(self.rootViewController)

    self.popUp.addSubview(self.rootViewController.view)
    self.popUp.addSubview(self.navigationBar)
    self.popUp.addSubview(self.divider)
    self.popUp.addSubview(self.toolbar)
    self.view.addSubview(self.popUp)
    self.view.addSubview(self.exitButton)

    self.navigationBar.text = self.rootViewController.title

    self.toolbar.setItems(self.rootViewController.toolbarItems, animated: false)
    self.toolbar.tintColor = UIColor.oceanBlue
  }

  func popUpWidth() -> CGFloat {
    return max(self.view.frame.width - 2*28, 280)
  }

  override func viewWillLayoutSubviews() {
    var popUpFrame = self.view.frame
    popUpFrame.size.width = self.popUpWidth()
    popUpFrame.size.height = popUpHeight
    self.popUp?.frame = popUpFrame

    self.popUp?.center.y = self.view.center.y + 10
    self.popUp?.center.x = self.view.center.x

    let (top, remainder) = self.popUp.bounds.divided(atDistance: 71.0, from: .minYEdge)

    let (bottom, content) = remainder.divided(atDistance: 44.0, from: .maxYEdge)

    self.navigationBar.frame = top
    self.divider.frame = CGRect(x: 0, y: self.navigationBar.frame.maxY, width: self.popUpWidth(), height: 1)
    if self.isToolbarHidden {
      self.rootViewController.view.frame = remainder
    } else {
      self.rootViewController.view.frame = content
      self.toolbar.frame = bottom
    }

    let width = CGFloat(30)
    let height = CGFloat(30)
    self.exitButton.frame = CGRect(x: self.popUp.frame.maxX - width/2 - 3,
                                   y: self.popUp.frame.minY - height/2 + 3,
                                   width: width,
                                   height: height)
  }

}
