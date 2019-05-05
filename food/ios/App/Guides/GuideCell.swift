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
    if let imageURL = category.imageURL {
      self.guideImageView?.kf.setImage(with: imageURL)
    }
    self.descriptionLabel?.text = category.description
    self.selectionStyle = .none
  }

  override func prepareForReuse() {
    self.guideImageView?.image = nil
  }

}
