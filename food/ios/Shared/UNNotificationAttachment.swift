import UserNotifications

public extension UNNotificationAttachment {

  static func create(_ imageFileName: String, data: NSData, options: [NSObject : AnyObject]?) -> UNNotificationAttachment? {
    let fileManager = FileManager.default
    let tmpSubFolderName = ProcessInfo.processInfo.globallyUniqueString
    let tmpSubFolderURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(tmpSubFolderName, isDirectory: true)
    do {
      try fileManager.createDirectory(at: tmpSubFolderURL, withIntermediateDirectories: true, attributes: nil)
      let imageFileIdentifier = imageFileName+".jpg"
      let fileURL = tmpSubFolderURL.appendingPathComponent(imageFileIdentifier)
      try data.write(to: fileURL, options: [])
      let imageAttachment = try UNNotificationAttachment(identifier: imageFileIdentifier, url: fileURL, options: options)
      return imageAttachment
    } catch let error {
      print("error \(error)")
    }
    return nil
  }

}
