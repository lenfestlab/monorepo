import UIKit

class ShareManager: NSObject {

  static let env = Env()

  class func messageCopyForPlace(_ place: Place) -> String? {
    let title = place.title!

    guard let post = place.post else {
      return nil
    }

    let url = post.linkShort.absoluteString
    let publicationName = post.publicationName!
    return """
    \(title) \(url) via the \(publicationName) and Lenfest Local Lab app, \(env.appName) \(env.appMarketingUrlString)
    """
  }

  class func twitterCopyForPlace(_ place: Place) -> String? {
    let title = place.title!
    guard let post = place.post else {
      return nil
    }
    let url = post.linkShort.absoluteString
    let appCreatorTwitter = "@lenfestlab"
    let publicationTwitter = post.publicationTwitter!
    return "\(title) \(url) via \(publicationTwitter) \(appCreatorTwitter)"
  }

  class func facebookCopyForPlace(_ place: Place) -> String? {
    let title = place.title!
    guard let post = place.post else {
      return nil
    }

    let placeURLString = post.linkShort.absoluteString
    return [title, placeURLString].joined(separator: " ")
  }

  class func mailCopyForPlace(_ place: Place) -> String? {
    guard let post = place.post else {
      return nil
    }

    let placeURLString = post.linkShort.absoluteString
    let publicationName = post.publicationName!
    return """
      <html><body>
      Here’s a local story from \(publicationName) sent to you from the \(env.appName) app built by the Lenfest Local Lab.
      <br>
      <br>
      <a href=\"\(placeURLString)">Read the article here.</a>
      <br>
      <br>
      Get the <a href=\"\(env.appMarketingUrlString)">\(env.appName) app</a> today.
      </body></html>
      """
  }

  class func mailSubjectForPlace(_ place: Place) -> String? {
    guard let post = place.post else {
      return nil
    }

    guard let title = place.title else {
      return nil
    }

    return "\(post.publicationName!): \(title)"
  }

}
