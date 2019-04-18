import UIKit

class ShareManager: NSObject {

  static let env = Env()

  class func messageCopyForPlace(_ place: Place) -> String {
    guard
      let title = place.title,
      let url = place.post?.url?.absoluteString
      else { return "" }
    return """
    \(title) \(url) via Lenfest Local Lab app, \(env.appName) \(env.appMarketingUrlString)")
    """
  }

  class func twitterCopyForPlace(_ place: Place) -> String {
    guard
      let title = place.title,
      let url = place.post?.url?.absoluteString
      else { return "" }
    return """
    \(title) \(url) via @lenfestlab
    """
  }

  class func facebookCopyForPlace(_ place: Place) -> String {
    guard
      let title = place.title,
      let url = place.post?.url?.absoluteString
      else { return "" }
    return """
    \(title) \(url)
    """
  }

  class func mailCopyForPlace(_ place: Place) -> String {
    return place.post?.url?.absoluteString ?? ""
  }

  class func mailSubjectForPlace(_ place: Place) -> String {
    return place.title ?? ""
  }

}
