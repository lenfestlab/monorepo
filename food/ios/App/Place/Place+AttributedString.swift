import UIKit

extension Place {

  func attributedCategories() -> NSAttributedString {
    var names : [String] = []
    for category in self.categories ?? [] {
      names.append(category.name)
    }
    for nabe in self.nabes ?? [] {
      names.append(nabe.name)
    }
    let categories = names.joined(separator: " | ")

    return NSAttributedString(string: categories)
  }

  func attributedTitle() -> NSAttributedString {
    let post = self.post

    let blurb = NSMutableAttributedString()

    let space = NSMutableAttributedString(string: " ")

    let text = NSMutableAttributedString(string: "")

    let name = self.name ?? ""
    let title = NSMutableAttributedString(string: String(format: "%@ ", name.uppercased()), font: UIFont.mediumSmall, fontColor: .black)
    blurb.append(title)

    var content = [NSAttributedString]()

    content.append(space)

    var bells = [NSAttributedString]()

    if let bellText = NSAttributedString.bells(count: post?.rating ?? 0) {
      bells.append(bellText)
    }

    var prices = [NSAttributedString]()
    for value in post?.prices ?? [] {
      var dollars = [String]()
      if let dollar = String.dollarSymbols(count: value) {
        dollars.append(dollar)
      }

      let symbols = NSMutableAttributedString(string: dollars.joined(separator: ","), font: UIFont.lightLarge, fontColor: .slate)
      prices.append(symbols)
    }

    content.append(contentsOf: bells)
    if bells.count > 0, prices.count > 0 {
      content.append(NSAttributedString(string: " | "))
    }
    content.append(contentsOf: prices)

    for attributedString in content {
      blurb.append(attributedString)
    }

    text.append(blurb)

    return text
  }
}
