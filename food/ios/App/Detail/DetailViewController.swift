import UIKit

class DetailViewController: UIViewController {

  var place : Place
  
  @IBOutlet weak var imageView: UIImageView!
  @IBOutlet weak var contentLabel: UILabel!
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var categoryLabel: UILabel!
  @IBOutlet weak var addressLabel: UILabel!
  @IBOutlet weak var numberLabel: UILabel!
  @IBOutlet weak var reservationButton: UIButton!
  @IBOutlet weak var quoteView: UIView!
  @IBOutlet weak var quoteLabel: UILabel!
  @IBOutlet weak var noteView: UIView!
  @IBOutlet weak var noteLabel: UILabel!
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
    self.reviewButton.titleLabel?.font = UIFont.customFont()?.bold
    self.reviewButton.clipsToBounds = true

    self.noteView.backgroundColor = .greyishBlue
    self.quoteView.backgroundColor = .greyishBlue

    self.quoteLabel.font = UIFont.customFont()?.boldItalic
    self.noteLabel.font = UIFont.customFont()?.bold

    guard let regularFont = UIFont(name: "Lato-Regular", size: 14) else {
      return
    }

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

      if var html = post.detailsHtml {
        print(html)

        let font = "<style>body{font-family: \(regularFont.familyName);}</style>"
        html = "\(font)<html><body>\(html)</body></html>"

        if let htmlData = html.data(using: String.Encoding.unicode) { // utf8
          let options : [NSAttributedString.DocumentReadingOptionKey : Any] = [.documentType : NSAttributedString.DocumentType.html]

          let content = try! NSMutableAttributedString(data: htmlData, options: options, documentAttributes: nil)

//          content.setAttributes([NSAttributedString.Key.font : regularFont!], range: NSMakeRange(0, content.length))

          self.contentLabel.attributedText = content
        }

//        self.contentLabel.text = html

      }

    }

  }

  @IBAction func openFullReview() {
    let app = AppDelegate.shared()
    if let link = self.place.post?.link {
      app.openInSafari(url: link)
    }
  }

}
