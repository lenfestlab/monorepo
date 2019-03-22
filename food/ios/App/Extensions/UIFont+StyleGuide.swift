import UIKit

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

  class func customFont() -> UIFont? {
    let size : CGFloat = 16
    let font = UIFont.systemFont(ofSize: size)
    return font
  }

}
