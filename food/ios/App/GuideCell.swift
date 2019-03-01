import UIKit

class GuideCell: UITableViewCell {

  @IBOutlet weak var guideLabel: UILabel?
  @IBOutlet weak var guideImageView: UIImageView?

  override func awakeFromNib() {
    super.awakeFromNib()
    // Initialization code
  }

  override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)

    // Configure the view for the selected state
  }

  func setCategory(category: Category){
    self.guideLabel?.text = category.name
    self.guideImageView?.af_setImage(withURL: category.imageURL)
    self.selectionStyle = .none
  }

  override func prepareForReuse() {
    self.guideImageView?.image = nil
  }

}
