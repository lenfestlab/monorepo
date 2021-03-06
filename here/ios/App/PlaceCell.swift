import UIKit
import AlamofireImage

class PlaceCell: UICollectionViewCell {
  
  @IBOutlet weak var textLabel: UILabel!
  @IBOutlet weak var imageView: UIImageView!
  @IBOutlet weak var containerView: UIView!
  @IBOutlet weak var articleButton: UIButton!
  
  override func awakeFromNib() {
    super.awakeFromNib()
    containerView.layer.cornerRadius = 5.0
    containerView.layer.borderColor = UIColor.lightGray.cgColor
    containerView.layer.borderWidth = 1
    containerView.layer.shadowColor = UIColor.black.cgColor
    containerView.layer.shadowOpacity = 0.3
    let radius = CGFloat(3)
    containerView.layer.shadowOffset = CGSize(width: radius, height: -radius)
    containerView.layer.shadowRadius = radius

    
    imageView.layer.cornerRadius = 5.0
    imageView.clipsToBounds = true
  }
  
  func attributedText(text: String, font: UIFont) -> NSMutableAttributedString {
    let attributedString = NSMutableAttributedString(string: text)
    let paragraphStyle = NSMutableParagraphStyle()
    
    // *** set LineSpacing property in points ***
    paragraphStyle.lineSpacing = 5 // Whatever line spacing you want in points
    
    // *** Apply attribute to string ***
    attributedString.addAttribute(NSAttributedStringKey.paragraphStyle, value:paragraphStyle, range:NSMakeRange(0, attributedString.length))
    attributedString.addAttribute(NSAttributedStringKey.font, value:font, range:NSMakeRange(0, attributedString.length))
    
    return attributedString
  }
  
  func setPlace(place: Place) {
    let post = place.post
    let text = NSMutableAttributedString(string: "")
    
    let boldFont = UIFont(name: "WorkSans-Bold", size: 14)
    let regularFont = UIFont(name: "Lato-Regular", size: 14)
    let title = self.attributedText(text: String(format: "%@\n\n", post.title!), font: boldFont!)
    let blurb = self.attributedText(text: post.blurb!, font: regularFont!)
    text.append(title)
    text.append(blurb)
    self.textLabel.attributedText = text
    self.textLabel.lineBreakMode = .byTruncatingTail
    
    if let url = post.imageURL {
      self.imageView.af_setImage(withURL: url)
    }
  }
  
  override func prepareForReuse() {
    super.prepareForReuse()
    self.textLabel.text = nil
    self.imageView.image = nil
  }
  
}
