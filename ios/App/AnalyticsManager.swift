import UIKit
import UserNotifications
import CoreLocation
import Gloss

struct AnalyticsEvent {
  var name: String
  var metadata: [String : String]

  init(name: String, metadata: [String: String] = [:], category: Category, label: String? = nil, location: Location? = nil) {
    var metadata:[String:String] = [:]
    metadata["event-category"] = category.description
    if label != nil {
      metadata["event-label"] = label
    }

    if location != nil {
      metadata["latitude"] = String(format:"%f", location!.latitude)
      metadata["longitude"] = String(format:"%f", location!.longitude)
    }

    self.name = name
    self.metadata = metadata
  }

  static func selectsNotificationPerfmissions(authorizationStatus: UNAuthorizationStatus) -> AnalyticsEvent{
    var label = "not-determined"
    if authorizationStatus == UNAuthorizationStatus.authorized {
      label = "authorized"
    } else if authorizationStatus == UNAuthorizationStatus.denied {
      label = "denied"
    }
    return AnalyticsEvent(name: "enable-notifications", category: .onboarding, label: label)
  }

  static let tapsGetStartedButton = AnalyticsEvent(name: "get-started", category: .onboarding)
  static let tapsGetNotifiedButton = AnalyticsEvent(name: "enable-notifications", category: .onboarding, label: "Get Notified")
  static let tapsEnableLocationButton = AnalyticsEvent(name: "enable-location-tracking", category: .onboarding, label: "enable-location")

  static func selectsLocationTrackingPerfmissions(status: CLAuthorizationStatus) -> AnalyticsEvent {
    var label = "not-determined"
    if status == CLAuthorizationStatus.authorizedWhenInUse {
      label = "authorized-when-in-use"
    } else if status == CLAuthorizationStatus.authorizedAlways {
      label = "authorized-alwaysb"
    } else if status == CLAuthorizationStatus.denied {
      label = "denied"
    }

    return AnalyticsEvent(name: "enable-location-tracking", category: .onboarding, label:label)
  }

  static func notificationShown(post: Post, currentLocation: Location) -> AnalyticsEvent {
    return AnalyticsEvent(name: "shows", category: .notification, label:post.link.absoluteString, location:currentLocation)
  }

  static func tapsNotificationDefaultTapToClickThrough(post: Post, currentLocation: Location) -> AnalyticsEvent {
    return AnalyticsEvent(name:  "taps", category: .notification, label:post.link.absoluteString, location:currentLocation)
  }

  static func tapsOpenInNotificationCTA(post: Post, currentLocation: Location) -> AnalyticsEvent {
    return AnalyticsEvent(name:  "open", category: .notification, label:post.link.absoluteString, location:currentLocation)
  }

  static func tapsShareInNotificationCTA(post: Post, currentLocation: Location) -> AnalyticsEvent {
    return AnalyticsEvent(name:  "share", category: .notification, label:post.link.absoluteString, location:currentLocation)
  }

  static func tapsPingMeLaterInNotificationCTA(post: Post, currentLocation: Location) -> AnalyticsEvent {
    return AnalyticsEvent(name:  "ping-me-later", category: .notification, label:post.link.absoluteString, location:currentLocation)
  }

  static func mapViewed(currentLocation: Location) -> AnalyticsEvent {
    return AnalyticsEvent(name:  "open-map", category: .app, location:currentLocation)
  }

  static func tapsOnPin(post: Post, currentLocation: Location) -> AnalyticsEvent {
    return AnalyticsEvent(name:  "click-pin", category: .app, label:post.link.absoluteString, location:currentLocation)
  }

  static func tapsOnViewArticle(post: Post, currentLocation: Location) -> AnalyticsEvent {
    return AnalyticsEvent(name:  "view-article", category: .app, label:post.link.absoluteString, location:currentLocation)
  }

  static func swipesCarousel(post: Post, currentLocation: Location) -> AnalyticsEvent {
    return AnalyticsEvent(name:  "swipe-carousel", category: .app, label:post.link.absoluteString, location:currentLocation)
  }

  static func changeNotificationSettings(enabled: Bool) -> AnalyticsEvent {
    if enabled {
      return AnalyticsEvent(name:  "enable-notifications", category: .settings)
    } else {
      return AnalyticsEvent(name:  "disable-notifications", category: .settings)
    }
  }

  static func changeLocationSettings(enabled: Bool) -> AnalyticsEvent {
    if enabled {
      return AnalyticsEvent(name:  "enable-location", category: .settings)
    } else {
      return AnalyticsEvent(name:  "disable-location", category: .settings)
    }
  }

}

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

protocol AnalyticsEngine: class {
  func sendAnalyticsEvent(named name: String, metadata: [String : String])
}

// Use this for testing local testing purposes
class LocalLogAnalyticsEngine: AnalyticsEngine {

  var installationId:String

  init() {
    self.installationId = "tempId"
  }

  func sendAnalyticsEvent(named name: String, metadata: [String: String] = [:]) {
    let data = metadata.merging( ["installation-id" : installationId, "event-name": name], uniquingKeysWith: { (_, new) in new })
    print(data)
  }

}

class AnalyticsManager: NSObject {

  static let shared = AnalyticsManager(engine: LocalLogAnalyticsEngine())

  private let engine: AnalyticsEngine

  init(engine: AnalyticsEngine) {
    self.engine = engine
  }

  func log(_ event: AnalyticsEvent) {
    engine.sendAnalyticsEvent(named: event.name, metadata: event.metadata)
  }

}
