import UIKit

class CloudViewController: UIViewController {

  @IBOutlet weak var indicatorView: UIActivityIndicatorView!

  override func viewDidLoad() {
    super.viewDidLoad()
    indicatorView.startAnimating()
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }

}
