import UIKit

protocol FilterViewControllerDelegate: class {
  func filterUpdated(_ viewController: FilterViewController, filter: FilterModule)
}

extension FilterViewController : NeighborhoodViewControllerDelegate {
  func neighborhoodsUpdated(_ viewController: NeighborhoodViewController, neighborhoods: [Neighborhood]) {
    self.filterModule.nabes = neighborhoods
    updateNeighborhoodButton()
    viewController.dismiss(animated: true, completion: nil)
  }
}


extension FilterViewController : CuisinesViewControllerDelegate {
  func categoriesUpdated(_ viewController: CuisinesViewController, categories: [Category]) {
    self.filterModule.categories = categories
    updateCusineButton()
    viewController.dismiss(animated: true, completion: nil)
  }
}

class FilterViewController: UIViewController {

  weak var filterDelegate: FilterViewControllerDelegate?

  @IBOutlet weak var oneStar : UIButton!
  @IBOutlet weak var twoStars : UIButton!
  @IBOutlet weak var threeStars : UIButton!
  @IBOutlet weak var fourStars : UIButton!

  @IBOutlet weak var oneDollar : UIButton!
  @IBOutlet weak var twoDollars : UIButton!
  @IBOutlet weak var threeDollars : UIButton!
  @IBOutlet weak var fourDollars : UIButton!

  @IBOutlet weak var distanceButton : UIButton!
  @IBOutlet weak var ratingButton : UIButton!
  @IBOutlet weak var latestButton : UIButton!

  @IBOutlet weak var cusineButton : UIButton!
  @IBOutlet weak var neighborhoodButton : UIButton!
  @IBOutlet weak var reviewerButton : UIButton!

  private let analytics: AnalyticsManager
  private let filterModule: FilterModule

  func updateCusineButton() {
    var title = "Choose Cuisines"
    let categories = self.filterModule.categories
    if categories.count == 1 {
      title = categories.first?.name ?? title
    } else if categories.count > 0 {
      title = "\(categories.count) Categories Selected"
    }
    self.cusineButton.setTitle(title, for: .normal)
  }

  func updateNeighborhoodButton() {
    var title = "Choose Neighborhoods"
    let nabes = self.filterModule.nabes
    if nabes.count == 1 {
      title = nabes.first?.name ?? title
    } else if nabes.count > 0 {
      title = "\(nabes.count) Neighborhoods Selected"
    }
    self.neighborhoodButton.setTitle(title, for: .normal)
  }

  @IBAction func clearAll(_ sender: Any?) {
    self.filterModule.sortMode = .distance
    self.filterModule.ratings = []
    self.filterModule.prices = []
    self.filterModule.categories = []
    self.filterDelegate?.filterUpdated(self, filter: self.filterModule)
  }

  @IBAction func selectDistanceButton(_ sender: Any?) {
    self.filterModule.sortMode = .distance
    updateSortButton()
  }

  @IBAction func selectRatingButton(_ sender: Any?) {
    self.filterModule.sortMode = .rating
    updateSortButton()
  }

  @IBAction func selectLatestButton(_ sender: Any?) {
    self.filterModule.sortMode = .latest
    updateSortButton()
  }

  func updateRatingButton() {
    self.oneStar.isSelected = self.filterModule.ratings.contains(1)
    self.twoStars.isSelected = self.filterModule.ratings.contains(2)
    self.threeStars.isSelected = self.filterModule.ratings.contains(3)
    self.fourStars.isSelected = self.filterModule.ratings.contains(4)
  }

  func updatePriceButton() {
    self.oneDollar.isSelected = self.filterModule.prices.contains(1)
    self.twoDollars.isSelected = self.filterModule.prices.contains(2)
    self.threeDollars.isSelected = self.filterModule.prices.contains(3)
    self.fourDollars.isSelected = self.filterModule.prices.contains(4)
  }

  func updateSortButton() {
    self.ratingButton.isSelected = self.filterModule.sortMode == .rating
    self.latestButton.isSelected = self.filterModule.sortMode == .latest
    self.distanceButton.isSelected = self.filterModule.sortMode == .distance
  }

  init(analytics: AnalyticsManager, filter: FilterModule) {
    self.filterModule = filter
    self.analytics = analytics
    super.init(nibName: nil, bundle: nil)
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    self.navigationController?.styleController()
    self.title = "Filter"
    self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(dismissFilter))
    self.view.backgroundColor = .white

    updateCusineButton()
    updateSortButton()
    updateRatingButton()
    updatePriceButton()
    updateNeighborhoodButton()
  }

  @objc func dismissFilter() {
    self.dismiss(animated: true, completion: nil)
  }

  @IBAction func applyFilter() {
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

    print(ratings)
    print(prices)

    self.filterModule.ratings = ratings
    self.filterModule.prices = prices

    self.filterDelegate?.filterUpdated(self, filter: self.filterModule)
  }


  @IBAction func selectButton(_ sender: Any?) {
    if let button = sender as? UIButton {
      button.isSelected = !button.isSelected
    }
  }

  @IBAction func showCuisines() {
    let vc = CuisinesViewController(analytics: self.analytics, selected: self.filterModule.categories)
    vc.delegate = self
    let navigationController = PopupViewController(rootViewController: vc)
    navigationController.popUpHeight = 500
    navigationController.modalPresentationStyle = .overFullScreen
    navigationController.modalTransitionStyle = .crossDissolve
    self.present(navigationController, animated: true, completion: nil)
  }

  @IBAction func showNeighborhoods() {
    let vc = NeighborhoodViewController(analytics: self.analytics, selected: self.filterModule.nabes)
    vc.delegate = self
    let navigationController = PopupViewController(rootViewController: vc)
    navigationController.popUpHeight = 500
    navigationController.modalPresentationStyle = .overFullScreen
    navigationController.modalTransitionStyle = .crossDissolve
    self.present(navigationController, animated: true, completion: nil)
  }


}
