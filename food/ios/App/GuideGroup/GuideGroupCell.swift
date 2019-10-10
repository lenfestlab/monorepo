import UIKit
import AlamofireImage
import UPCarouselFlowLayout

class GuideGroupCell: UITableViewCell {

  @IBOutlet weak var guideLabel: UILabel?
  @IBOutlet weak var allButton: UIButton?
  @IBOutlet weak var descriptionLabel: UILabel?
  @IBOutlet weak var containerView: UIView!
  @IBOutlet weak var collectionView: UICollectionView!

  static let reuseIdentifier = "GuideGroupCell"

  var guideGroup: GuideGroup?

  weak var navigationController: UINavigationController?
  var context: Context?
  var showIndex = false {
    didSet {
      self.collectionView.reloadData()
    }
  }

  @IBAction func seeAll() {
    if let context = context, let guideGroup = self.guideGroup {
      let guides = guideGroup.guides
      if
        guides.count == 1,
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
    let padding = placeCellPadding
    let layout = UPCarouselFlowLayout()
    layout.scrollDirection = .horizontal
    let width = self.collectionView.frame.size.width - 2*padding
    layout.spacingMode = .fixed(spacing: 0)
    layout.sideItemScale = 1.0
    layout.sideItemAlpha = 1.0
    layout.itemSize = CGSize(width: width, height: self.collectionView.frame.size.height)
    self.collectionView.collectionViewLayout = layout
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

  func setGuideGroup(guideGroup: GuideGroup){
    self.guideGroup = guideGroup
    self.guideLabel?.text = guideGroup.title
    self.descriptionLabel?.text = guideGroup.desc
    self.selectionStyle = .none
  }

}
