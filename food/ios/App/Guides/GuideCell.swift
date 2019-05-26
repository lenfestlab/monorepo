import UIKit
import AlamofireImage

class GuideCell: UITableViewCell {

  @IBOutlet weak var guideLabel: UILabel?
  @IBOutlet weak var descriptionLabel: UILabel?
  @IBOutlet weak var guideImageView: RemoteImageView?
  @IBOutlet weak var containerView: UIView!


  override func awakeFromNib() {
    super.awakeFromNib()

    containerView.layer.borderColor = UIColor.lightGray.cgColor
    containerView.layer.borderWidth = 1

    containerView.layer.shadowColor = UIColor.black.cgColor
    containerView.layer.shadowOpacity = 0.3
    let radius = CGFloat(6)
    containerView.layer.shadowOffset = .zero
    containerView.layer.shadowRadius = radius

    self.guideLabel?.font = UIFont.lightLarge
    self.descriptionLabel?.font = UIFont.lightSmall
  }

  override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)

    // Configure the view for the selected state
  }

  func setCategory(category: Category){
    self.guideLabel?.text = category.name
    self.descriptionLabel?.text = category.desc
    self.selectionStyle = .none
    if
      let imageView = guideImageView,
      let url = category.imageURL {
      let size = imageView.frame.size
      let filter = AspectScaledToFillSizeFilter(size: size)
      imageView.set(url, filter: filter)
    }
  }

  override func prepareForReuse() {
    self.guideImageView?.image = nil
  }

}
