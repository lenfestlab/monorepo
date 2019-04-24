import UIKit
import UserNotifications
import CoreLocation
import Gloss
import GoogleReporter
import CoreMotion
import Firebase
import Amplitude

typealias FirebaseAnalytics = Analytics

extension UIApplication.State: CustomStringConvertible, CustomDebugStringConvertible {
  public var description: String {
    switch self {
    case .active: return "active"
    case .inactive: return "inactive"
    case .background: return "background"
    @unknown default: return "unknown"
    }
  }
  public var debugDescription: String {
    return description
  }
}


typealias Meta = Dictionary<String, String>

enum AnalyticsCategory: String {
  case debug // for pre-production use only
  case onboarding, notification, settings, background, detail, card, filter, navigation, tab, search
  case app = "in-app"
}

struct AnalyticsEvent {
  var name: String // NOTE: GA "action": https://goo.gl/opYrNg
  var category: AnalyticsCategory
  var label: String? = ""
  var metadata: Meta = [:]

  init(
    name: String,
    metadata meta: Meta = [:],
    category: AnalyticsCategory,
    label: String? = "",
    cd2: String? = nil,
    cd6: String? = nil,
    cd7: String? = nil,
    cd8: String? = nil,
    cd9: String? = nil,
    cd10: String? = nil,
    cd11: String? = nil
    ) {
    self.name = name
    self.category = category
    self.label = label
    self.metadata = meta
    if let cd2 = cd2 {
      self.metadata["cd2"] = cd2
    }
    if let cd6 = cd6 {
      self.metadata["cd6"] = cd6
    }
    if let cd7 = cd7 {
      self.metadata["cd7"] = cd7
    }
    if let cd8 = cd8 {
      self.metadata["cd8"] = cd8
    }
    if let cd9 = cd9 {
      self.metadata["cd9"] = cd9
    }
    if let cd10 = cd10 {
      self.metadata["cd10"] = cd10
    }
    if let cd11 = cd11 {
      self.metadata["cd11"] = cd11
    }

    self.metadata["cd12"] = UIApplication.shared.applicationState.description
  }


