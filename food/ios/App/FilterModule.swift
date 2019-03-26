import UIKit

extension NSAttributedString {

  class func bellIcon() -> NSAttributedString {
    let bellImage = UIImage(named: "bell-icon")
    let attachment = NSTextAttachment()
    attachment.image = bellImage
    attachment.bounds = CGRect(x: 0, y: -3, width: bellImage?.size.width ?? 0, height: bellImage?.size.height ?? 0)
    return NSAttributedString(attachment: attachment)
  }

  class func space() -> NSAttributedString {
    return NSAttributedString(string: " ")
  }

  class func bells(count: Int) -> NSAttributedString? {
    if count < 1 {
      return nil
    }

    let bells = NSMutableAttributedString(string: "")
    let bellIcon = NSAttributedString.bellIcon()
    let space = NSAttributedString.space()
    for _ in 1 ... count {
      bells.append(bellIcon)
      bells.append(space)
    }
    return bells
  }

}

extension String {

  static func dollarSymbols(count: Int) -> String? {
    if count < 1 {
      return nil
    }

    var dollar = ""
    for _ in 1 ... count {
      dollar = String(format: "%@$", dollar)
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

    let space = NSMutableAttributedString(string: " ")
    let comma = NSMutableAttributedString(string: ",")

    var content = [NSAttributedString]()

    let text = NSMutableAttributedString(string: "")

    var bells = [NSAttributedString]()
    for (index, rating) in self.ratings.enumerated() {
      if let bellText = NSAttributedString.bells(count: rating) {
        bells.append(bellText)
      }
      if index != self.ratings.count - 1 {
        bells.append(comma)
        bells.append(space)
      }
    }

    var dollars = [String]()
    for value in self.prices {
      if let dollar = String.dollarSymbols(count: value) {
        dollars.append(dollar)
      }
    }

    if bells.count > 0 {
      for bell in bells {
        content.append(bell)
      }
    }

    if dollars.count > 0 {
      content.append(NSAttributedString(string: dollars.joined(separator: ",")))
    }

    let count = self.categories.count
    if let first = self.categories.first {
      if count == 1 {
        content.append(NSAttributedString(string: "\(first.name)"))
      } else {
        content.append(NSAttributedString(string: "\(first.name)+\(count)"))
      }
    }

    if content.count == 0 {
      return nil
    }

    for attributedString in content {
      text.append(attributedString)
    }

    return text
  }
}
