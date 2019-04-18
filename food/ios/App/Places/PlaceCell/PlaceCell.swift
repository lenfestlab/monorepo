import UIKit
import AlamofireImage

class PlaceCell: UICollectionViewCell {

  @IBOutlet weak var textLabel: UILabel!
  @IBOutlet weak var subtitleLabel: UILabel!
  @IBOutlet weak var categoryLabel: UILabel!
  @IBOutlet weak var milesAwayLabel: UILabel!
  @IBOutlet weak var imageView: UIImageView!
  @IBOutlet weak var containerView: UIView!
  @IBOutlet weak var articleButton: UIButton!
  @IBOutlet weak var loveButton: UIButton!

  weak var analytics: AnalyticsManager?
  var controllerIdentifierKey : String = "unknown"
  var place : Place?

  override func awakeFromNib() {
    super.awakeFromNib()
    self.milesAwayLabel.font = UIFont.lightSmall
    containerView.layer.cornerRadius = 5.0
    containerView.layer.borderColor = UIColor.lightGray.cgColor
    containerView.layer.borderWidth = 1
    let radius = CGFloat(3)
    containerView.layer.shadowOffset = CGSize(width: radius, height: -radius)
    containerView.layer.shadowRadius = radius

    imageView.layer.cornerRadius = 5.0
    imageView.clipsToBounds = true

    NotificationCenter.default.addObserver(self, selector: #selector(onFavoritesUpdated(_:)), name: .favoritesUpdated, object: nil)
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
      let miles = (distance/1609.344)
      let milesAway = miles >= 10 ? String(format: "%0.0f miles away", miles) : String(format: "%0.1f miles away", miles)
      self.milesAwayLabel.text = milesAway
    }

    let attributedTitle = NSMutableAttributedString()
    if showIndex {
      attributedTitle.append(NSMutableAttributedString(string: "\(index + 1). ", font: UIFont.mediumSmall, fontColor: .black))
    }
    attributedTitle.append(place.attributedTitle(font: UIFont.mediumSmall))

    self.textLabel.attributedText = attributedTitle
    self.textLabel.lineBreakMode = .byTruncatingTail

    self.subtitleLabel.attributedText = place.attributedSubtitle(font: UIFont.mediumSmall, capHeight: UIFont.mediumSmall.capHeight)
    self.subtitleLabel.lineBreakMode = .byTruncatingTail

    self.categoryLabel.attributedText = place.attributedCategories()
    self.categoryLabel.lineBreakMode = .byTruncatingTail
    self.categoryLabel.textColor = .greyishBlue

    if let url = post?.imageURL {
      self.imageView.af_setImage(withURL: url)
    }

    self.loveButton.isHidden = Installation.authToken() == nil

    refresh()
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
      if let place = self.place {
        self.analytics?.log(.tapsFavoriteButtonOnCard(save: false, place: place, controllerIdentifierKey: self.controllerIdentifierKey))
      }
      deleteBookmark(placeId: identifier) { (success) in
        if !success {
          self.loveButton.isSelected = true
        }
      }
    } else {
      loveButton.isSelected = true
      if let place = self.place {
        self.analytics?.log(.tapsFavoriteButtonOnCard(save: true, place: place, controllerIdentifierKey: self.controllerIdentifierKey))
      }
      createBookmark(placeId: identifier) { (success) in
        if !success {
          self.loveButton.isSelected = false
        }
      }
    }
  }

}
