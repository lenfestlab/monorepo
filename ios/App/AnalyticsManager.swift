import UIKit
import UserNotifications
import CoreLocation
import Gloss

enum Category : CustomStringConvertible {
  case onboarding
  case notification
  case app
  case settings

  var description : String {
    switch self {
    // Use Internationalization, as appropriate.
    case .onboarding: return "onboarding"
    case .notification: return "notification"
    case .app: return "in-app"
    case .settings: return "settings"
    }
  }
}

class AnalyticsManager: NSObject {

  var installationId:String

  static let shared = AnalyticsManager()

  override init() {
    self.installationId = "tempId"
    super.init()
  }
  
  class func tapsGetStartedButton(){
    track(event: "get-started", category: .onboarding)
  }
  
  class func tapsGetNotifiedButton(){
    track(event: "enable-notifications", category: .onboarding, label: "Get Notified")
  }

  class func selectsNotificationPerfmissions(authorizationStatus: UNAuthorizationStatus){
    var label = "not-determined"
    if authorizationStatus == UNAuthorizationStatus.authorized {
      label = "authorized"
    } else if authorizationStatus == UNAuthorizationStatus.denied {
      label = "denied"
    }
    track(event: "enable-notifications", category: .onboarding, label: label)
  }

  class func tapsEnableLocationButton(){
    track(event: "enable-location-tracking", category: .onboarding, label: "enable-location")
  }

  class func selectsLocationTrackingPerfmissions(status: CLAuthorizationStatus){
    var label = "not-determined"
    if status == CLAuthorizationStatus.authorizedWhenInUse {
      label = "authorized-when-in-use"
    } else if status == CLAuthorizationStatus.authorizedAlways {
      label = "authorized-alwaysb"
    } else if status == CLAuthorizationStatus.denied {
      label = "denied"
    }

    track(event: "enable-location-tracking", category: .onboarding, label:label)
  }

  class func notificationShown(post: Post, currentLocation: Location){
    track(event: "shows", category: .notification, label:post.link.absoluteString, location:currentLocation)
  }

  class func tapsNotificationDefaultTapToClickThrough(post: Post, currentLocation: Location){
    track(event: "taps", category: .notification, label:post.link.absoluteString, location:currentLocation)
  }

  class func tapsOpenInNotificationCTA(post: Post, currentLocation: Location){
    track(event: "open", category: .notification, label:post.link.absoluteString, location:currentLocation)
  }

  class func tapsShareInNotificationCTA(post: Post, currentLocation: Location){
    track(event: "share", category: .notification, label:post.link.absoluteString, location:currentLocation)
  }

  class func tapsPingMeLaterInNotificationCTA(post: Post, currentLocation: Location){
    track(event: "ping-me-later", category: .notification, label:post.link.absoluteString, location:currentLocation)
  }

  class func mapViewed(currentLocation: Location){
    track(event: "open-map", category: .app, location:currentLocation)
  }

  class func tapsOnPin(post: Post, currentLocation: Location){
    track(event: "click-pin", category: .app, label:post.link.absoluteString, location:currentLocation)
  }

  class func tapsOnViewArticle(post: Post, currentLocation: Location){
    track(event: "view-article", category: .app, label:post.link.absoluteString, location:currentLocation)
  }
  
  class func swipesCarousel(post: Post, currentLocation: Location){
    track(event: "swipe-carousel", category: .app, label:post.link.absoluteString, location:currentLocation)
  }

  class func changeNotificationSettings(enabled: Bool){
    if enabled {
      track(event: "enable-notifications", category: .settings)
    } else {
      track(event: "disable-notifications", category: .settings)
    }
  }

  class func changeLocationSettings(enabled: Bool){
    if enabled {
      track(event: "enable-location", category: .settings)
    } else {
      track(event: "disable-location", category: .settings)
    }
  }

  class func track(event: String, category: Category, label: String? = nil, location: Location? = nil) {
    AnalyticsManager.shared.track(event: event, category: category, label: label, location: location)
  }
  
  func track(event: String, category: Category, label: String? = nil, location: Location? = nil) {
    var data:[String:String] = [:]
    data["installation-id"] = installationId
    data["event-name"] = event
    data["event-category"] = category.description
    if label != nil {
      data["event-label"] = label
    }
    
    if location != nil {
      data["latitude"] = String(format:"%f", location!.latitude)
      data["longitude"] = String(format:"%f", location!.longitude)
    }

    print(data)
  }
  
  
}
