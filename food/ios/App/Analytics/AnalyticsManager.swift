import UIKit
import UserNotifications
import CoreLocation
import GoogleReporter
import CoreMotion
import Firebase
import Amplitude
import SwiftDate
import RxSwift
import NSObject_Rx
import MapKit

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
  case onboarding, notification, settings, background, detail, card, filter, navigation, tab, search, region
  case app = "in-app"
}

struct AnalyticsEvent {
  var name: String // NOTE: GA "action": https://goo.gl/opYrNg
  var category: AnalyticsCategory
  var label: String? = ""
  var metadata: Meta = [:]
  let env = Env()

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
    cd11: String? = nil,
    cd13: String? = nil,
    cd18: String? = nil, // Contact meta - "phone, reservations, website, review"
    cd19: String? = nil // Visit Criteria - "viewed, saved"
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

    /* NOTE: disabling, not threadsafe
    self.metadata["cd12"] = UIApplication.shared.applicationState.description
     */

    if let cd13 = cd13 {
      self.metadata["cd13"] = cd13
    }
    if let cd18 = cd18 {
      self.metadata["cd18"] = cd18
    }
    if let cd19 = cd19 {
      self.metadata["cd19"] = cd19
    }

    let buildVersion = env.buildVersion
    self.metadata["cd14"] = buildVersion
    self.metadata["build-version"] = buildVersion

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

  static func latestLocationPermission(status: CLAuthorizationStatus) -> AnalyticsEvent {
    return AnalyticsEvent(name: "latest-location-status",
                          category: .app,
                          label: status.description)
  }

  static func tapsOnPin(place: Place) -> AnalyticsEvent {
    return AnalyticsEvent(name: "click-pin", category: .app, label: place.name, cd7: place.analyticsCuisine, cd8: place.analyticsNeighborhood, cd9: place.analyticsBells, cd10: place.analyticsPrice, cd11: place.analyticsReviewer)
  }

  static func tapsOnCard(place: Place, controllerIdentifierKey: String, _ currentLocation: CLLocation?) -> AnalyticsEvent {
    let cd19 = place.visitRadiusContains(currentLocation) ? "inside" : "outside"
    return AnalyticsEvent(name: "tap", category: .card, label: place.name, cd6: controllerIdentifierKey, cd7: place.analyticsCuisine, cd8: place.analyticsNeighborhood, cd9: place.analyticsBells, cd10: place.analyticsPrice, cd11: place.analyticsReviewer, cd18: place.contactMeta, cd19: cd19)
  }

  static func swipesCarousel(place: Place) -> AnalyticsEvent {
    return AnalyticsEvent(name: "swipe-carousel", category: .app, label: place.name, cd7: place.analyticsCuisine, cd8: place.analyticsNeighborhood, cd9: place.analyticsBells, cd10: place.analyticsPrice, cd11: place.analyticsReviewer)
  }

  static func swipesGuideGroupCarousel(guideGroup: GuideGroup, guide: Category) -> AnalyticsEvent {
    return AnalyticsEvent(name: "swipe-guide-group-carousel", category: .app, label: guideGroup.title, cd7: guide.name, cd8: guide.identifier)
  }

