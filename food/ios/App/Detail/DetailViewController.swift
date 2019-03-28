import UIKit
import UPCarouselFlowLayout

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


class DetailViewController: UIViewController {

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

  @IBOutlet weak var quoteView: UIView!
  @IBOutlet weak var quoteLabel: UILabel!

  @IBOutlet weak var noteView: UIView!
  @IBOutlet weak var noteLabel: UILabel!

  @IBOutlet weak var remainderView: UIView!
  @IBOutlet weak var remainderLabel: UILabel!

  @IBOutlet weak var reviewButton: UIButton!
  @IBOutlet weak var reviewLabel: UILabel!

  init(place: Place) {
    self.place = place
    super.init(nibName: nil, bundle: nil)
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    let nib = UINib(nibName: "ImageViewCell", bundle:nil)
    self.collectionView.register(nib, forCellWithReuseIdentifier: imageIdentifier)
    self.collectionView.backgroundColor = UIColor.lightGreyBlue
    self.collectionView.delegate = self
    self.collectionView.dataSource = self
    self.collectionView.contentInset = .zero
    let layout = UPCarouselFlowLayout()
    layout.scrollDirection = .horizontal
    layout.spacingMode = .fixed(spacing: 0)
    layout.sideItemScale = 1.0
    layout.itemSize = CGSize(width: AppDelegate.shared().window?.frame.size.width ?? 0, height: self.collectionView.frame.height)

    self.collectionView.collectionViewLayout = layout

    self.pageControl.numberOfPages = self.place.post?.images?.count ?? 0
    self.pageControl.pageIndicatorTintColor = UIColor.white.withAlphaComponent(0.5)
    self.pageControl.currentPageIndicatorTintColor = UIColor.oceanBlue

    self.extendedLayoutIncludesOpaqueBars = true

    self.remainderView.backgroundColor = .greyishBlue
    self.quoteView.backgroundColor = .greyishBlue

    self.quoteLabel.font = UIFont.customFont(.large)?.boldItalic
    self.noteLabel.font = UIFont.customFont(.large)?.bold

    self.titleLabel.attributedText = self.place.attributedTitle()
    self.categoryLabel.attributedText = self.place.attributedCategories()
    self.categoryLabel.font = UIFont.lightSmall
    self.addressLabel.text = self.place.address ?? ""
    self.addressLabel.font = UIFont.italicSmall

    self.reviewButton.titleLabel?.font = UIFont.lightLarge
    self.reviewButton.setBackgroundImage(UIColor.lightGreyBlue.pixelImage(), for: .normal)
    self.reviewButton.layer.cornerRadius = 5.0
    self.reviewButton.clipsToBounds = true

    if let authorName = self.place.post?.author?.name {
      self.reviewLabel.text = "REVIEWED BY \(authorName.uppercased())"
    } else {
      self.reviewLabel.text = "UNKNOWN REVIEWER"
    }
    self.reviewLabel.font = UIFont.lightLarge

    if let post = self.place.post {
      if let html = post.placeSummary {
        if let attributedText = updateLabel(html: html, textColorHex: "white", font: UIFont.mediumItalicLarge, alignment: .center) {
          attributedText.addAttribute(NSAttributedString.Key.font, value:UIFont.mediumItalicLarge, range:NSMakeRange(0, attributedText.length))
          attributedText.addAttribute(NSAttributedString.Key.foregroundColor, value:UIColor.white, range:NSMakeRange(0, attributedText.length))
          self.quoteLabel.attributedText = attributedText
        }
      }
      
      if let html = post.menu {
        if let attributedText = updateLabel(html: html, textColorHex: "black", h1Font: UIFont.mediumLarge, font: UIFont.bookSmall) {
          self.menuLabel.attributedText = attributedText
        }
      }

      if let html = post.drinks {
        if let attributedText = updateLabel(html: html, textColorHex: "black", h1Font: UIFont.mediumLarge, font: UIFont.bookSmall) {
          self.drinkLabel.attributedText = attributedText
        }
      }

      if let html = post.notes {
        if let attributedText = updateLabel(html: html, textColorHex: "black", h1Font: UIFont.mediumLarge, font: UIFont.bookSmall) {
          self.noteLabel.attributedText = attributedText
        }
      }

      if let html = post.remainder {
        if let attributedText = updateLabel(html: html, textColorHex: "white", h1Font: UIFont.mediumLarge, font: UIFont.bookSmall) {
          self.remainderLabel.attributedText = attributedText
        }
      }

    }

  }

  func updateLabel(html: String, textColorHex: String, h1Font: UIFont? = nil, font: UIFont?, alignment: NSTextAlignment = .left) -> NSMutableAttributedString? {
    var style =     "<style>"
    if let font = h1Font {
      style = style + " h1 { font: \(Int(font.pointSize))px \(font.fontName); }"
    }
    if let font = font {
      style = style + " p, ul { font: \(Int(font.pointSize))px \(font.fontName); }"
    }
    style = style + " body {"

    var textAlignment = "left"
    if alignment == .center {
      textAlignment = "center"
    }
    if alignment == .right {
      textAlignment = "right"
    }

    style = style + " text-align: \(textAlignment);"
    style = style + " color: \(textColorHex);"
    style = style + " }</style>"

    let htmlString = "\(style)<html><body>\(html)</body></html>"
    if let htmlData = htmlString.data(using: String.Encoding.unicode) { // utf8
      let options : [NSAttributedString.DocumentReadingOptionKey : Any] = [.documentType : NSAttributedString.DocumentType.html]
      let content = try! NSMutableAttributedString(data: htmlData, options: options, documentAttributes: nil)
      return content
    }
    return nil
  }

  @IBAction func openFullReview() {
    let app = AppDelegate.shared()
    if let link = self.place.post?.link {
      app.openInSafari(url: link)
    }
  }

}
