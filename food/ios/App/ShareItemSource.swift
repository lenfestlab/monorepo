import UIKit

class ShareItemSource: NSObject, UIActivityItemSource {

  var stringData : [UIActivity.ActivityType:String]!
  var subjectData : [UIActivity.ActivityType:String]!

  init(data: [String:[UIActivity.ActivityType:String]]) {
    self.stringData = data["string"]
    self.subjectData = data["subject"]
    super.init()
  }

  func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
    return ""
  }

  func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivity.ActivityType?) -> Any? {
    guard
      let activityType = activityType,
      let string = self.stringData[activityType] else {
        return self.stringData[UIActivity.ActivityType.message]
    }
    return string
  }

  func activityViewController(_ activityViewController: UIActivityViewController, subjectForActivityType activityType: UIActivity.ActivityType?) -> String {
    if (activityType != nil) {
      let subject = self.subjectData[activityType!] ?? ""
      return subject
    }
    return ""
  }

}

