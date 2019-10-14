import UIKit
import AlamofireImage

class GuideCollectionCell: UICollectionViewCell {

  @IBOutlet weak var textLabel: UILabel!
  @IBOutlet weak var subtitleLabel: UILabel!
  @IBOutlet weak var categoryLabel: UILabel!
  @IBOutlet weak var imageView: RemoteImageView!
  @IBOutlet weak var containerView: UIView!

  static let reuseIdentifier = "GuideCollectionCell"

    override func awakeFromNib() {
      super.awakeFromNib()

      containerView.layer.shadowColor = UIColor.black.cgColor
      containerView.layer.shadowOpacity = 0.3
      let radius = CGFloat(3)
      containerView.layer.shadowOffset = .zero
      containerView.layer.shadowRadius = radius
      containerView.layer.borderWidth = 1
      containerView.layer.borderColor = UIColor.lightGray.cgColor

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
