import UIKit

class GuideCell: UITableViewCell {

  @IBOutlet weak var guideLabel: UILabel?
  @IBOutlet weak var descriptionLabel: UILabel?
  @IBOutlet weak var guideImageView: UIImageView?
  @IBOutlet weak var containerView: UIView!

  override func awakeFromNib() {
    super.awakeFromNib()

    containerView.layer.borderColor = UIColor.lightGray.cgColor
    containerView.layer.borderWidth = 1
    let radius = CGFloat(3)
    containerView.layer.shadowOffset = CGSize(width: radius, height: -radius)
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
    if let imageURL = category.imageURL {
      self.guideImageView?.af_setImage(withURL: imageURL)
    }
    self.descriptionLabel?.text = category.description
    self.selectionStyle = .none
  }

  override func prepareForReuse() {
    self.guideImageView?.image = nil
  }

}
