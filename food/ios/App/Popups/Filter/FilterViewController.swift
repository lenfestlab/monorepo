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


class FilterViewController: UIViewController, Contextual {


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
  @IBOutlet weak var clearButton : UIButton!
  @IBOutlet weak var searchButton : UIButton!

  @IBOutlet weak var bellsTitle : UILabel!
  @IBOutlet weak var priceTitle : UILabel!
  @IBOutlet weak var cuisineTitle : UILabel!
  @IBOutlet weak var neighborhoodTitle : UILabel!
  @IBOutlet weak var reviewerTitle : UILabel!
  @IBOutlet weak var sortTitle : UILabel!

  @IBOutlet weak var divider : UIView!
  @IBOutlet weak var scrollView : UIScrollView!

  var context: Context
  private let filterModule: FilterModule

  func updateReviewerButton() {
    var title = "Choose Authors"
    self.reviewerButton.setTitle(title, for: .normal)

    let categories = self.filterModule.authors
    if categories.count == 1 {
      title = categories.first?.name ?? title
    } else if categories.count > 0 {
      title = "\(categories.count) Authors Selected"
    }
    self.reviewerButton.setTitle(title, for: .selected)

    self.reviewerButton.isSelected = categories.count > 0
  }

  func updateCusineButton() {
    var title = "Choose Cuisines"
    self.cusineButton.setTitle(title, for: .normal)

    let categories = self.filterModule.categories
    if categories.count == 1 {
      title = categories.first?.name ?? title
    } else if categories.count > 0 {
      title = "\(categories.count) Categories Selected"
    }
    self.cusineButton.setTitle(title, for: .selected)

    self.cusineButton.isSelected = categories.count > 0
  }

  func updateNeighborhoodButton() {
    var title = "Choose Neighborhoods"
    self.neighborhoodButton.setTitle(title, for: .normal)

    let nabes = self.filterModule.nabes
    if nabes.count == 1 {
      title = nabes.first?.name ?? title
    } else if nabes.count > 0 {
      title = "\(nabes.count) Neighborhoods Selected"
    }
    self.neighborhoodButton.setTitle(title, for: .selected)

    self.neighborhoodButton.isSelected = nabes.count > 0
  }

  @IBAction func clearAll() {
    self.filterModule.reset()
    self.filterDelegate?.filterUpdated(self, filter: self.filterModule)
  }

  @IBAction func selectDistanceButton(_ sender: Any?) {
    self.filterModule.sortMode = .distance
    self.analytics.log(.selectsSortFromFilter(mode: self.filterModule.sortMode, category: .filter))
    updateSortButton()
  }

  @IBAction func selectRatingButton(_ sender: Any?) {
    self.filterModule.sortMode = .rating
    self.analytics.log(.selectsSortFromFilter(mode: self.filterModule.sortMode, category: .filter))
    updateSortButton()
  }

