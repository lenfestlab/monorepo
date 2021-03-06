import UIKit
import AlamofireImage
import UPCarouselFlowLayout
import RxSwift
import RxRealm
import DifferenceKit

class GuideGroupCell: UITableViewCell {

  var controllerIdentifierKey : String = "guide-group-cell"

  @IBOutlet weak var guideLabel: UILabel?
  @IBOutlet weak var allButton: UIButton?
  @IBOutlet weak var descriptionLabel: UILabel?
  @IBOutlet weak var containerView: UIView!
  @IBOutlet weak var collectionView: UICollectionView!
  @IBOutlet weak var heightConstraint: NSLayoutConstraint!
  @IBOutlet weak var leadingConstraint: NSLayoutConstraint!
  static let reuseIdentifier = "GuideGroupCell"

  var guideGroup: GuideGroup?
  typealias Guide = Category
  var guides: [Guide] = [] {
    didSet {
      if self.guideGroup?.guidesCount == 1 {
        self.heightConstraint.constant = 265
      } else {
        self.heightConstraint.constant = 255
      }
    }
  }
  var bag = DisposeBag()

  weak var navigationController: UINavigationController?
  var context: Context?
  var showIndex = false {
    didSet {
      self.collectionView.reloadData()
    }
  }

  @IBAction func seeAll() {
    if let context = context, let guideGroup = self.guideGroup {
      context.analytics.log(.tapsGuideGroupCellSeeAllButton(guideGroup: guideGroup))
      let guides = guideGroup.guides
      if
        self.guideGroup?.guidesCount == 1,
        let guide = guides.first {
        let vc = GuideViewController(context: context, category: guide)
        vc.title = guide.name
        vc.topBarIsHidden = true
        self.navigationController?.pushViewController(vc, animated: true)
      } else {
        let guidesViewController =
          GuidesViewController(
            context: context,
            guideGroup: guideGroup)
        self.navigationController?.pushViewController(guidesViewController, animated: true)
      }
    }
  }

  override func awakeFromNib() {
    super.awakeFromNib()
    self.collectionView.register(UINib(nibName: "GuideCollectionCell", bundle:nil), forCellWithReuseIdentifier: GuideCollectionCell.reuseIdentifier)
    self.collectionView.register(UINib(nibName: "PlaceCell", bundle:nil), forCellWithReuseIdentifier: PlaceCell.reuseIdentifier)
    self.allButton?.titleLabel?.font = UIFont.italicSmall
    self.allButton?.setTitleColor(.slate, for: .normal)
    self.guideLabel?.font = UIFont.mediumLarge
    self.descriptionLabel?.font = UIFont.lightSmall
  }

  override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)

    // Configure the view for the selected state
  }

  func setGuideGroup(guideGroup: GuideGroup, context: Context) {
    self.guideGroup = guideGroup
    self.guideLabel?.text = guideGroup.title
    self.descriptionLabel?.text = guideGroup.desc
    self.selectionStyle = .none

    let layout = GGCarouselFlowLayout()
    layout.scrollDirection = .horizontal
    layout.spacingMode = .fixed(spacing: 0)
    layout.sideItemScale = 1.0
    layout.sideItemAlpha = 1.0
    layout.itemSize = self.itemSize()
    self.collectionView.collectionViewLayout = layout

    Observable.array(from: guideGroup.guides, synchronousStart: false)
      .map({ (guides) -> [Guide] in
        let ids = guideGroup.guidesIdentifiers.toArray()
        return Cache.orderedByIdentifier(ids, guides)
      })
      .bind(onNext: { [unowned self] guides in
        self.guides = guides

        self.collectionView.reloadData()
      })
      .disposed(by: bag)

    // treat scrolling Top 25 carousel as viewing the guide
    collectionView.rx.didEndDecelerating
      .take(1) // first swipe only
      .skipWhile({ [weak self] _ -> Bool in // Top 25 guide only
        guard let guideCount = self?.guides.count else { return true }
        return guideCount != 1
      })
      .subscribe(onNext: { [weak self] _ in
        if let topGuide = self?.guides.first {
          context.analytics.log(.tapsOnGuideCell(category: topGuide))
        }
      })
      .disposed(by: bag)
  }

  override func prepareForReuse() {
    super.prepareForReuse()
    self.collectionView.reloadData()
    bag = DisposeBag()
  }

}
