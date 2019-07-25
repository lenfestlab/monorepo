import UIKit
import UPCarouselFlowLayout
import RxSwift
import RxCocoa
import AlamofireImage
import Lightbox

let imageIdentifier = "ImageViewCell"

extension DetailViewController: UICollectionViewDataSource {

  func numberOfSections(in collectionView: UICollectionView) -> Int {
    return 1
  }

  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    if let images = self.place.post?.images {
      return images.count
    }
    return 0
  }

  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: imageIdentifier, for: indexPath) as! ImageViewCell
    if
      let images = self.place.post?.images,
      let imageView = cell.imageView {
      let image: Img = images[indexPath.row]
      imageView.set(image.url)
    }
    return cell
  }
}

extension DetailViewController: LightboxControllerDismissalDelegate {
  func lightboxControllerWillDismiss(_ controller: LightboxController) {
    self.collectionView.scrollToItem(at: IndexPath(item: controller.currentPage, section: 0),
                                     at: .centeredHorizontally,
                                     animated: false)
  }
}

extension DetailViewController: UICollectionViewDelegate {

  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    guard let post = place.post else { return }

    let images : [LightboxImage] = post.images.map {
      let text = [$0.caption, $0.credit].compactMap({$0}).joined(separator: " \n")
      return LightboxImage(
        imageURL: $0.url!,
        text: text
      )
    }

    guard let indexPath = self.collectionView.indexPathsForVisibleItems.first else { return }

    let controller = LightboxController(images: images, startIndex: indexPath.item)
    controller.dismissalDelegate = self

    present(controller, animated: true, completion: nil)

  }

}

extension DetailViewController: UICollectionViewDelegateFlowLayout {

  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    return collectionView.frame.size
  }

}

extension DetailViewController: UIScrollViewDelegate {

  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    let currentIndex = self.collectionView.contentOffset.x / self.collectionView.frame.size.width;
    self.pageControl.currentPage = Int(currentIndex)
  }

}


class DetailViewController: UIViewController, Contextual {

  var place : Place
  
  @IBOutlet weak var pageControl: UIPageControl!
  @IBOutlet weak var collectionView: UICollectionView!
  @IBOutlet weak var menuLabel: UILabel!
  @IBOutlet weak var drinkLabel: UILabel!
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var categoryLabel: UILabel!
  @IBOutlet weak var addressLabel: UILabel!
  @IBOutlet weak var callButton: UIButton!
  @IBOutlet weak var reservationButton: UIButton!
  @IBOutlet weak var websiteButton: UIButton!
  @IBOutlet weak var buttonsView: UIStackView!

  @IBOutlet weak var quoteView: UIView!
  @IBOutlet weak var quoteLabel: UILabel!

  @IBOutlet weak var noteView: UIView!
  @IBOutlet weak var noteLabel: UILabel!

  @IBOutlet weak var remainderView: UIView!
  @IBOutlet weak var remainderLabel: UILabel!

  @IBOutlet weak var reviewButton: UIButton!
  @IBOutlet weak var reviewLabel: UILabel!

  @IBOutlet weak var loveButton: UIButton!

  var context: Context
  var isSaved$: Observable<Bool>

  init(context: Context, place: Place, eagerLoadView: Bool = true) {
    self.context = context
    self.place = place
    self.isSaved$ = context.cache.isSaved$(place.identifier)
    super.init(nibName: nil, bundle: nil)
    eagerLoadCarouselImages$()
    trackView$()
    maintainContextAnimatingState()
    // NOTE: `NSMutableAttributedString(html...)` is expensive but evidently
    // must run on the main thread for access to webkit; eager load our view on
    // init to leave main thread free during VC transition animation.
    if eagerLoadView {
      loadViewIfNeeded()
    }
  }

