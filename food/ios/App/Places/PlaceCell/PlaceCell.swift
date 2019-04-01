import UIKit
import AlamofireImage

extension NSMutableAttributedString {

  convenience init(string: String, font: UIFont?, fontColor: UIColor?) {
    self.init(string: string)
    let paragraphStyle = NSMutableParagraphStyle()

    // *** set LineSpacing property in points ***
    paragraphStyle.lineSpacing = 5 // Whatever line spacing you want in points

    // *** Apply attribute to string ***
    self.addAttribute(NSAttributedString.Key.paragraphStyle, value:paragraphStyle, range:NSMakeRange(0, self.length))
    if let font = font {
      self.addAttribute(NSAttributedString.Key.font, value:font, range:NSMakeRange(0, self.length))
    }
    if let fontColor = fontColor {
      self.addAttribute(NSAttributedString.Key.foregroundColor, value:fontColor, range:NSMakeRange(0, self.length))
    }
  }

}

class PlaceCell: UICollectionViewCell {

  @IBOutlet weak var textLabel: UILabel!
  @IBOutlet weak var subtitleLabel: UILabel!
  @IBOutlet weak var categoryLabel: UILabel!
  @IBOutlet weak var milesAwayLabel: UILabel!
  @IBOutlet weak var imageView: UIImageView!
  @IBOutlet weak var containerView: UIView!
  @IBOutlet weak var articleButton: UIButton!
  @IBOutlet weak var loveButton: UIButton!

  var place : Place?

  override func awakeFromNib() {
    super.awakeFromNib()
    containerView.layer.cornerRadius = 5.0
    containerView.layer.borderColor = UIColor.lightGray.cgColor
    containerView.layer.borderWidth = 1
    let radius = CGFloat(3)
    containerView.layer.shadowOffset = CGSize(width: radius, height: -radius)
    containerView.layer.shadowRadius = radius

    imageView.layer.cornerRadius = 5.0
    imageView.clipsToBounds = true
    imageView.layer.addSublayer(self.gradientLayer(bounds: self.imageView.bounds))

    NotificationCenter.default.addObserver(self, selector: #selector(onFavoritesUpdated(_:)), name: .favoritesUpdated, object: nil)
  }

  func gradientLayer(bounds: CGRect) -> CAGradientLayer {
    let transparent = UIColor.black.withAlphaComponent(0.0).cgColor
    let opaque = UIColor.black.withAlphaComponent(1.0).cgColor
    let gradient = CAGradientLayer()
    gradient.frame = bounds
    gradient.colors = [opaque, transparent, transparent, transparent]
    return gradient
  }

  func attributedText(text: String, font: UIFont) -> NSMutableAttributedString {
    let attributedString = NSMutableAttributedString(string: text)
    let paragraphStyle = NSMutableParagraphStyle()

    // *** set LineSpacing property in points ***
    paragraphStyle.lineSpacing = 5 // Whatever line spacing you want in points

    // *** Apply attribute to string ***
    attributedString.addAttribute(NSAttributedString.Key.paragraphStyle, value:paragraphStyle, range:NSMakeRange(0, attributedString.length))
    attributedString.addAttribute(NSAttributedString.Key.font, value:font, range:NSMakeRange(0, attributedString.length))

    return attributedString
  }

  @objc func onFavoritesUpdated(_ notification: Notification) {
    self.refresh()
  }

  func refresh() {
    if let identifier = self.place?.identifier {
      self.loveButton.isSelected = Place.contains(identifier: identifier)
    }
  }

  func setPlace(place: Place, index:Int, showIndex: Bool) {
    self.place = place
    let post = place.post

    if let distance = place.distance {
      let milesAway = String(format: "%0.2f miles away", (distance/1609.344))
      self.milesAwayLabel.text = milesAway
    }

    let attributedTitle = NSMutableAttributedString()
    if showIndex {
      attributedTitle.append(NSMutableAttributedString(string: "\(index + 1). ", font: UIFont.mediumSmall, fontColor: .black))
    }
    attributedTitle.append(place.attributedTitle(font: UIFont.mediumSmall))

    self.textLabel.attributedText = attributedTitle
    self.textLabel.lineBreakMode = .byTruncatingTail
    
    self.subtitleLabel.attributedText = place.attributedSubtitle(font: UIFont.mediumSmall)
    self.subtitleLabel.lineBreakMode = .byTruncatingTail

    self.categoryLabel.attributedText = place.attributedCategories()
    self.categoryLabel.lineBreakMode = .byTruncatingTail
    self.categoryLabel.textColor = .greyishBlue

    if let url = post?.imageURL {
      self.imageView.af_setImage(withURL: url)
    }

    self.loveButton.isHidden = Installation.authToken() == nil

    if let identifier = self.place?.identifier {
      self.loveButton.isSelected = Place.contains(identifier: identifier)
    }
  }

  override func prepareForReuse() {
    super.prepareForReuse()
    self.textLabel.text = nil
    self.imageView.image = nil
  }

  @IBAction func tapBookmarkButton() {
    guard let identifier = self.place?.identifier else {
      return
    }


    if loveButton.isSelected {
      loveButton.isSelected = false
      deleteBookmark(placeId: identifier) { (success) in
        if !success {
          self.loveButton.isSelected = true
        }
      }
    } else {
      loveButton.isSelected = true
      createBookmark(placeId: identifier) { (success) in
        if !success {
          self.loveButton.isSelected = false
        }
      }
    }
  }

}
