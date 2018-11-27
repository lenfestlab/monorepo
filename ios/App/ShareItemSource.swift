import UIKit

class ShareItemSource: NSObject, UIActivityItemSource {

  var stringData : [UIActivityType:String]!
  var subjectData : [UIActivityType:String]!

  init(data: [String:[UIActivityType:String]]) {
    self.stringData = data["string"]
    self.subjectData = data["subject"]
    super.init()
  }

  func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
    return ""
  }

  func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivityType?) -> Any? {
    var string:String? = nil
    if (activityType != nil) {
      string = self.stringData[activityType!]
    }
    if (string == nil) {
      string = self.stringData[UIActivityType.message]
    }
    return string
  }

  func activityViewController(_ activityViewController: UIActivityViewController, subjectForActivityType activityType: UIActivityType?) -> String {
    if (activityType != nil) {
      let subject = self.subjectData[activityType!] ?? ""
      return subject
    }
    return ""
  }

  //  func activityViewController(_ activityViewController: UIActivityViewController, thumbnailImageForActivityType activityType: UIActivityType?, suggestedSize size: CGSize) -> UIImage? {
  //    if activityType == UIActivityType.message {
  //      return UIImage(named: "thumbnail-for-message")
  //    } else if activityType == UIActivityType.mail {
  //      return UIImage(named: "thumbnail-for-mail")
  //    } else if activityType == UIActivityType.postToTwitter {
  //      return UIImage(named: "thumbnail-for-twitter")
  //    } else if activityType == UIActivityType.postToFacebook {
  //      return UIImage(named: "thumbnail-for-facebook")
  //    }
  //    return UIImage(named: "some-default-thumbnail")
  //  }
}