  static func tapsGuideGroupCellSeeAllButton(guideGroup: GuideGroup) -> AnalyticsEvent {
    return AnalyticsEvent(name: "taps-guide-group-cell-see-all-button", category: .app, label: guideGroup.title, cd8: guideGroup.identifier)
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

  static func backgroundTrackingforLocation(_ location: CLLocationCoordinate2D?) -> AnalyticsEvent {
    return AnalyticsEvent(name: "location", category: .background, location: location)
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
    return AnalyticsEvent(name: "view-map", category: .navigation, label: page)
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
    let cuisines =
      filterModule.categories
        .compactMap({ $0.name })
        .joined(separator: ",")
    let neighborhoods =
      filterModule.nabes
        .compactMap({ $0.name })
        .joined(separator: ",")
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
    return AnalyticsEvent(name: "apply-cuisine", category: .filter, cd7: cuisines.map{ $0.name }.joined(separator: ","))
  }

  static func clicksNeighborhoodApplyButton(nabes: [Neighborhood]) -> AnalyticsEvent {
    let nabeNames = nabes.map({ $0.name }).compactMap({$0})
    return AnalyticsEvent(name: "apply-neighborhood", category: .filter, cd8: nabeNames.joined(separator: ","))
  }

  static func selectsSortFromFilter(mode: SortMode, category: AnalyticsCategory) -> AnalyticsEvent {
    return AnalyticsEvent(name:  "sort-selected", category: category, label:mode.rawValue)
  }

  static func selectsMultipleCriteriaToFilterBy(filterModule: FilterModule, mode: SortMode) -> AnalyticsEvent {
    let cuisines = filterModule.categories.map({ $0.name }).compactMap({$0}).joined(separator: ",")
    let neighborhoods = filterModule.nabes.map({ $0.name }).compactMap({$0}).joined(separator: ",")
    let bells = filterModule.ratings.map { "\($0)" }.joined(separator: ",")
    let price = filterModule.prices.map { "\($0)" }.joined(separator: ",")
    let reviewer = filterModule.authors.map { $0.name }.joined(separator: ",")
    return AnalyticsEvent(name: "search", category: .filter, label:mode.rawValue, cd7: cuisines, cd8: neighborhoods, cd9: bells, cd10: price, cd11: reviewer)
  }

  enum LaunchSource: String {
    case direct, notification
  }
  static func appLaunched(_ source: LaunchSource) -> AnalyticsEvent {
    return AnalyticsEvent(name: "launched", category: .app, label: source.rawValue)
  }

  static func locationMeta(_ location: CLLocationCoordinate2D?) -> (latlng: String?, meta: Meta) {
    var latlng: String? = nil
    var meta: Meta = [:]
    if let location = location {
      latlng = String(format:"%f,%f", location.latitude, location.longitude)
      meta["lat-lng"] = latlng
    }
    return (latlng, meta)
  }

  typealias NotificationCategory = NotificationManager.Category

  static func notificationShown(_ category: NotificationCategory, place: Place, location: CLLocationCoordinate2D?) -> AnalyticsEvent {
    let (latlng, meta) = locationMeta(location)
    return AnalyticsEvent(name: "shows", metadata: meta, category: .notification, label: place.name, cd2: latlng, cd7: place.analyticsCuisine, cd8: place.analyticsNeighborhood, cd9: place.analyticsBells, cd10: place.analyticsPrice, cd11: place.analyticsReviewer, cd13: category.analyticsName)
  }

  static func tapsNotificationDefaultTapToClickThrough(_ category: NotificationCategory, place: Place, location: CLLocationCoordinate2D? = nil) -> AnalyticsEvent {
    let (latlng, meta) = locationMeta(location)
    return AnalyticsEvent(name: "taps", metadata: meta, category: .notification, label: place.name, cd2: latlng, cd7: place.analyticsCuisine, cd8: place.analyticsNeighborhood, cd9: place.analyticsBells, cd10: place.analyticsPrice, cd11: place.analyticsReviewer, cd13: category.analyticsName)
  }

  static func tapsReadInNotificationCTA(_ category: NotificationCategory, place: Place, location: CLLocationCoordinate2D?) -> AnalyticsEvent {
    let (latlng, meta) = locationMeta(location)
    return AnalyticsEvent(name: "read", metadata: meta, category: .notification, label: place.name, cd2: latlng, cd7: place.analyticsCuisine, cd8: place.analyticsNeighborhood, cd9: place.analyticsBells, cd10: place.analyticsPrice, cd11: place.analyticsReviewer, cd13: category.analyticsName)
  }

  static func tapsShareInNotificationCTA(_ category: NotificationCategory, place: Place, location: CLLocationCoordinate2D?) -> AnalyticsEvent {
    let (latlng, meta) = locationMeta(location)
    return AnalyticsEvent(name: "share", metadata: meta, category: .notification, label: place.name, cd2: latlng, cd7: place.analyticsCuisine, cd8: place.analyticsNeighborhood, cd9: place.analyticsBells, cd10: place.analyticsPrice, cd11: place.analyticsReviewer, cd13: category.analyticsName)
  }

  static func tapsSaveInNotificationCTA(_ category: NotificationCategory, toSaved: Bool, place: Place, location: CLLocationCoordinate2D?) -> AnalyticsEvent {
    let name = toSaved ? "add" : "remove"
    let (latlng, meta) = locationMeta(location)
    return AnalyticsEvent(name: name, metadata: meta, category: .notification, label: place.name, cd2: latlng, cd7: place.analyticsCuisine, cd8: place.analyticsNeighborhood, cd9: place.analyticsBells, cd10: place.analyticsPrice, cd11: place.analyticsReviewer, cd13: category.analyticsName)
  }

  static func regionDidChange(_ region: MKCoordinateRegion) -> AnalyticsEvent {
    let latlng = String(format:"%f,%f", region.center.latitude, region.center.longitude)
    let latDelta = String(format:"%f", region.span.latitudeDelta)
    let lngDelta = String(format:"%f", region.span.longitudeDelta)

    return AnalyticsEvent(name: latDelta, category: .region, label: lngDelta, cd2: latlng)
  }

  static func closeCuisine(cuisines: [Category]) -> AnalyticsEvent {
    return AnalyticsEvent(name: "close-cuisine", category: .filter, cd7: cuisines.map{ $0.name }.joined(separator: ","))
  }

  static func closeSort() -> AnalyticsEvent {
    return AnalyticsEvent(name: "close-sort", category: .filter)
  }

  static func closeFilter(filterModule: FilterModule) -> AnalyticsEvent {
    let cuisines = filterModule.categories.map({ $0.name }).compactMap({$0}).joined(separator: ",")
    let neighborhoods = filterModule.nabes.map({ $0.name }).compactMap({$0}).joined(separator: ",")
    let bells = filterModule.ratings.map { "\($0)" }.joined(separator: ",")
    let price = filterModule.prices.map { "\($0)" }.joined(separator: ",")
    let reviewer = filterModule.authors.map { $0.name }.joined(separator: ",")
    return AnalyticsEvent(name: "close-filter", category: .filter, cd7: cuisines, cd8: neighborhoods, cd9: bells, cd10: price, cd11: reviewer)
  }

  static func placeEvent(
    kind: PlaceEvent.Kind,
    place: Place,
    coordinate: CLLocationCoordinate2D? = nil
    ) -> AnalyticsEvent {
    let (latlng, meta) = locationMeta(coordinate)
    return AnalyticsEvent(
      name: kind.name,
      metadata: meta,
      category: .debug,
      label: place.name,
      cd2: latlng,
      cd7: place.analyticsCuisine,
      cd8: place.analyticsNeighborhood,
      cd9: place.analyticsBells,
      cd10: place.analyticsPrice,
      cd11: place.analyticsReviewer
    )
  }

  static func visited(
    place: Place,
    coordinate: CLLocationCoordinate2D?,
    triggers: [String] = []
    ) -> AnalyticsEvent {
    let (latlng, meta) = locationMeta(coordinate)
    return AnalyticsEvent(
      name: "visited",
      metadata: meta,
      category: .background,
      label: place.name,
      cd2: latlng,
      cd7: place.analyticsCuisine,
      cd8: place.analyticsNeighborhood,
      cd9: place.analyticsBells,
      cd10: place.analyticsPrice,
      cd11: place.analyticsReviewer,
      cd19: triggers.joined(separator: ","))
  }

  static func error(
    _ error: Error
    ) -> AnalyticsEvent {
    return AnalyticsEvent(
      name: "error",
      category: .debug,
      label: error.localizedDescription
    )
  }

}

class AnalyticsManager: NSObject {

