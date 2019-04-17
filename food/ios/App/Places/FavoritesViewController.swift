import UIKit

extension Notification.Name {
  static let favoritesUpdated = Notification.Name("favoritesUpdate")
}

class FavoritesViewController : PlacesViewController {
  override func initalDataFetched() {
    let placeIds = self.placeStore.placesFiltered.map { $0.place.identifier }
    Place.save(identifiers: placeIds)
    NotificationCenter.default.post(name: .favoritesUpdated, object: nil)
  }

  init(analytics: AnalyticsManager) {
    super.init(path: "places.json?bookmarked=1", analytics: analytics)
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  @objc func onFavoritesUpdated(_ notification: Notification) {
    self.placeStore.refresh()
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    self.listViewController.controllerIdentifierKey = "my-list"
    self.mapViewController.controllerIdentifierKey = "my-list"

    NotificationCenter.default.addObserver(self, selector: #selector(onFavoritesUpdated(_:)), name: .favoritesUpdated, object: nil)

    self.title = "My List"

    self.topBarIsHidden = true

    self.emptyView.addSubview(self.emptyImageView)
    self.emptyView.addSubview(self.emptyTitleLabel)
    self.emptyView.addSubview(self.emptySubtitleLabel)
    self.view.addSubview(self.emptyView)
  }

  lazy var emptyView : UIView = {
    let view = UIView()
    view.backgroundColor = .white
    return view
  }()

  lazy var emptyImageView : UIImageView = {
    let view = UIImageView(image: UIImage(named: "no-favorites"))
    return view
  }()

  lazy var emptyTitleLabel : UILabel = {
    let label = UILabel()
    label.text = "Your plate is empty!"
    label.font = .titleFont
    label.textAlignment = .center
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
    return label
  }()

  override func viewWillLayoutSubviews() {
    super.viewWillLayoutSubviews()

    self.emptyView.frame = self.view.bounds

    let padding : CGFloat = 51
    let labelWidth = self.emptyView.frame.width - 2 * padding

    self.emptyImageView.center = CGPoint(x: self.emptyView.center.x, y: self.emptyView.center.y - 100)
    self.emptyTitleLabel.frame = CGRect(x: padding, y: self.emptyImageView.frame.maxY + 36, width: labelWidth, height: 21)
    self.emptySubtitleLabel.frame = CGRect(x: padding, y: self.emptyTitleLabel.frame.maxY + 14, width: labelWidth, height: 45)
  }

  override func fetchedMapData() {
    super.fetchedMapData()

    self.emptyView.isHidden = !isEmpty()
  }

}
