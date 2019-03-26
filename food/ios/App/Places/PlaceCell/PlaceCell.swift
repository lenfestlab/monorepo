import UIKit
import AlamofireImage

class PlaceCell: UICollectionViewCell {

  @IBOutlet weak var textLabel: UILabel!
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

  func setPlace(place: Place) {
    self.place = place
    let post = place.post

    let blurb = NSMutableAttributedString()

    let space = NSMutableAttributedString(string: " ")

    let text = NSMutableAttributedString(string: "")

    let boldFont = UIFont(name: "WorkSans-Bold", size: 16)
    let name = place.name ?? ""
    let title = self.attributedText(text: String(format: "%@ ", name), font: boldFont!)

    blurb.append(title)

    var content = [NSAttributedString]()

    content.append(space)

    var bells = [NSAttributedString]()

    if let bellText = NSAttributedString.bells(count: post?.rating ?? 0) {
      bells.append(bellText)
    }

    var prices = [NSAttributedString]()
    for value in post?.price ?? [] {
      var dollars = [String]()
      if let dollar = String.dollarSymbols(count: value) {
        dollars.append(dollar)
      }
      prices.append(NSAttributedString(string: dollars.joined(separator: ",")))
    }

    content.append(contentsOf: bells)
    if bells.count > 0, prices.count > 0 {
      content.append(NSAttributedString(string: " | "))
    }
    content.append(contentsOf: prices)


    if let distance = place.distance {
      let milesAway = String(format: "%0.2f miles away", (distance/1609.344))
      self.milesAwayLabel.text = milesAway
    }

    for attributedString in content {
      blurb.append(attributedString)
    }

    text.append(blurb)

    self.textLabel.attributedText = text
    self.textLabel.lineBreakMode = .byTruncatingTail

    var names : [String] = []
    for category in place.categories ?? [] {
      names.append(category.name)
    }
    for nabe in place.nabes ?? [] {
      names.append(nabe.name)
    }
    let categories = names.joined(separator: " | ")

    self.categoryLabel.attributedText = NSAttributedString(string: categories)
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
