import UIKit

extension UIColor {

//  White: #FFFFFF
//  Light Grey: #F3F3F3
//  Grey: #EEEEEE
//  Light Blue: #96BDC6
//  Blue: #0066AA
//  Greyish Blue: #546A7B
//  Black: #000000
//  Dark Red: #700000

  static let white = UIColor(hex: 0xFFFFFF)
  static let lightGrey = UIColor(hex: 0xF3F3F3)
  static let grey = UIColor(hex: 0xEEEEEE)
  static let lightBlue = UIColor(hex: 0xf96BDC6)
  static let blue = UIColor(hex: 0x0066AA)
  static let greyishBlue = UIColor(hex: 0x546A7B)
  static let darkRed = UIColor(hex: 0x700000)

  convenience init(red: Int, green: Int, blue: Int, a: CGFloat = 1.0) {
    self.init(
      red: CGFloat(red) / 255.0,
      green: CGFloat(green) / 255.0,
      blue: CGFloat(blue) / 255.0,
      alpha: a
    )
  }

  convenience init(hex: Int, a: CGFloat = 1.0) {
    self.init(
      red: (hex >> 16) & 0xFF,
      green: (hex >> 8) & 0xFF,
      blue: hex & 0xFF,
      a: a
    )
  }

  class func navigationColor() -> UIColor{
    return .lightBlue
  }

  class func offBlue() -> UIColor{
    return .blue
  }

  class func iconColor() -> UIColor{
    return .greyishBlue
  }

  func pixelImage() -> UIImage? {
    let color = self

    let rect = CGRect(origin: .zero, size: CGSize(width: 1, height: 1))
    UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
    color.setFill()
    UIRectFill(rect)
    let image = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()

    guard let cgImage = image?.cgImage else { return nil }
    return UIImage.init(cgImage: cgImage)
  }

}

