import UIKit
import UserNotifications
import CoreLocation
import Gloss
import GoogleReporter
import CoreMotion
import Firebase
typealias FirebaseAnalytics = Analytics


typealias Meta = Dictionary<String, String>

enum Category: String {
  case debug // for pre-production use only
  case onboarding, notification, settings
  case app = "in-app"
}

struct AnalyticsEvent {
  var name: String // NOTE: GA "action": https://goo.gl/opYrNg
  var category: Category
  var label: String? = ""
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
      let latlng = "\(lat),\(lng)"
      self.metadata["lat-lng"] = latlng
      self.metadata["cd2"] = latlng
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
  static let tapsEnableMotionButton = AnalyticsEvent(name: "enable-motion-tracking", category: .onboarding, label: "enable-motion")
  static let tapsEnableLocationButton = AnalyticsEvent(name: "enable-location-tracking", category: .onboarding, label: "enable-location")

  static let tapsSkipLocationButton = AnalyticsEvent(name: "enable-location-tracking", category: .onboarding, label: "skip")
  static let tapsSkipNotifificationsButton = AnalyticsEvent(name: "enable-notifications", category: .onboarding, label: "skip")
  static let tapsSkipMotionButton = AnalyticsEvent(name: "enable-motion", category: .onboarding, label: "skip")


  static func selectsLocationTrackingPermissions(status: CLAuthorizationStatus) -> AnalyticsEvent {
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

  static func selectsMotionTrackingPermissions(status: CMAuthorizationStatus) -> AnalyticsEvent {
    var label = "not-determined"
    if status == CMAuthorizationStatus.authorized {
      label = "authorized"
    } else if status == CMAuthorizationStatus.restricted {
      label = "restricted"
    } else if status == CMAuthorizationStatus.denied {
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

  static func tapsShareInNotificationCTA(url: URL, currentLocation: CLLocationCoordinate2D?) -> AnalyticsEvent {
    return AnalyticsEvent(name:  "share", category: .notification, label:url.absoluteString, location:currentLocation)
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

  static func notificationSkipped(_ location: CLLocationCoordinate2D?) -> AnalyticsEvent {
    return
      AnalyticsEvent(
        name: "notification-skipped",
        metadata: ["cause": "motion"],
        category: .debug,
        label: "motion",
        location: location)
  }

  static func regionEntered(source: String) -> AnalyticsEvent {
    return
      AnalyticsEvent(
        name: "region-entered",
        metadata: ["source": source],
        category: .debug,
        label: source)
  }

}

class AnalyticsManager {

  private let env: Env
  private var ga: GoogleReporter

  init(_ env: Env) {
    self.env = env
    self.ga = GoogleReporter.shared // NOTE: init private, must use `.shared`

    ga.configure(withTrackerId: env.get(.googleAnalyticsTrackingId))

    ga.anonymizeIP = false // pending GDPR compliance - https://git.io/fxuUt

    ga.quietMode = env.isNamed(.prod)

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

    // Firebase
    ["installation_id", "cd1"].forEach { propName in
      FirebaseAnalytics.setUserProperty(env.installationId, forName: propName)
    }

  }

  func log(_ event: AnalyticsEvent) {
    let action = event.name
    let category = event.category.rawValue
    let label = (event.label ?? "")

    // Google Analytics
    if ![.debug].contains(event.category) { // skip events used for debugging
      ga.event(category, action: action, label: label, parameters: event.metadata)
    }

    // Firebase
    guard env.isPreProduction else { return } // no need for FIR in prod yet
    // ... > Event name must contain only letters, numbers, or underscores
    let name = event.name.replacingOccurrences(of: "-", with: "_")
    var firebaseParams = event.metadata as Dictionary<String, NSObject>
    // > Event parameter name must contain only letters, numbers, or underscores: lat-lng
    firebaseParams.replacingOccurrencesInAllKeys(of: "-", with: "_")
    firebaseParams.merge([
      // > Parameter name uses reserved prefix. Ignoring parameter: ga_category
      "category": category as NSObject,
      // TODO: if FIR support requested in prod, must first resolve FIR/GA data
      // model incompatibility, eg:
      // > Event parameter value is too long. The maximum supported length is 100: https://...
      "label": label.prefix(100) as NSObject,
    ]) { (_, new) -> NSObject in new }
    FirebaseAnalytics.logEvent(name, parameters: firebaseParams)
  }

}

public extension Dictionary where Key: StringProtocol {

  public mutating func replacingOccurrencesInAllKeys(of: String, with: String) {
    for key in keys {
      // https://stackoverflow.com/questions/33180028/extend-dictionary-where-key-is-of-type-string
      if let newKey = String(describing: key).replacingOccurrences(of: of, with: with) as? Key {
        self[newKey] = removeValue(forKey: key)
      }
    }
  }
}