  init(
    name: String,
    category: AnalyticsCategory,
    label: String? = "",
    location: CLLocationCoordinate2D? = nil
    ) {
    var latlng : String? = nil
    var meta : Meta = [:]
    if let location = location {
      latlng = String(format:"%f,%f", location.latitude, location.longitude)
      meta["lat-lng"] = latlng
    }
    self.init(name: name, metadata: meta, category: category, label: label, cd2: latlng)
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

  static let tapsEnableLocationButton = AnalyticsEvent(name: "enable-location", category: .onboarding, label: "enable-location")
  static let tapsSkipLocationButton = AnalyticsEvent(name: "enable-location", category: .onboarding, label: "skip")

  static let tapsGetNotifiedButton = AnalyticsEvent(name: "enable-notifications", category: .onboarding, label: "enable-notifications")
  static let tapsSkipNotifificationsButton = AnalyticsEvent(name: "enable-notifications", category: .onboarding, label: "skip")

  static let tapsSubmitEmailButton = AnalyticsEvent(name: "email", category: .onboarding, label: "submitted")
  static let tapsSkipEmailButton = AnalyticsEvent(name: "email", category: .onboarding, label: "skip")

  static func selectsLocationTrackingPermissions(status: CLAuthorizationStatus) -> AnalyticsEvent {
    var label = "not-determined"
    if status == CLAuthorizationStatus.authorizedWhenInUse {
      label = "authorized-when-in-use"
    } else if status == CLAuthorizationStatus.authorizedAlways {
      label = "authorized-always"
    } else if status == CLAuthorizationStatus.denied {
      label = "denied"
    }

    return AnalyticsEvent(name: "enable-location", category: .onboarding, label:label)
  }

  static func mapViewed(currentLocation: CLLocationCoordinate2D?, source url:URL?) -> AnalyticsEvent {
    var label = "direct"
    if url != nil {
      label = (url?.absoluteString)!
    }

    return AnalyticsEvent(name:  "open-map", category: .app, label:label, location:currentLocation)
  }

  static func tapsOnPin(place: Place) -> AnalyticsEvent {
    return AnalyticsEvent(name: "click-pin", category: .app, label: place.name, cd7: place.analyticsCuisine, cd8: place.analyticsNeighborhood, cd9: place.analyticsBells, cd10: place.analyticsPrice, cd11: place.analyticsReviewer)
  }

  static func tapsOnCard(place: Place, controllerIdentifierKey: String) -> AnalyticsEvent {
    return AnalyticsEvent(name: "tap", category: .card, label: place.name, cd6: controllerIdentifierKey, cd7: place.analyticsCuisine, cd8: place.analyticsNeighborhood, cd9: place.analyticsBells, cd10: place.analyticsPrice, cd11: place.analyticsReviewer)
  }

  static func swipesCarousel(place: Place, currentLocation: CLLocationCoordinate2D?) -> AnalyticsEvent {
    return AnalyticsEvent(name: "swipe-carousel", category: .app, label: place.name, cd7: place.analyticsCuisine, cd8: place.analyticsNeighborhood, cd9: place.analyticsBells, cd10: place.analyticsPrice, cd11: place.analyticsReviewer)
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

  static func changeMotionSettings(enabled: Bool) -> AnalyticsEvent {
    let prefix = enabled ? "enable" : "disable"
    return AnalyticsEvent(name:  "\(prefix)-motion", category: .settings)
  }

  static func clearHistory() -> AnalyticsEvent {
    return AnalyticsEvent(name: "clear-history", category: .settings)
  }

  static func notificationSkipped(_ location: CLLocationCoordinate2D?) -> AnalyticsEvent {
    return
      AnalyticsEvent(
        name: "skip",
        category: .notification,
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

  static func locationChanged(_ location: CLLocationCoordinate2D?) -> AnalyticsEvent {
    return AnalyticsEvent(name: "location-changed", category: .background, location: location)
  }

  static func tapsFullReviewButton(place: Place) -> AnalyticsEvent {
    return AnalyticsEvent(name: "taps-full-review-button", category: .detail, label: place.name, cd7: place.analyticsCuisine, cd8: place.analyticsNeighborhood, cd9: place.analyticsBells, cd10: place.analyticsPrice, cd11: place.analyticsReviewer)

  }

  static func tapsReservationButton(place: Place) -> AnalyticsEvent {
    return AnalyticsEvent(name: "taps-reservation-button", category: .detail, label: place.name, cd7: place.analyticsCuisine, cd8: place.analyticsNeighborhood, cd9: place.analyticsBells, cd10: place.analyticsPrice, cd11: place.analyticsReviewer)

  }

  static func tapsWebsiteButton(place: Place) -> AnalyticsEvent {
    return AnalyticsEvent(name: "taps-website-button", category: .detail, label: place.name, cd7: place.analyticsCuisine, cd8: place.analyticsNeighborhood, cd9: place.analyticsBells, cd10: place.analyticsPrice, cd11: place.analyticsReviewer)

  }


  static func tapsCallButton(place: Place) -> AnalyticsEvent {
    return AnalyticsEvent(name: "taps-call-button", category: .detail, label: place.name, cd7: place.analyticsCuisine, cd8: place.analyticsNeighborhood, cd9: place.analyticsBells, cd10: place.analyticsPrice, cd11: place.analyticsReviewer)
  }

  static func searchForRestaurant(searchTerm: String) -> AnalyticsEvent {
    return AnalyticsEvent(name: "search", category: .navigation, label:searchTerm)
  }

  static let tapsSettingsButton = AnalyticsEvent(name: "settings", category: .navigation)

  static let tapsAllRestaurant = AnalyticsEvent(name: "all-restaurant", category: .tab)
  static let tapsGuides = AnalyticsEvent(name: "guides", category: .tab, label: "home")
  static let tapsMyList = AnalyticsEvent(name: "my-list", category: .tab)

  static func switchesViewCarouselToList(page: String) -> AnalyticsEvent {
    return AnalyticsEvent(name: "view-list", category: .navigation, label: page)
  }

  static func switchesViewListToCarousel(page: String) -> AnalyticsEvent {
    return AnalyticsEvent(name: "view-carousel", category: .navigation, label: page)
  }

  static let tapsFilterButton = AnalyticsEvent(name: "filter", category: .navigation)
  static let tapsSortButton = AnalyticsEvent(name: "taps-sort-button", category: .navigation)
  static let tapsCuisineButton = AnalyticsEvent(name: "cuisine", category: .navigation)

  static func tapsOnGuideCell(category: Category) -> AnalyticsEvent {
    return AnalyticsEvent(name: "guides", category: .navigation, label: category.name)
  }

  static func noResultsWhenSearching(searchTerm: String) -> AnalyticsEvent {
    return AnalyticsEvent(name: "no-results", category: .search, label: searchTerm)
  }

  static func noResultsWhenFiltering(filterModule: FilterModule) -> AnalyticsEvent {
    let cuisines = filterModule.categories.map { $0.name ?? "" }.joined(separator: ",")
    let neighborhoods = filterModule.nabes.map { $0.name }.joined(separator: ",")
    let bells = filterModule.ratings.map { "\($0)" }.joined(separator: ",")
    let price = filterModule.prices.map { "\($0)" }.joined(separator: ",")
    let reviewer = filterModule.authors.map { $0.name }.joined(separator: ",")
    return AnalyticsEvent(name: "no-results", category: .filter, cd7: cuisines, cd8: neighborhoods, cd9: bells, cd10: price, cd11: reviewer)
  }

  static func tapsFavoriteButtonOnCard(save: Bool, place: Place, controllerIdentifierKey: String) -> AnalyticsEvent {
    let name = save ? "save" : "unsave"
    return AnalyticsEvent(name: name, category: .card, label: place.name, cd6: controllerIdentifierKey, cd7: place.analyticsCuisine, cd8: place.analyticsNeighborhood, cd9: place.analyticsBells, cd10: place.analyticsPrice, cd11: place.analyticsReviewer)
  }

  static func tapsFavoriteButtonOnDetailPage(save: Bool, place: Place) -> AnalyticsEvent {
    let name = save ? "save" : "unsave"
    return AnalyticsEvent(name: name, category: .detail, label: place.name, cd7: place.analyticsCuisine, cd8: place.analyticsNeighborhood, cd9: place.analyticsBells, cd10: place.analyticsPrice, cd11: place.analyticsReviewer)
  }

  static func clicksCuisineApplyButton(cuisines: [Category]) -> AnalyticsEvent {
    return AnalyticsEvent(name: "apply-cuisine", category: .filter, cd7: cuisines.map{ $0.name ?? ""}.joined(separator: ","))
  }

  static func clicksNeighborhoodApplyButton(nabes: [Neighborhood]) -> AnalyticsEvent {
    return AnalyticsEvent(name: "apply-neighborhood", category: .filter, cd8: nabes.map{ $0.name }.joined(separator: ","))
  }

  static func selectsSortFromFilter(mode: SortMode, category: AnalyticsCategory) -> AnalyticsEvent {
    return AnalyticsEvent(name:  "sort-selected", category: category, label:mode.rawValue)
  }

  static func selectsMultipleCriteriaToFilterBy(filterModule: FilterModule, mode: SortMode) -> AnalyticsEvent {
    let cuisines = filterModule.categories.map { $0.name ?? "" }.joined(separator: ",")
    let neighborhoods = filterModule.nabes.map { $0.name }.joined(separator: ",")
    let bells = filterModule.ratings.map { "\($0)" }.joined(separator: ",")
    let price = filterModule.prices.map { "\($0)" }.joined(separator: ",")
    let reviewer = filterModule.authors.map { $0.name }.joined(separator: ",")
    return AnalyticsEvent(name: "search", category: .filter, label:mode.rawValue, cd7: cuisines, cd8: neighborhoods, cd9: bells, cd10: price, cd11: reviewer)
  }

  static let appLaunched = AnalyticsEvent(name: "launched", category: .app)

  static func locationMeta(_ location: CLLocationCoordinate2D?) -> (latlng: String?, meta: Meta) {
    var latlng: String? = nil
    var meta: Meta = [:]
    if let location = location {
      latlng = String(format:"%f,%f", location.latitude, location.longitude)
      meta["lat-lng"] = latlng
    }
    return (latlng, meta)
  }

  static func notificationShown(place: Place, location: CLLocationCoordinate2D?) -> AnalyticsEvent {
    let (latlng, meta) = locationMeta(location)
    return AnalyticsEvent(name: "shows", metadata: meta, category: .notification, label: place.name, cd2: latlng, cd7: place.analyticsCuisine, cd8: place.analyticsNeighborhood, cd9: place.analyticsBells, cd10: place.analyticsPrice, cd11: place.analyticsReviewer)
  }

  static func tapsNotificationDefaultTapToClickThrough(place: Place, location: CLLocationCoordinate2D? = nil) -> AnalyticsEvent {
    let (latlng, meta) = locationMeta(location)
    return AnalyticsEvent(name: "taps", metadata: meta, category: .notification, label: place.name, cd2: latlng, cd7: place.analyticsCuisine, cd8: place.analyticsNeighborhood, cd9: place.analyticsBells, cd10: place.analyticsPrice, cd11: place.analyticsReviewer)
  }

  static func tapsReadInNotificationCTA(place: Place, location: CLLocationCoordinate2D?) -> AnalyticsEvent {
    let (latlng, meta) = locationMeta(location)
    return AnalyticsEvent(name: "read", metadata: meta, category: .notification, label: place.name, cd2: latlng, cd7: place.analyticsCuisine, cd8: place.analyticsNeighborhood, cd9: place.analyticsBells, cd10: place.analyticsPrice, cd11: place.analyticsReviewer)
  }

  static func tapsShareInNotificationCTA(place: Place, location: CLLocationCoordinate2D?) -> AnalyticsEvent {
    let (latlng, meta) = locationMeta(location)
    return AnalyticsEvent(name: "share", metadata: meta, category: .notification, label: place.name, cd2: latlng, cd7: place.analyticsCuisine, cd8: place.analyticsNeighborhood, cd9: place.analyticsBells, cd10: place.analyticsPrice, cd11: place.analyticsReviewer)
  }

  static func tapsSaveInNotificationCTA(toSaved: Bool, place: Place, location: CLLocationCoordinate2D?) -> AnalyticsEvent {
    let name = toSaved ? "add" : "remove"
    let (latlng, meta) = locationMeta(location)
    return AnalyticsEvent(name: name, metadata: meta, category: .notification, label: place.name, cd2: latlng, cd7: place.analyticsCuisine, cd8: place.analyticsNeighborhood, cd9: place.analyticsBells, cd10: place.analyticsPrice, cd11: place.analyticsReviewer)
  }

}

class AnalyticsManager {

  private let env: Env
  private var ga: GoogleReporter
  private let amplitude: Amplitude

  init(_ env: Env) {
    self.env = env
    self.ga = GoogleReporter.shared // NOTE: init private, must use `.shared`
    self.amplitude = Amplitude.instance()

    ga.configure(withTrackerId: env.get(.googleAnalyticsTrackingId))
    amplitude.initializeApiKey(env.get(.amplitudeApiKey))

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

    let installationId = env.installationId
    ga.customDimensionArguments = [
      // "t" (hit type) defaults to "event" - https://git.io/fxuMm
      "ds": "app", // "Data source" - https://goo.gl/BNTRMF

      //"installation-id"
      "cd1": installationId // same value as "cid" param above

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

    // Firebase, Amplitude
    ["installation_id", "cd1"].forEach { propName in
      FirebaseAnalytics.setUserProperty(installationId, forName: propName)
      amplitude.setUserProperties([propName: installationId])
    }

  }

  func log(_ event: AnalyticsEvent) {
    let action = event.name
    let category = event.category.rawValue
    let label = (event.label ?? "")

    // skip debugging events
    guard (event.category != .debug) else { return }
    let vetted: Bool = env.isPreProduction

    // NOTE: workaround iOS 12 networking bug that drops requests prematurely
    // GH discussion: https://git.io/fpY6S
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
      // > The handler is called synchronously on the main thread, blocking
      // > the app’s suspension momentarily while the app is notified.
      // - https://goo.gl/yRgxEG
      var backgroundTaskID: UIBackgroundTaskIdentifier = UIBackgroundTaskIdentifier(rawValue: 0)
      backgroundTaskID = UIApplication.shared.beginBackgroundTask(withName: "GA") {
        UIApplication.shared.endBackgroundTask(backgroundTaskID)
        backgroundTaskID = UIBackgroundTaskIdentifier.invalid
      }

      // omit from prod pending QA:
      guard vetted else { return }

      // Google Analytics
      GoogleReporter.shared.event(
        category,
        action: action,
        label: label,
        parameters: event.metadata)

      // event + property map services (eg, Amplitude, Firebase)

      // Firebase
      // ... > Event name must contain only letters, numbers, or underscores
      let name = event.name.replacingOccurrences(of: "-", with: "_")
      // > Event parameter name must contain only letters, numbers, or underscores: lat-lng
      var props = event.metadata as Dictionary<String, NSObject>
      props.replacingOccurrencesInAllKeys(of: "-", with: "_")
      props.merge([
        // > Parameter name uses reserved prefix. Ignoring parameter: ga_category
        "category": category as NSObject,
        // TODO: if FIR support requested in prod, must first resolve FIR/GA data
        // model incompatibility, eg:
        // > Event parameter value is too long. The maximum supported length is 100
        "label": label.prefix(100) as NSObject,
      ]) { (_, new) -> NSObject in new }
      FirebaseAnalytics.logEvent(name, parameters: props)

      // Amplitude
      Amplitude.instance().logEvent(name, withEventProperties: props)

      // iOS 12 networking bug fix completion
      UIApplication.shared.endBackgroundTask(backgroundTaskID)
      backgroundTaskID = UIBackgroundTaskIdentifier.invalid
    }

  }

  func mergeCustomDimensions(cds: Dictionary<String, String>) -> Void {
    ga.customDimensionArguments?.merge(cds, uniquingKeysWith: { (_, new) -> String in
      return new
    })
  }

}

public extension Dictionary where Key: StringProtocol {

  mutating func replacingOccurrencesInAllKeys(of: String, with: String) {
    for key in keys {
      // https://stackoverflow.com/questions/33180028/extend-dictionary-where-key-is-of-type-string
      if let newKey = String(describing: key).replacingOccurrences(of: of, with: with) as? Key {
        self[newKey] = removeValue(forKey: key)
      }
    }
  }
}
