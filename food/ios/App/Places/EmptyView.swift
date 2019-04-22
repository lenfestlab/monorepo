import UIKit

class EmptyView: UIView {

  lazy var emptyImageView : UIImageView = {
    let view = UIImageView()
    self.addSubview(view)
    return view
  }()

  lazy var emptyTitleLabel : UILabel = {
    let label = UILabel()
    label.font = .titleFont
    label.textAlignment = .center
    self.addSubview(label)
    return label
  }()

  lazy var emptySubtitleLabel : UILabel = {
    let label = UILabel()

    let attributedText = NSMutableAttributedString(string: "Tap the “ ")
    attributedText.append(NSMutableAttributedString.heartIcon())
    attributedText.append(NSMutableAttributedString(string: " ” to add a resturant to your list."))
    label.attributedText = attributedText
    label.font = .lightLarge
    label.numberOfLines = 0
    label.textAlignment = .center

    self.addSubview(label)
    return label
  }()

  override func layoutSubviews() {
    super.layoutSubviews()

    let padding : CGFloat = 51
    let labelWidth = self.frame.width - 2 * padding

    var frame : CGRect = .zero
    if let size = self.emptyImageView.image?.size {
      frame.size = size
    }
    self.emptyImageView.frame = frame
    self.emptyImageView.center = CGPoint(x: self.center.x, y: self.center.y - 100)
    self.emptyTitleLabel.frame = CGRect(x: padding, y: self.emptyImageView.frame.maxY + 36, width: labelWidth, height: 21)
    self.emptySubtitleLabel.frame = CGRect(x: padding, y: self.emptyTitleLabel.frame.maxY + 14, width: labelWidth, height: 60)
  }


}
