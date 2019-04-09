import UIKit

extension NSAttributedString {

  class func bellIcon(selected: Bool) -> NSAttributedString {
    let bellImage = selected ? UIImage(named: "bell-selected-icon") : UIImage(named: "bell-icon")
    let attachment = NSTextAttachment()
    attachment.image = bellImage
    attachment.bounds = CGRect(x: 0, y: -3, width: bellImage?.size.width ?? 0, height: bellImage?.size.height ?? 0)
    return NSAttributedString(attachment: attachment)
  }

  class func space() -> NSAttributedString {
    return NSAttributedString(string: " ")
  }

  class func space(width: Int) -> NSAttributedString {
    let attachment = NSTextAttachment()
    attachment.image = UIColor.clear.pixelImage()
    attachment.bounds = CGRect(x: 0, y: 0, width: width, height: 1)
    return NSAttributedString(attachment: attachment)
  }


  class func bells(count: Int, selected: Bool = false) -> NSAttributedString? {
    if count < 1 {
      return nil
    }

    let bells = NSMutableAttributedString(string: "")
    let bellIcon = NSAttributedString.bellIcon(selected: selected)
    let space = NSAttributedString.space(width: 2)
    for _ in 1 ... count {
      bells.append(bellIcon)
      bells.append(space)
    }
    return bells
  }

  static func dollarSymbols(count: Int, color: UIColor = .black) -> NSMutableAttributedString? {
    if count < 1 {
      return nil
    }

    let dollar = NSMutableAttributedString(string: "")
    let space = NSAttributedString.space(width: 2)
    for _ in 1 ... count {
      dollar.append(NSMutableAttributedString(string: "$", font: nil, fontColor: color))
      dollar.append(space)
    }
    return dollar
  }

}

protocol FilterModuleDelegate: class {
  func filterUpdated(_ viewController: UIViewController, filter: FilterModule)
}

class FilterModule : NSObject {
  var ratings = [Int]()
  var prices = [Int]()
  var categories = [Category]()
  var nabes = [Neighborhood]()
  var authors = [Author]()
  var sortMode : SortMode = .distance

  func labelText() -> NSAttributedString? {

    let space = NSMutableAttributedString(string: " ", font: .lightSmall, fontColor: .black)
    let comma = NSMutableAttributedString(string: ",", font: .lightSmall, fontColor: .black)

    var content = [NSAttributedString]()

    for rating in self.ratings {
      if let bellText = NSAttributedString.bells(count: rating, selected: false) {
        content.append(bellText)
      }
    }

    for value in self.prices {
      if let dollar = NSMutableAttributedString.dollarSymbols(count: value) {
        content.append(dollar)
      }
    }

    for category in self.categories {
      let string = NSMutableAttributedString(string: "\(category.name)", font: .lightSmall, fontColor: .black)
      content.append(string)
    }

    for nabe in self.nabes {
      let string = NSMutableAttributedString(string: "\(nabe.name)", font: .lightSmall, fontColor: .black)
      content.append(string)
    }

    for author in self.authors {
      let string = NSMutableAttributedString(string: "\(author.name)", font: .lightSmall, fontColor: .black)
      content.append(string)
    }

    if content.count == 0 {
      return nil
    }

    let text = NSMutableAttributedString(string: "")
    let labelText = NSMutableAttributedString(string: "")

    let screenWidth = UIScreen.main.bounds.width
    var more = 0


    for (index, attributedString) in content.enumerated() {
      text.append(attributedString)
      text.append(comma)
      text.append(space)
      let rect = text.boundingRect(with: CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude), options: [], context: nil)
      print(rect.size.width)
      if rect.size.width < screenWidth - 30 {
        labelText.append(attributedString)
        if index != content.count - 1 {
          labelText.append(comma)
          labelText.append(space)
        }
      } else {
        more += 1
      }
    }

    if more > 0 {
      labelText.append(NSAttributedString(string: "+\(more)"))
    }

    labelText.addAttribute(NSAttributedString.Key.font, value:UIFont.lightSmall, range:NSMakeRange(0, labelText.length))
    let paragraphStyle = NSMutableParagraphStyle()
    paragraphStyle.alignment = .center
    labelText.addAttribute(NSAttributedString.Key.paragraphStyle, value:paragraphStyle, range:NSMakeRange(0, labelText.length))

    return labelText
  }
}
