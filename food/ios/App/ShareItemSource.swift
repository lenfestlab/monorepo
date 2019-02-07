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
    guard
      let activityType = activityType,
      let string = self.stringData[activityType] else {
        return self.stringData[UIActivityType.message]
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

}