  private let env: Env
  private let locationManager: LocationManager
  private let amplitude: Amplitude
  private let backgroundQueue = DispatchQueue.global(qos: .background)

  static let separator = ","

  init(env: Env, locationManager: LocationManager) {
    self.env = env
    self.locationManager = locationManager
    self.amplitude = Amplitude.instance()
    super.init()
    let installationId = env.installationId

    let gaId = env.get(.googleAnalyticsTrackingId)
    backgroundQueue.sync {
      let ga = GoogleReporter.shared // NOTE: init private, must use `.shared`
      ga.configure(withTrackerId: gaId)
      ga.anonymizeIP = false // pending GDPR compliance - https://git.io/fxuUt
      ga.quietMode = true

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
        "cd1": installationId // same value as "cid" param above
      ]
    }

    amplitude.initializeApiKey(env.get(.amplitudeApiKey))

    // Firebase, Amplitude
    ["installation_id", "cd1"].forEach { propName in
      FirebaseAnalytics.setUserProperty(installationId, forName: propName)
      amplitude.setUserProperties([propName: installationId])
    }

    self.observeLocationManager()
  }

  func log(_ event: AnalyticsEvent) {
    let action = event.name
    let category = event.category.rawValue
    let label = (event.label ?? "")

    // NOTE: workaround iOS 12 networking bug that drops requests prematurely
    // GH discussion: https://git.io/fpY6S

    backgroundQueue.asyncAfter(deadline: .now() + 0.1) {
      // > The handler is called synchronously on the main thread, blocking
      // > the app’s suspension momentarily while the app is notified.
      // - https://goo.gl/yRgxEG
      var backgroundTaskID: UIBackgroundTaskIdentifier = UIBackgroundTaskIdentifier(rawValue: 0)
      backgroundTaskID = UIApplication.shared.beginBackgroundTask(withName: "GA") {
        UIApplication.shared.endBackgroundTask(backgroundTaskID)
        backgroundTaskID = UIBackgroundTaskIdentifier.invalid
      }

      // Google Analytics
      GoogleReporter.shared.event(
        category,
        action: action,
        label: label,
        parameters: event.metadata)

      // event + property map services (eg, Amplitude, Firebase)

      // spare FIR/Amplitude format-incompat events
      if (event.category == .region) { return }

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
    backgroundQueue.sync {
      GoogleReporter.shared.customDimensionArguments?.merge(cds, uniquingKeysWith: { (_, new) -> String in
        return new
      })
    }
  }

  // analyze location in hours beginning: 8am, 4pm and midnight
  func logLocationChange(_ newLocation: CLLocation) {
    let region =
      Region(calendar: Calendars.gregorian,
             zone: Zones.autoUpdating, // default is GMT: https://git.io/fpAIZ
        locale: Locale.autoupdatingCurrent)
    let now = Date().in(region: region)
    let timestamp = newLocation.timestamp.in(region: region)
    guard timestamp.isInside(date: now, granularity: .minute) else {
      return print("\t skip stale location")
    }
    let windowHourStarts = env.isPreProduction ? Array(0..<23) : [0, 8, 16]
    let windowHours = windowHourStarts.map { now.dateBySet(hour: $0, min: 0, secs: 0)! }
    let isInWindow: Bool = windowHours.contains { beginsAt -> Bool in
      let endsAt = 1.hours.from(beginsAt)!.in(region: region)
      return now.isInRange(date: beginsAt, and: endsAt)
    }
    guard isInWindow else {
      return print("location changed outside window")
    }
    log(.backgroundTrackingforLocation(newLocation.coordinate))
  }

  private func observeLocationManager() {
    locationManager.significantLocation$
      .do(onNext: { [weak self] location in
        guard let `self` = self else { return print("MIA: self") }
        let region =
          Region(calendar: Calendars.gregorian,
                 zone: Zones.autoUpdating, // default is GMT: https://git.io/fpAIZ
            locale: Locale.autoupdatingCurrent)
        let now = Date().in(region: region)
        let timestamp = location.timestamp.in(region: region)
        guard timestamp.isInside(date: now, granularity: .minute) else { return }
        self.logLocationChange(location)
      })
      .subscribe()
      .disposed(by: rx.disposeBag)

    locationManager.placemark$
      .subscribe(onNext: { [weak self] placemark in
        guard
          let locality = placemark.locality,
          let subLocality = placemark.subLocality,
          let postalCode = placemark.postalCode
          else { return print("MIA: placemark") }
        self?.mergeCustomDimensions(cds: [
          "cd15": locality,
          "cd16": subLocality,
          "cd17": postalCode
          ])
      })
      .disposed(by: rx.disposeBag)
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
