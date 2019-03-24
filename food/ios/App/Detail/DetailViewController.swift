import UIKit

class DetailViewController: UIViewController {

  #if DEBUG
  @objc func injected() {
    print("\n injected \n")
    self.view.subviews.forEach({
      $0.removeFromSuperview()
    })
    self.viewDidLoad()
  }
  #endif


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
        html = stubDetailHTML

//        let font = "<style>body{font-family: \(regularFont.familyName);}</style>"
//        html = "\(font)<html><body>\(html)</body></html>"

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


var stubDetailHTML = """

<html><body><style type="text/css">
body {
font-family: "apple-system", "Lato-Regular";
box-sizing: border-box;
padding: 0;
border: 0;
}
blockquote {
background-color: rgb(67,86,103);
color: white;
font-style: italic;
font-weigth: bold;
font-size: 17;
}
blockquote:after {
content: close-quote;
vertical-align: bottom;
}
blockquote:before {
content: open-quote;
vertical-align: top;
}
#place_summary {
  height: 100;
}

</style><section id="place_summary"><blockquote>Dynamic contemporary dishes built around the ever-changing tides of sustainable &#39;dock-to-table&#39; ingredients</blockquote></section><section id="menu"><h1>Menu Highlight</h1>
<ul>
<li>Meaty filefish over chilled poblano-avocado puree.</li>
<li>Scallop ceviche splashed in bright yellow watermelon juice enriched with labne.</li>
<li>Juicy halibut over puffed quinoa, minted tomato salad.</li>
<li>Refreshing sweet tart spice of summer cantaloupe gazpacho.</li>
</ul>
</section><section id="drinks"><h1>Recommended Drinks</h1>
<p>The city’s best martinis, highlighted by the housemade vermouth and Philly’s biggest collection of gin.</p>
</section><section id="notes"><h1>Short dining notes</h1>
<p>The region’s finest raw bar and the premier showplace for New Jersey’s revitalized oyster industry and pristine shellfish from around the globe. New chef Aaron Gottesman (ex-Hearthside, Fat Ham) has brought dynamic contemporary dishes built around the ever-changing tides of sustainable ‘dock-to-table’ ingredients chosen daily at market by Sam’s dad, David. Add a team of well-informed servers and beautiful seasonal desserts from Stephanie Vacca - grilled rum cake with peaches; strawberry pie ribboned with dark chocolate; timeless butterscotch pudding - and you have a very complete restaurant.</p>
</section></body></html>



"""
