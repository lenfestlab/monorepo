import UIKit

protocol SettingsToggleCellDelegate: class {
  func switchTriggered(sender: UISwitch)
}

class SettingsToggleCell: UITableViewCell {

  weak var delegate: SettingsToggleCellDelegate?
  
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var descriptionLabel: UILabel!
  @IBOutlet weak var permissionSwitch: UISwitch!

  override func awakeFromNib() {
    super.awakeFromNib()
    // Initialization code
  }

  override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)

    // Configure the view for the selected state
  }
  
  @IBAction func switchTriggered(sender: UISwitch) {
    self.delegate?.switchTriggered(sender: sender)
  }

}
