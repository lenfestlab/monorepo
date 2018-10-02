import UIKit

class ButtonCell: UITableViewCell {
  
  @IBOutlet weak var button: UIButton!
  
  override func awakeFromNib() {
    super.awakeFromNib()
    button.layer.cornerRadius = 5.0
    button.clipsToBounds = true
  }
  
  override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
    
    // Configure the view for the selected state
  }
  
}
