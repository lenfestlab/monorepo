// Source: https://stackoverflow.com/questions/39103095/unnotificationattachment-with-uiimage-or-remote-url
import UserNotifications
import UIKit

extension UNNotificationAttachment {
  
  static func create(identifier: String, image: UIImage, options: [NSObject : AnyObject]?) -> UNNotificationAttachment? {
    let fileManager = FileManager.default
    let tmpSubFolderName = ProcessInfo.processInfo.globallyUniqueString
    let tmpSubFolderURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(tmpSubFolderName, isDirectory: true)
    do {
      try fileManager.createDirectory(at: tmpSubFolderURL, withIntermediateDirectories: true, attributes: nil)
      let imageFileIdentifier = identifier+".png"
      let fileURL = tmpSubFolderURL.appendingPathComponent(imageFileIdentifier)
      guard let imageData = image.pngData() else {
        return nil
      }
      try imageData.write(to: fileURL)
      let imageAttachment = try UNNotificationAttachment.init(identifier: imageFileIdentifier, url: fileURL, options: options)
      return imageAttachment
    } catch {
      print("error " + error.localizedDescription)
    }
    return nil
  }
}
