import UIKit

extension FilterViewController : NeighborhoodViewControllerDelegate {
  func neighborhoodsUpdated(_ viewController: NeighborhoodViewController, neighborhoods: [Neighborhood]) {
    self.filterModule.nabes = neighborhoods
    updateNeighborhoodButton()
    viewController.dismiss(animated: true, completion: nil)
  }
}

extension FilterViewController : FilterModuleDelegate {
  func filterUpdated(_ viewController: UIViewController, filter: FilterModule) {
    self.filterModule.categories = filter.categories
    updateCusineButton()
    viewController.dismiss(animated: true, completion: nil)
  }
}

extension FilterViewController : AuthorViewControllerDelegate {
  func authorsUpdated(_ viewController: AuthorViewController, authors: [Author]) {
    self.filterModule.authors = authors
    updateReviewerButton()
    viewController.dismiss(animated: true, completion: nil)
  }

}


class FilterViewController: UIViewController {

  weak var filterDelegate: FilterModuleDelegate?

  @IBOutlet weak var starView : UIView!
  @IBOutlet weak var oneStar : UIButton!
  @IBOutlet weak var twoStars : UIButton!
  @IBOutlet weak var threeStars : UIButton!
  @IBOutlet weak var fourStars : UIButton!

  @IBOutlet weak var dollarView : UIView!
  @IBOutlet weak var oneDollar : UIButton!
  @IBOutlet weak var twoDollars : UIButton!
  @IBOutlet weak var threeDollars : UIButton!
  @IBOutlet weak var fourDollars : UIButton!

  @IBOutlet weak var sortView : UIView!
  @IBOutlet weak var distanceButton : UIButton!
  @IBOutlet weak var ratingButton : UIButton!
  @IBOutlet weak var latestButton : UIButton!

  @IBOutlet weak var cusineButton : UIButton!
  @IBOutlet weak var neighborhoodButton : UIButton!
  @IBOutlet weak var reviewerButton : UIButton!
  @IBOutlet weak var searchButton : UIButton!

  private let analytics: AnalyticsManager
  private let filterModule: FilterModule

  func updateReviewerButton() {
    var title = "Choose Reviewers"
    let categories = self.filterModule.authors
    if categories.count == 1 {
      title = categories.first?.name ?? title
    } else if categories.count > 0 {
      title = "\(categories.count) Reviewers Selected"
    }
    self.reviewerButton.setTitle(title, for: .normal)
  }

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

  func styleView(_ view : UIView) {
    view.layer.cornerRadius = 5.0
    view.layer.borderWidth = 1.0
    view.layer.borderColor = UIColor.iconColor().cgColor
    view.clipsToBounds = true
  }

  func styleButton(_ button : UIButton) {
    guard let selectedImage = UIColor.iconColor().pixelImage() else {
      return
    }

    button.setBackgroundImage(selectedImage, for: .selected)
    button.setTitleColor(.white, for: .selected)
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    self.navigationController?.styleController()
    self.title = "Filter"
    self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(dismissFilter))
    self.view.backgroundColor = .white

    styleView(self.sortView)
    styleView(self.dollarView)
    styleView(self.starView)
    styleView(self.cusineButton)
    styleView(self.reviewerButton)
    styleView(self.neighborhoodButton)

    styleButton(self.oneStar)
    styleButton(self.twoStars)
    styleButton(self.threeStars)
    styleButton(self.fourStars)

    styleButton(self.oneDollar)
    styleButton(self.twoDollars)
    styleButton(self.threeDollars)
    styleButton(self.fourDollars)

    styleButton(self.ratingButton)
    styleButton(self.distanceButton)
    styleButton(self.latestButton)

    self.searchButton.layer.cornerRadius = 5.0
    self.searchButton.clipsToBounds = true

    updateCusineButton()
    updateSortButton()
    updateRatingButton()
    updatePriceButton()
    updateNeighborhoodButton()
    updateReviewerButton()
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
    let vc = CuisinesViewController(analytics: self.analytics, filter: self.filterModule)
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

  @IBAction func showReviewers() {
    let vc = AuthorViewController(analytics: self.analytics, selected: self.filterModule.authors)
    vc.delegate = self
    let navigationController = PopupViewController(rootViewController: vc)
    navigationController.popUpHeight = 500
    navigationController.modalPresentationStyle = .overFullScreen
    navigationController.modalTransitionStyle = .crossDissolve
    self.present(navigationController, animated: true, completion: nil)
  }


}
