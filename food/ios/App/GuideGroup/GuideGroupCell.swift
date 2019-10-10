import UIKit
import AlamofireImage

class GuideGroupCell: UITableViewCell {

  @IBOutlet weak var guideLabel: UILabel?
  @IBOutlet weak var allButton: UIButton?
  @IBOutlet weak var descriptionLabel: UILabel?
  @IBOutlet weak var containerView: UIView!
  @IBOutlet weak var collectionView: UICollectionView!

  var mapPlaces: [MapPlace] = []
  var currentPlace: MapPlace?
  var navigationController: UINavigationController?
  var context: Context?
  var showIndex = false {
    didSet {
      self.collectionView.reloadData()
    }
  }

  func scrollToItem(at indexPath:IndexPath) {
    guard
    let collectionView = collectionView.collectionViewFlowLayout.collectionView,
    collectionView.numberOfSections > 0
    else { return print("ERROR: empty collectionView") }
    collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
  }

  override func awakeFromNib() {
    super.awakeFromNib()

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
    self.guideLabel?.text = guideGroup.title
    self.descriptionLabel?.text = guideGroup.desc
    self.selectionStyle = .none
  }

}
