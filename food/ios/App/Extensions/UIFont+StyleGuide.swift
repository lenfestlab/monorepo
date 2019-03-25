import UIKit

enum TextSize {
  case regular
  case large
}

extension UIFont {
  var bold: UIFont {
    return with(traits: .traitBold)
  }

  var italic: UIFont {
    return with(traits: .traitItalic)
  }

  var boldItalic: UIFont {
    return with(traits: [.traitBold, .traitItalic])
  }

  func with(traits: UIFontDescriptor.SymbolicTraits) -> UIFont {
    guard let descriptor = self.fontDescriptor.withSymbolicTraits(traits) else {
      return self
    }

    return UIFont(descriptor: descriptor, size: 0)
  }

  class func customFont(_ textSize: TextSize) -> UIFont? {
    var size : CGFloat = 16
    if textSize == .large {
      size = 20
    }
    let font = UIFont(name: "Lato-Regular", size: size)
    return font
  }

}
