import UIKit
import AlamofireImage

class GuideCollectionCell: UICollectionViewCell {

  @IBOutlet weak var textLabel: UILabel!
  @IBOutlet weak var subtitleLabel: UILabel!
  @IBOutlet weak var categoryLabel: UILabel!
  @IBOutlet weak var imageView: RemoteImageView!
  @IBOutlet weak var containerView: UIView!
  @IBOutlet weak var shadowView: UIView!

  static let reuseIdentifier = "GuideCollectionCell"

    override func awakeFromNib() {
      super.awakeFromNib()

      shadowView.layer.shadowColor = UIColor.black.cgColor
      shadowView.layer.shadowOpacity = 0.3
      shadowView.layer.shadowOffset = .zero
      shadowView.layer.shadowRadius = 5

      containerView.layer.borderWidth = 1
      containerView.layer.borderColor = UIColor.lightGray.cgColor
      containerView.layer.cornerRadius = 5
      containerView.clipsToBounds = true

      self.clipsToBounds = false
      self.textLabel.font = .bookSmall
      self.subtitleLabel.font = .bookSmall
      self.subtitleLabel.textColor = .slate
  }

  func setCategory(category: Category){
    self.textLabel?.text = category.name
    self.subtitleLabel?.text = "See all \(category.places.count) restaurants"
    if
      let imageView = imageView,
      let url = category.imageURL {
      let size = imageView.frame.size
      let filter = AspectScaledToFillSizeFilter(size: size)
      imageView.set(url, filter: filter)
    }
  }

  override func prepareForReuse() {
    self.imageView.image = nil
  }
}
