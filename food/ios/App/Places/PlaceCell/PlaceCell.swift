import UIKit
import RxSwift
import AlamofireImage

class PlaceCell: UICollectionViewCell {

  @IBOutlet weak var textLabel: UILabel!
  @IBOutlet weak var subtitleLabel: UILabel!
  @IBOutlet weak var categoryLabel: UILabel!
  @IBOutlet weak var milesAwayLabel: UILabel!
  @IBOutlet weak var imageView: RemoteImageView!
  @IBOutlet weak var containerView: UIView!
  @IBOutlet weak var articleButton: UIButton!
  @IBOutlet weak var loveButton: UIButton!

  static let reuseIdentifier = "PlaceCell"

  var controllerIdentifierKey : String = "unknown"
  var place : Place?
  var context: Context?
  var bag = DisposeBag()

  override func awakeFromNib() {
    super.awakeFromNib()
    self.milesAwayLabel.font = UIFont.lightSmall
    containerView.layer.cornerRadius = 5.0
    containerView.layer.borderColor = UIColor.lightGray.cgColor
    containerView.layer.borderWidth = 1
    containerView.layer.shadowColor = UIColor.black.cgColor
    containerView.layer.shadowOpacity = 0.3
    let radius = CGFloat(6)
    containerView.layer.shadowOffset = .zero
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
    attributedString.addAttribute(NSAttributedString.Key.paragraphStyle, value:paragraphStyle, range:NSMakeRange(0, attributedString.length))
    attributedString.addAttribute(NSAttributedString.Key.font, value:font, range:NSMakeRange(0, attributedString.length))

    return attributedString
  }

  func setPlace(context: Context, place: Place, index:Int, showIndex: Bool) {
    self.context = context
    self.place = place
    let post = place.post

    context.locationManager.location$
      .map({ [weak self] latestLocation -> Double? in
        return self?.place?.distanceFrom(latestLocation)
      })
      .unwrap()
      .bind(onNext: { [weak self] distance in
        let miles = (distance / 1609.344)
        let format = ((miles >= 10) || (miles == 0)) ? "%0.0f" : "%0.1f"
        let milesAway = String(format: "\(format) miles away", miles)
        self?.milesAwayLabel.text = milesAway
      })
      .disposed(by: bag)

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
      let size = imageView.frame.size
      let radius = imageView.layer.cornerRadius
      let filter = AspectScaledToFillSizeWithRoundedCornersFilter(size: size, radius: radius)
      imageView.set(url, filter: filter)
    }

    self.loveButton.isHidden = Installation.authToken() == nil

    self.context?.cache.isSaved$(place.identifier)
      .bind(to: loveButton.rx.isSelected)
      .disposed(by: bag)
  }

  override func prepareForReuse() {
    super.prepareForReuse()
    self.bag = DisposeBag()
    self.textLabel.text = nil
    self.imageView.image = nil
  }

  @IBAction func tapBookmarkButton() {
    guard
      let context = self.context,
      let place = self.place else { return }
    let placeId = place.identifier
    let isSaved = loveButton.isSelected
    let toSaved = !isSaved
    loveButton.isSelected = toSaved
    context.analytics.log(.tapsFavoriteButtonOnCard(save: toSaved, place: place, controllerIdentifierKey: self.controllerIdentifierKey))
    if toSaved { UIView.flashHUD("Added to List") }
    context.api.updateBookmark$(placeId, toSaved: toSaved)
      .subscribe()
      .disposed(by: rx.disposeBag)
  }

}
