import UIKit
import UPCarouselFlowLayout
import RxSwift
import RxCocoa
import AlamofireImage

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

    // Configure the cell
    if let images = self.place.post?.images {
      let image:Img = images[indexPath.row]
      if let url = image.url {
        cell.imageView.af_setImage(withURL: url)
      }
    }

    return cell
  }
}

extension DetailViewController: UICollectionViewDelegate {

  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

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

  @IBOutlet weak var quoteView: UIView!
  @IBOutlet weak var quoteLabel: UILabel!

  @IBOutlet weak var noteView: UIView!
  @IBOutlet weak var noteLabel: UILabel!

  @IBOutlet weak var remainderView: UIView!
  @IBOutlet weak var remainderLabel: UILabel!

  @IBOutlet weak var reviewLabel: UILabel!

  @IBOutlet weak var loveButton: UIButton!

  var context: Context
  var isSaved$: Observable<Bool>

  init(context: Context, place: Place) {
    self.context = context
    self.place = place
    self.isSaved$ = context.cache.isSaved$(place.identifier)
    super.init(nibName: nil, bundle: nil)
    eagerLoadCarouselImages$()
  }

  private func eagerLoadCarouselImages$() -> Void {
    guard let post = place.post else { return }
    let willAppear$ = rx.methodInvoked(#selector(UIViewController.viewWillAppear(_:)))
    let willDisappear$ = rx.methodInvoked(#selector(UIViewController.viewWillDisappear(_:)))
    willAppear$
      .flatMapLatest { [unowned self] _ -> Observable<[Image]> in
        let urls = post.images.compactMap({ $0.url })
        let loader = UIImageView.af_sharedImageDownloader
        return self.cache.loadImages$(Array(urls), withLoader: loader)
      }
      .takeUntil(willDisappear$)
      .subscribe()
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
    api.updateBookmark$(placeId, toSaved: toSaved)
      .subscribe(
        onNext: { bookmark in
          if toSaved {
            UIView.flashHUD("Added to List")
          }
      })
      .disposed(by: rx.disposeBag)
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    self.loveButton.isHidden = Installation.authToken() == nil

    isSaved$
      .bind(to: loveButton.rx.isSelected)
      .disposed(by: rx.disposeBag)

    self.websiteButton.isEnabled = self.place.website != nil
    self.callButton.isEnabled = self.place.phone != nil
    self.reservationButton.isEnabled = self.place.reservationsURL != nil

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

    let address = self.place.address ?? ""
    self.addressLabel.attributedText = NSMutableAttributedString(string: address, font: UIFont.italicSmall, fontColor: nil)

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
    let app = AppDelegate.shared()
    if let url = self.place.reservationsURL {
      app.openInSafari(url: url)
    }
  }

  @IBAction func openFullReview() {
    analytics.log(.tapsFullReviewButton(place: self.place))
    let app = AppDelegate.shared()
    if let link = self.place.post?.url {
      app.openInSafari(url: link)
    }
  }

  @IBAction func openWebsite() {
    analytics.log(.tapsWebsiteButton(place: self.place))
    let app = AppDelegate.shared()
    if let link = self.place.website {
      app.openInSafari(url: link)
    }
  }

  @IBAction func call() {
    analytics.log(.tapsCallButton(place: self.place))
    if let phone = self.place.phone {
      guard let number = URL(string: "tel://" + phone) else { return }
      UIApplication.shared.open(number)
    }
  }



}

