import UIKit

extension Place {

  func attributedCategories() -> NSAttributedString {
    var names: [String] = []
    names.append(contentsOf: categories.map({ $0.name }).compactMap({$0}))
    names.append(contentsOf: nabes.map({ $0.name }).compactMap({$0}))
    return NSAttributedString(string: names.joined(separator: " | "))
  }

  func attributedTitle(font: UIFont) -> NSAttributedString {
    let name = self.name ?? ""
    return NSMutableAttributedString(string: name.uppercased(), font: font, fontColor: .black)
  }

  func attributedSubtitle(font: UIFont, capHeight: CGFloat) -> NSMutableAttributedString {
    let post = self.post

    let blurb = NSMutableAttributedString()

    let space = NSMutableAttributedString(string: " ")

    var content = [NSAttributedString]()

    content.append(space)

    var bells = [NSAttributedString]()

    if let bellText = NSAttributedString.bells(count: post?.rating ?? 0) {
      bells.append(bellText)
    }

    var dollars = [NSAttributedString]()
    if let price = post?.prices {
      for value in price {
        if let dollar = NSMutableAttributedString.dollarSymbols(count: value, font: UIFont.lightLarge) {
          dollar.addAttribute(NSAttributedString.Key.font, value:UIFont.lightLarge, range:NSMakeRange(0, dollar.length))
          dollars.append(dollar)
        }
      }
    }

    var prices = [NSAttributedString]()
    for (index, dollar) in dollars.enumerated() {
      prices.append(dollar)
      if index + 1 != dollars.count {
        prices.append(NSMutableAttributedString(string: ", "))
      }
    }

    content.append(contentsOf: bells)
    if bells.count > 0, prices.count > 0 {
      content.append(NSMutableAttributedString(string: " | ", font: UIFont.lightLarge, fontColor: .slate))
    }
    content.append(contentsOf: prices)

    for attributedString in content {
      blurb.append(attributedString)
    }

    let text = NSMutableAttributedString(string: "")

    if let image = blurb.image() {
      let attachment = NSTextAttachment()
      attachment.image = image
      let y = (capHeight - image.size.height).rounded() / 2
      attachment.bounds = CGRect(x: 0, y: y - 2, width: image.size.width, height: image.size.height)
      print(image.size)
      text.append(NSMutableAttributedString(attachment: attachment))
    }

    return text
  }

}
