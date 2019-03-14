import UIKit

class PopupViewController: UIViewController {

  lazy var popUp : UIView! = {
    let popUp = UIView(frame: CGRect(x: 0, y: 0, width: 300, height: 450))
    popUp.backgroundColor = UIColor.white
    popUp.clipsToBounds = true
    popUp.layer.cornerRadius = 5.0
    return popUp
  }()

  var rootViewController : UIViewController!
  var navigationBar : UINavigationBar! = {
    let navigationBar = UINavigationBar()
    return navigationBar
  }()

  init(rootViewController: UIViewController) {
    self.rootViewController = rootViewController
    super.init(nibName: nil, bundle: nil)
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  var popUpHeight = 450 {
    didSet {
      self.popUp.frame = CGRect(x: 0, y: 0, width: 300, height: popUpHeight)
    }
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    self.view.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.5)

    self.addChild(self.rootViewController)

    self.popUp.addSubview(self.rootViewController.view)
    self.popUp.addSubview(self.navigationBar)
    self.view.addSubview(self.popUp)

    self.navigationBar.setItems([self.rootViewController.navigationItem], animated: false)
  }


  override func viewWillLayoutSubviews() {
    self.popUp?.center = self.view.center

    let (top, bottom) = self.popUp.bounds.divided(atDistance: 44.0, from: .minYEdge)

    self.navigationBar.frame = top
    self.rootViewController.view.frame = bottom
  }



}
