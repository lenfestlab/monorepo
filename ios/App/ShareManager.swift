import UIKit

class ShareManager: NSObject {

  class func messageCopyForPlace(_ place: Place) -> String {
    let title = place.title!
    let placeURLString = place.post.link.absoluteString
    let shareCopy: String = [title, placeURLString].joined(separator: " ")

    return shareCopy
  }

  class func twitterCopyForPlace(_ place: Place) -> String {
    let title = place.title!
    let placeURLString = place.post.link.absoluteString
    let shareCopy: String = [title, placeURLString].joined(separator: " ")

    return shareCopy
  }

  class func facebookCopyForPlace(_ place: Place) -> String {
    let title = place.title!
    let placeURLString = place.post.link.absoluteString
    let shareCopy: String = [title, placeURLString].joined(separator: " ")
    return shareCopy
  }

  class func mailCopyForPlace(_ place: Place) -> String {
    let title = place.title!
    let placeURLString = place.post.link.absoluteString
    let env = Env()
    let shareCopy: String = [
      "<html><body>",
      "<h3>\(title)</h3>",
      placeURLString,
      "<br><br>via <a href=\"\(env.appMarketingUrlString)\">the \(env.appName) app</a>",
      "</body></html>",
      ].joined(separator: "")

    return shareCopy
  }

  class func mailSubjectForPlace(_ place: Place) -> String {
    let title = place.title!
    return title
  }

}
