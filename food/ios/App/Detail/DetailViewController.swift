import UIKit

class DetailViewController: UIViewController {

  var place : Place
  
  @IBOutlet weak var imageView: UIImageView!
  @IBOutlet weak var menuLabel: UILabel!
  @IBOutlet weak var drinkLabel: UILabel!
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var categoryLabel: UILabel!
  @IBOutlet weak var addressLabel: UILabel!
  @IBOutlet weak var numberLabel: UILabel!
  @IBOutlet weak var reservationButton: UIButton!

  @IBOutlet weak var quoteView: UIView!
  @IBOutlet weak var quoteLabel: UILabel!

  @IBOutlet weak var noteView: UIView!
  @IBOutlet weak var noteLabel: UILabel!

  @IBOutlet weak var remainderView: UIView!
  @IBOutlet weak var remainderLabel: UILabel!

  @IBOutlet weak var reviewButton: UIButton!

  init(place: Place) {
    self.place = place
    super.init(nibName: nil, bundle: nil)
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.extendedLayoutIncludesOpaqueBars = true

    self.reservationButton.tintColor = .blue
    self.reservationButton.layer.cornerRadius = 5.0
    self.reservationButton.layer.borderWidth = 1.0
    self.reservationButton.layer.borderColor = self.reservationButton.tintColor.cgColor
    self.reservationButton.clipsToBounds = true

    self.reviewButton.backgroundColor = .lightBlue
    self.reviewButton.layer.cornerRadius = 5.0
    self.reviewButton.titleLabel?.font = UIFont.customFont(.large)?.bold
    self.reviewButton.clipsToBounds = true

    self.remainderView.backgroundColor = .greyishBlue
    self.quoteView.backgroundColor = .greyishBlue

    self.quoteLabel.font = UIFont.customFont(.large)?.boldItalic
    self.noteLabel.font = UIFont.customFont(.large)?.bold

    self.titleLabel.text = self.place.name
    self.numberLabel.text = self.place.phone
    
    var names : [String] = []
    for category in self.place.categories ?? [] {
      names.append(category.name)
    }
    for nabe in self.place.nabes ?? [] {
      names.append(nabe.name)
    }
    self.categoryLabel.text = names.joined(separator: " | ")
    self.addressLabel.text = self.place.address ?? ""

    if let post = self.place.post {
      if let url = post.imageURL {
        self.imageView.af_setImage(withURL: url)
      }

      if let html = post.placeSummary {
        updateLabel(self.quoteLabel, with: html, textColorHex: "white", font: UIFont.customFont(.large)?.bold, alignment: .center)
      }
      
      if let html = post.menu {
        updateLabel(self.menuLabel, with: html, textColorHex: "black", font: UIFont.customFont(.regular)?.bold)
      }

      if let html = post.drinks {
        updateLabel(self.drinkLabel, with: html, textColorHex: "black", font: UIFont.customFont(.regular)?.bold)
      }

      if let html = post.notes {
        updateLabel(self.noteLabel, with: html, textColorHex: "black", font: UIFont.customFont(.regular)?.bold)
      }

      if let html = post.remainder {
        updateLabel(self.remainderLabel, with: html, textColorHex: "white", font: UIFont.customFont(.regular)?.bold)
      }

    }

  }

  func updateLabel(_ label: UILabel, with html: String, textColorHex: String, font: UIFont?, alignment: NSTextAlignment = .left) {
    var style =     "<style>body{ "
    if let font = font {
      style = style + " font-family: \(font.familyName); font-size: \(Int(font.pointSize))px;"
    }
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
      label.attributedText = content
    }
  }

  @IBAction func openFullReview() {
    let app = AppDelegate.shared()
    if let link = self.place.post?.link {
      app.openInSafari(url: link)
    }
  }

}