  private func eagerLoadCarouselImages$() -> Void {
    let willAppear$ = rx.methodInvoked(#selector(UIViewController.viewWillAppear(_:)))
    let willDisappear$ = rx.methodInvoked(#selector(UIViewController.viewWillDisappear(_:)))
    willAppear$
      .takeUntil(willDisappear$)
      .map({ [weak self] _ -> [URL] in
        guard let `self` = self, let post = self.place.post else { return [] }
        return post.images.compactMap({ $0.url })
      })
      .observeOn(Scheduler.background)
      .flatMapLatest { [unowned self] urls -> Observable<[Image]> in
        let loader = UIImageView.af_sharedImageDownloader
        return self.cache.loadImages$(Array(urls), withLoader: loader)
      }
      .subscribe()
      .disposed(by: rx.disposeBag)
  }

  private func trackView$() {
    api.recordPlaceEvent$(place.identifier, .viewed)
      .subscribe()
      .disposed(by: rx.disposeBag)
  }

  private func maintainContextAnimatingState() {
    rx.methodInvoked(#selector(UIViewController.viewDidAppear(_:)))
      .mapTo(false)
      .startWith(true)
      .bind(to: context.detailAnimating$$)
      .disposed(by: rx.disposeBag)
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  @IBAction func tapBookmarkButton() {
    let placeId = place.identifier
    let isSaved = cache.isSaved(placeId)
    let toSaved = !isSaved
    loveButton.isSelected = toSaved
    analytics.log(.tapsFavoriteButtonOnDetailPage(save: toSaved, place: place))
    if toSaved { UIView.flashHUD("Added to List") }
    api.updateBookmark$(placeId, toSaved: toSaved)
      .subscribe()
      .disposed(by: rx.disposeBag)
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    if self.place.post?.url == nil {
      self.reviewButton.removeFromSuperview()
    }

    self.loveButton.isHidden = api.authToken == nil

    isSaved$
      .bind(to: loveButton.rx.isSelected)
      .disposed(by: rx.disposeBag)

    buttonsView.axis = .horizontal
    buttonsView.distribution = .equalSpacing
    buttonsView.spacing = 10

    callButton.removeFromSuperview()
    if place.phoneURL != nil {
      buttonsView.addArrangedSubview(callButton)
    }

    websiteButton.removeFromSuperview()
    if place.websiteURL != nil {
      buttonsView.addArrangedSubview(websiteButton)
    }

    reservationButton.removeFromSuperview()
    if place.reservationsURL != nil {
      buttonsView.addArrangedSubview(reservationButton)
    }

    self.navigationItem.titleView = UIImageView(image: UIImage(named: "inquirer-logo"))

    let nib = UINib(nibName: "ImageViewCell", bundle:nil)
    self.collectionView.register(nib, forCellWithReuseIdentifier: imageIdentifier)
    self.collectionView.backgroundColor = UIColor.lightGreyBlue
    self.collectionView.delegate = self
    self.collectionView.dataSource = self
    self.collectionView.contentInset = .zero
    self.collectionView.showsHorizontalScrollIndicator = false
    let layout = UPCarouselFlowLayout()
    layout.scrollDirection = .horizontal
    layout.spacingMode = .fixed(spacing: 0)
    layout.sideItemScale = 1.0
    layout.itemSize = CGSize(width: AppDelegate.shared().window?.frame.size.width ?? 0, height: self.collectionView.frame.height)

    self.collectionView.collectionViewLayout = layout

    self.pageControl.numberOfPages = self.place.post?.images.count ?? 0
    self.pageControl.pageIndicatorTintColor = UIColor.white.withAlphaComponent(0.5)
    self.pageControl.currentPageIndicatorTintColor = UIColor.oceanBlue
    self.pageControl.hidesForSinglePage = true

    self.extendedLayoutIncludesOpaqueBars = true

    self.quoteLabel.font = .mediumItalicLarge

    let title = NSMutableAttributedString()
    title.append(self.place.attributedTitle(font: UIFont.mediumLarge))
    title.append(NSAttributedString.space())
    title.append(self.place.attributedSubtitle(font: UIFont.mediumLarge, capHeight: UIFont.mediumLarge.capHeight))
    self.titleLabel.attributedText = title

    self.categoryLabel.attributedText = self.place.attributedCategories()
    self.categoryLabel.font = UIFont.lightSmall
    categoryLabel.lineBreakMode = .byWordWrapping
    categoryLabel.numberOfLines = 0

    let address = self.place.address ?? ""
    let addressString = NSMutableAttributedString(string: address, font: UIFont.bookSmall, fontColor: .oceanBlue)
    addressString.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: NSMakeRange(0, addressString.length))
    self.addressLabel.attributedText = addressString

    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(openInMap))
    tapGesture.numberOfTapsRequired = 1
    self.addressLabel.addGestureRecognizer(tapGesture)
    self.addressLabel.isUserInteractionEnabled = true

    let reviewString = NSMutableAttributedString(string: "Read Full Review", font: UIFont.lightLarge, fontColor: .white)
    reviewString.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: NSMakeRange(0, reviewString.length))
    self.reviewButton.setAttributedTitle(reviewString, for: .normal)

    if let authorName = self.place.post?.author?.name {
      self.reviewLabel.text = "By \(authorName)"
    } else {
      self.reviewLabel.text = "Unknown Author"
    }
    self.reviewLabel.font = UIFont.lightLarge

    if let post = self.place.post {
      if let html = post.placeSummary {
        if let attributedText = NSMutableAttributedString(html: html, textColorHex: "white", font: UIFont.mediumItalicLarge, alignment: .center) {
          attributedText.addAttribute(NSAttributedString.Key.font, value:UIFont.mediumItalicLarge, range:NSMakeRange(0, attributedText.length))
          attributedText.addAttribute(NSAttributedString.Key.foregroundColor, value:UIColor.white, range:NSMakeRange(0, attributedText.length))
          self.quoteLabel.attributedText = attributedText
          self.quoteView.backgroundColor = .greyishBlue
        }
      }
      
      if let html = post.menu {
        if let attributedText = NSMutableAttributedString(html: html, h1Font: UIFont.mediumLarge) {
          self.menuLabel.attributedText = attributedText
        }
      }

      if let html = post.drinks {
        if let attributedText = NSMutableAttributedString(html: html, h1Font: UIFont.mediumLarge) {
          self.drinkLabel.attributedText = attributedText
        }
      }

      if let html = post.notes {
        if let attributedText = NSMutableAttributedString(html: html, h1Font: UIFont.mediumLarge) {
          self.noteLabel.attributedText = attributedText
        }
      }

      if let html = post.remainder {
        if let attributedText = NSMutableAttributedString(html: html, textColorHex: "white", font: UIFont.boldSmall) {
          self.remainderLabel.attributedText = attributedText
          self.remainderView.backgroundColor = .greyishBlue
        }
      }

    }

  }

  @IBAction func makeReservation() {
    analytics.log(.tapsReservationButton(place: self.place))
    if let url = self.place.reservationsURL {
      UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
  }

  @IBAction func openFullReview() {
    analytics.log(.tapsFullReviewButton(place: self.place))
    let app = AppDelegate.shared()
    if let url = self.place.postURL {
      app.openInlineBrowser(url: url)
    }
  }

  @IBAction func openWebsite() {
    analytics.log(.tapsWebsiteButton(place: self.place))
    let app = AppDelegate.shared()
    if let url = self.place.websiteURL {
      app.openInlineBrowser(url: url)
    }
  }

  @IBAction func call() {
    analytics.log(.tapsCallButton(place: self.place))
    guard
      let url = place.phoneURL
      else { return print("MIA: phoneURL") }
    UIApplication.shared.open(url)
  }

  @IBAction func openInMap() {
    // prefer Google Maps if installed, else default to Apple Maps.
    let app = UIApplication.shared
    if app.canOpenURL(URL(string:"comgooglemaps://")!),
      let url = place.mapsURL(.google) {
      app.open(url, options: [:], completionHandler: nil)
    } else if let url = place.mapsURL(.apple) {
      app.open(url, options: [:], completionHandler: nil)
    }
  }

}

