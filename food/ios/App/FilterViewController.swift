import UIKit

protocol FilterViewControllerDelegate: class {
  func filterUpdated(_ viewController: FilterViewController, ratings: [Int], prices: [Int])
}

class FilterViewController: UIViewController {

  weak var filterDelegate: FilterViewControllerDelegate?

  @IBOutlet weak var oneStar : UIButton!
  @IBOutlet weak var twoStars : UIButton!
  @IBOutlet weak var threeStars : UIButton!
  @IBOutlet weak var fourStars : UIButton!
  @IBOutlet weak var fiveStars : UIButton!

  @IBOutlet weak var oneDollar : UIButton!
  @IBOutlet weak var twoDollars : UIButton!
  @IBOutlet weak var threeDollars : UIButton!
  @IBOutlet weak var fourDollars : UIButton!

  override func viewDidLoad() {
    super.viewDidLoad()
    self.style()
    self.title = "Filter"
    self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(dismissFilter))
    self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Apply", style: .plain, target: self, action: #selector(applyFilter))
    self.view.backgroundColor = UIColor.beige()
  }

  @objc func dismissFilter() {
    self.dismiss(animated: true, completion: nil)
  }

  @objc func applyFilter() {
    var ratings = [Int]()
    var prices = [Int]()
    if self.oneStar.isSelected {
      ratings.append(1)
    }
    if self.twoStars.isSelected {
      ratings.append(2)
    }
    if self.threeStars.isSelected {
      ratings.append(3)
    }
    if self.fourStars.isSelected {
      ratings.append(4)
    }
    if self.fiveStars.isSelected {
      ratings.append(5)
    }
    if self.oneDollar.isSelected {
      prices.append(1)
    }
    if self.twoDollars.isSelected {
      prices.append(2)
    }
    if self.threeDollars.isSelected {
      prices.append(3)
    }
    if self.fourDollars.isSelected {
      prices.append(4)
    }
    self.filterDelegate?.filterUpdated(self, ratings: ratings, prices: prices)
  }


  @IBAction func selectButton(_ sender: Any?) {
    if let button = sender as? UIButton {
      button.isSelected = !button.isSelected
    }
  }

}
