import UserNotifications
import Shared

class NotificationService: UNNotificationServiceExtension {

  var contentHandler: ((UNNotificationContent) -> Void)?
  var bestAttemptContent: UNMutableNotificationContent?

  override func didReceive(
    _ request: UNNotificationRequest,
    withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
    self.contentHandler = contentHandler
    bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)

    // https://www.avanderlee.com/ios-10/rich-notifications-ios-10/
    guard
      let content = bestAttemptContent,
      let imageURLString = content.userInfo["image_url"] as? String,
      let imageURL = URL(string: imageURLString),
      let imageData = NSData(contentsOf: imageURL),
      let image = UNNotificationAttachment.create("image.jpg", // TODO: mimetype
                                                  data: imageData,
                                                  options: nil)
      else { return contentHandler(request.content) }
    content.attachments = [image]
    contentHandler(content)
  }

  override func serviceExtensionTimeWillExpire() {
    if let contentHandler = contentHandler,
      let bestAttemptContent =  bestAttemptContent {
      contentHandler(bestAttemptContent)
    }
  }

}