  @IBAction func selectLatestButton(_ sender: Any?) {
    self.filterModule.sortMode = .latest
    self.analytics.log(.selectsSortFromFilter(mode: self.filterModule.sortMode, category: .filter))
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

  init(context: Context, filter: FilterModule) {
    self.filterModule = filter
    self.context = context
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
    button.titleLabel?.textAlignment = .center
    button.titleLabel?.font = .lightSmall
    button.setBackgroundImage(UIColor.slate.pixelImage(), for: .selected)
    button.setTitleColor(.white, for: .selected)
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    self.navigationController?.styleController()
    self.title = "Filter"
    self.view.backgroundColor = .white

    divider.backgroundColor = .offWhite
    
    bellsTitle.font = UIFont.mediumSmall
    priceTitle.font = UIFont.mediumSmall
    cuisineTitle.font = UIFont.mediumSmall
    neighborhoodTitle.font = UIFont.mediumSmall
    reviewerTitle.font = UIFont.mediumSmall
    sortTitle.font = UIFont.mediumSmall

    self.popUpViewController?.isToolbarHidden = true

    styleView(self.sortView)
    styleView(self.dollarView)
    styleView(self.starView)
    styleView(self.cusineButton)
    styleView(self.reviewerButton)
    styleView(self.neighborhoodButton)
    self.cusineButton.titleLabel?.lineBreakMode = .byTruncatingTail
    self.reviewerButton.titleLabel?.lineBreakMode = .byTruncatingTail
    self.neighborhoodButton.titleLabel?.lineBreakMode = .byTruncatingTail

    styleButton(self.cusineButton)
    styleButton(self.reviewerButton)
    styleButton(self.neighborhoodButton)

    styleButton(self.oneStar)
    self.oneStar.setAttributedTitle(NSAttributedString.bells(count: 1, selected: false), for: .normal)
    self.oneStar.setAttributedTitle(NSAttributedString.bells(count: 1, selected: true), for: .selected)

    styleButton(self.twoStars)
    self.twoStars.setAttributedTitle(NSAttributedString.bells(count: 2, selected: false), for: .normal)
    self.twoStars.setAttributedTitle(NSAttributedString.bells(count: 2, selected: true), for: .selected)

    styleButton(self.threeStars)
    self.threeStars.setAttributedTitle(NSAttributedString.bells(count: 3, selected: false), for: .normal)
    self.threeStars.setAttributedTitle(NSAttributedString.bells(count: 3, selected: true), for: .selected)

    styleButton(self.fourStars)
    self.fourStars.setAttributedTitle(NSAttributedString.bells(count: 4, selected: false), for: .normal)
    self.fourStars.setAttributedTitle(NSAttributedString.bells(count: 4, selected: true), for: .selected)


    styleDollarButton(self.oneDollar, count: 1)
    styleDollarButton(self.twoDollars, count: 2)
    styleDollarButton(self.threeDollars, count: 3)
    styleDollarButton(self.fourDollars, count: 4)

    styleButton(self.ratingButton)
    styleButton(self.distanceButton)
    self.distanceButton.titleLabel?.numberOfLines = 0
    styleButton(self.latestButton)

    self.clearButton.titleLabel?.textColor = UIColor.oceanBlue
    self.clearButton.titleLabel?.font = UIFont.largeBook

    self.searchButton.backgroundColor = UIColor.lightGreyBlue
    self.searchButton.titleLabel?.font = UIFont.lightLarge
    self.searchButton.layer.cornerRadius = 5.0
    self.searchButton.clipsToBounds = true

    updateCusineButton()
    updateSortButton()
    updateRatingButton()
    updatePriceButton()
    updateNeighborhoodButton()
    updateReviewerButton()

    // flash scrollbar to show content exists below the fold.
    self.rx.methodInvoked(#selector(UIViewController.viewDidAppear(_:)))
      .subscribe({ [weak self] _ in
        self?.scrollView.flashScrollIndicators()
      })
      .disposed(by: rx.disposeBag)

  }

  func styleDollarButton(_ button: UIButton, count: Int) {
    styleButton(button)
    button.titleLabel?.font = UIFont.lightLarge
    button.setAttributedTitle(NSMutableAttributedString.dollarSymbols(count: count, font: UIFont.lightLarge, color: .black), for: .normal)
    button.setAttributedTitle(NSMutableAttributedString.dollarSymbols(count: count, font: UIFont.lightLarge, color: .white), for: .selected)
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

    self.filterModule.ratings = ratings
    self.filterModule.prices = prices

    self.analytics.log(.selectsMultipleCriteriaToFilterBy(filterModule: self.filterModule, mode: self.filterModule.sortMode))
    self.filterDelegate?.filterUpdated(self, filter: self.filterModule)
  }


  @IBAction func selectButton(_ sender: Any?) {
    if let button = sender as? UIButton {
      button.isSelected = !button.isSelected
    }
  }

  @IBAction func showCuisines() {
    let vc = CuisinesViewController(context: self.context, filter: self.filterModule)
    vc.delegate = self
    let navigationController = PopupViewController(rootViewController: vc)
    let screenHeight = AppDelegate.shared().window?.frame.size.height ?? 568
    navigationController.popUpHeight = max(screenHeight - 130 - 122, 568 - 20 - 40)
    navigationController.modalPresentationStyle = .overFullScreen
    navigationController.modalTransitionStyle = .crossDissolve
    self.present(navigationController, animated: true, completion: nil)
  }

  @IBAction func showNeighborhoods() {
    let vc = NeighborhoodViewController(context: context, selected: self.filterModule.nabes)
    vc.delegate = self
    let navigationController = PopupViewController(rootViewController: vc)
    let screenHeight = AppDelegate.shared().window?.frame.size.height ?? 568
    navigationController.popUpHeight = max(screenHeight - 130 - 122, 568 - 20 - 40)
    navigationController.modalPresentationStyle = .overFullScreen
    navigationController.modalTransitionStyle = .crossDissolve
    self.present(navigationController, animated: true, completion: nil)
  }

  @IBAction func showReviewers() {
    let vc = AuthorViewController(context: context, selected: self.filterModule.authors)
    vc.delegate = self
    let navigationController = PopupViewController(rootViewController: vc)
    navigationController.popUpHeight = 282
    navigationController.modalPresentationStyle = .overFullScreen
    navigationController.modalTransitionStyle = .crossDissolve
    self.present(navigationController, animated: true, completion: nil)
  }


}
