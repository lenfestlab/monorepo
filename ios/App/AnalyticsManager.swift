import UIKit
import UserNotifications
import CoreLocation
import Gloss
import GoogleReporter

typealias Meta = Dictionary<String, String>

enum Category: String {
  case onboarding, notification, settings
  case app = "in-app"
}

struct AnalyticsEvent {
  var name: String // NOTE: GA "action": https://goo.gl/opYrNg
  var category: Category
  var label: String? = ""
  var value: Int?
  var metadata: Meta = [:]

  init(
    name: String,
    metadata meta: Meta = [:],
    category: Category,
    label: String? = "",
    location: CLLocationCoordinate2D? = nil
    ) {
    self.name = name
    self.category = category
    self.label = label
    self.metadata = meta
    if location != nil {
      let lat = String(format:"%f", location!.latitude)
      let lng = String(format:"%f", location!.longitude)
      self.metadata["cd2"] = "\(lat),\(lng)"
    }
  }

  static func selectsNotificationPermissions(authorizationStatus: UNAuthorizationStatus) -> AnalyticsEvent{
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

  static let tapsSkipLocationButton = AnalyticsEvent(name: "enable-location-tracking", category: .onboarding, label: "skip")
  static let tapsSkipNotifificationsButton = AnalyticsEvent(name: "enable-notifications", category: .onboarding, label: "skip")

  static func selectsLocationTrackingPerfmissions(status: CLAuthorizationStatus) -> AnalyticsEvent {
    var label = "not-determined"
    if status == CLAuthorizationStatus.authorizedWhenInUse {
      label = "authorized-when-in-use"
    } else if status == CLAuthorizationStatus.authorizedAlways {
      label = "authorized-always"
    } else if status == CLAuthorizationStatus.denied {
      label = "denied"
    }

    return AnalyticsEvent(name: "enable-location-tracking", category: .onboarding, label:label)
  }

  static func notificationShown(post: Post, currentLocation: CLLocationCoordinate2D?) -> AnalyticsEvent {
    return AnalyticsEvent(name: "shows", category: .notification, label:post.link.absoluteString, location:currentLocation)
  }

  static func tapsNotificationDefaultTapToClickThrough(post: Post, currentLocation: CLLocationCoordinate2D?) -> AnalyticsEvent {
    return AnalyticsEvent(name:  "taps", category: .notification, label:post.link.absoluteString, location:currentLocation)
  }

  static func tapsOpenInNotificationCTA(post: Post, currentLocation: CLLocationCoordinate2D?) -> AnalyticsEvent {
    return AnalyticsEvent(name:  "open", category: .notification, label:post.link.absoluteString, location:currentLocation)
  }

  static func tapsShareInNotificationCTA(post: Post, currentLocation: CLLocationCoordinate2D?) -> AnalyticsEvent {
    return AnalyticsEvent(name:  "share", category: .notification, label:post.link.absoluteString, location:currentLocation)
  }

  static func tapsPingMeLaterInNotificationCTA(post: Post, currentLocation: CLLocationCoordinate2D?) -> AnalyticsEvent {
    return AnalyticsEvent(name:  "ping-me-later", category: .notification, label:post.link.absoluteString, location:currentLocation)
  }

  static func mapViewed(currentLocation: CLLocationCoordinate2D?, source url:URL?) -> AnalyticsEvent {
    var label = "direct"
    if url != nil {
      label = (url?.absoluteString)!
    }

    return AnalyticsEvent(name:  "open-map", category: .app, label:label, location:currentLocation)
  }

  static func tapsOnPin(post: Post, currentLocation: CLLocationCoordinate2D?) -> AnalyticsEvent {
    return AnalyticsEvent(name:  "click-pin", category: .app, label:post.link.absoluteString, location:currentLocation)
  }

  static func tapsOnViewArticle(post: Post, currentLocation: CLLocationCoordinate2D?) -> AnalyticsEvent {
    return AnalyticsEvent(name:  "view-article", category: .app, label:post.link.absoluteString, location:currentLocation)
  }

  static func swipesCarousel(post: Post, currentLocation: CLLocationCoordinate2D?) -> AnalyticsEvent {
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

  static func clearHistory() -> AnalyticsEvent {
    return AnalyticsEvent(name: "clear-history", category: .settings)
  }

}

class AnalyticsManager {

  private var ga: GoogleReporter

  init(_ env: Env) {
    self.ga = GoogleReporter.shared // NOTE: init private, must use `.shared`

    ga.configure(withTrackerId: env.get(.googleAnalyticsTrackingId))

    ga.anonymizeIP = false // pending GDPR compliance - https://git.io/fxuUt

    ga.quietMode = ["prod", "stag"].contains(env.get(.name))

    // "Client ID" - "cid" param - https://goo.gl/gexXmE
    // > This field is required if User ID (uid) is not specified in the request.
    // > This anonymously identifies a particular user, device, or browser instance.
    // > ...For mobile apps, this is randomly generated for each particular instance
    // > of an application install. The value of this field should be a random
    // > UUID (version 4)...
    // GoogleReporter defaults to `UIDevice().identifierForVendor`: https://git.io/fxuMc
    // > The value of this property is the same for apps that come from the same
    // > vendor running on the same device. A different value is returned for
    // > apps on the same device that come from different vendors, and for
    // > apps on different devices regardless of vendor.
    // NOTE: the value is reset if our app is deleted/reinstalled.
    ga.usesVendorIdentifier = true

    ga.customDimensionArguments = [
      // "t" (hit type) defaults to "event" - https://git.io/fxuMm
      "ds": "app", // "Data source" - https://goo.gl/BNTRMF

      //"installation-id"
      "cd1": env.installationId // same value as "cid" param above

      // "User ID" - https://goo.gl/ZXsk6q
      // > This is intended to be a known identifier for a user provided by the
      // > site owner/tracking library user. It must not itself be PII
      // > (personally identifiable information). The value should never be
      // > persisted in GA cookies or other Analytics provided storage.
      // NOTE: deliberately omitted; to persist id across deletes/installs,
      // fetch the iCloud ID (async), set as the "uid" custom dimension, per:
      // https://goo.gl/5QFvkb
      // "uid": env.userId,
    ]
  }

  func log(_ event: AnalyticsEvent) {
    ga.event(
      event.category.rawValue,
      action: event.name,
      label: (event.label ?? ""),
      parameters: event.metadata)
  }

}
