import UIKit

extension NSMutableAttributedString {

  func image() -> UIImage? {
    UIGraphicsBeginImageContextWithOptions(self.size(), false, 0.0)
    // draw in context
    self.draw(at: .zero)

    // transfer image
    let image = UIGraphicsGetImageFromCurrentImageContext()?.withRenderingMode(.alwaysOriginal)
    UIGraphicsEndImageContext()

    return image;
  }

  convenience init?(html: String, textColorHex: String = "black", h1Font: UIFont? = nil, font: UIFont? = UIFont.bookSmall, alignment: NSTextAlignment = .left) {
    self.init()
    var style =     "<style>"
    if let font = h1Font {
      style = style + " h1 { font: \(Int(font.pointSize))px \(font.fontName); }"
    }
    if let font = font {
      style = style + " p, ul { font: \(Int(font.pointSize))px \(font.fontName); line-height: 20px; }"
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
      self.append(content)
    } else {
      return nil
    }
  }

  convenience init(string: String, font: UIFont?, fontColor: UIColor?) {
    self.init(string: string)
    let paragraphStyle = NSMutableParagraphStyle()

    // *** set LineSpacing property in points ***
    paragraphStyle.lineSpacing = 5 // Whatever line spacing you want in points

    // *** Apply attribute to string ***
    self.addAttribute(NSAttributedString.Key.paragraphStyle, value:paragraphStyle, range:NSMakeRange(0, self.length))
    if let font = font {
      self.addAttribute(NSAttributedString.Key.font, value:font, range:NSMakeRange(0, self.length))
    }
    if let fontColor = fontColor {
      self.addAttribute(NSAttributedString.Key.foregroundColor, value:fontColor, range:NSMakeRange(0, self.length))
    }
  }

}

