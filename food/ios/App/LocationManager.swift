import UIKit
import CoreLocation
import UserNotifications
import SwiftDate
import RxSwift
import RxSwiftExt
import RxCoreLocation

extension Notification.Name {
  static let locationUpdated = Notification.Name("locationUpdated")
  static let locationAuthorizationUpdated = Notification.Name("locationAuthorizationUpdated")
}

extension CLAuthorizationStatus: CustomStringConvertible, CustomDebugStringConvertible {
  public var description: String {
    switch self {
    case .notDetermined: return "not-determined"
    case .restricted: return "restricted"
    case .denied: return "denied"
    case .authorizedAlways: return "authorized-always"
    case .authorizedWhenInUse: return "authorized-when-in-use"
    @unknown default: fatalError()
    }
  }
  public var debugDescription: String {
    return description
  }
}

@objc protocol LocationManagerAuthorizationDelegate: class {
  func authorized(_ locationManager: LocationManager, status: CLAuthorizationStatus)
  func notAuthorized(_ locationManager: LocationManager, status: CLAuthorizationStatus)
}

class LocationManager: NSObject, CLLocationManagerDelegate {

  static let shared = LocationManager()

  let env: Env
  var authorizationStatus: CLAuthorizationStatus = .notDetermined {
    didSet {
      NotificationCenter.default.post(name: .locationAuthorizationUpdated, object: nil)
    }
  }

  let defaultCoordinate =
    CLLocationCoordinate2D(
      latitude: 39.9526,
      longitude: -75.1652)

  weak var authorizationDelegate: LocationManagerAuthorizationDelegate?
  var locationManager:CLLocationManager

  func startMonitoringSignificantLocationChanges() {
    print("locationManager startMonitoringSignificantLocationChanges")
    locationManager.startMonitoringSignificantLocationChanges()
  }

  func startUpdatingLocation() {
    print("locationManager startUpdatingLocation")
    locationManager.startUpdatingLocation()
  }

  override init() {
    env = Env()
    locationManager = CLLocationManager()
    locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
    locationManager.pausesLocationUpdatesAutomatically = false
    locationManager.allowsBackgroundLocationUpdates = true
    super.init()
    locationManager.delegate = self
  }

  func authorized() -> Bool {
    if self.authorizationStatus == .authorizedWhenInUse {
      return true
    }
    if self.authorizationStatus == .authorizedAlways {
      return true
    }
    return false
  }

  func enableBasicLocationServices() {
    print("locationManager enableBasicLocationServices")
    let status = CLLocationManager.authorizationStatus()
    authorizationStatusUpdated(status: status)
  }

  func authorizationStatusUpdated(status: CLAuthorizationStatus) {
    print("locationManager authorizationStatusUpdated: \(status.rawValue)")
    self.authorizationStatus = status

    switch status {
    case .notDetermined:
      // Request when-in-use authorization initially
      locationManager.requestAlwaysAuthorization()
    case .restricted, .denied:
      guard let authDelegate = authorizationDelegate else {
        print("ERROR: MIA: LocationManaager.authorizationDelegate")
        return }
      authDelegate.notAuthorized(self, status: status)
    case .authorizedWhenInUse, .authorizedAlways:
      self.startMonitoringSignificantLocationChanges()
      guard let authDelegate = authorizationDelegate else {
        print("ERROR: MIA: LocationManaager.authorizationDelegate")
        return }
      authDelegate.authorized(self, status: status)
    @unknown default: fatalError()
    }
  }

  func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
    print("locationManager didChangeAuthorization: \(status)")
    if status != .notDetermined {
      authorizationStatusUpdated(status: status)
    }
  }

  public var latestLocation: CLLocation? {
    didSet {
      if let location = latestLocation {
        NotificationCenter.default.post(name: .locationUpdated, object: location)
      }
    }
  }
  public var latestCoordinate: CLLocationCoordinate2D? {
    return self.latestLocation?.coordinate
  }
  static var latestCoordinate: CLLocationCoordinate2D? {
    return self.shared.latestCoordinate
  }

  func locationManager(_ manager: CLLocationManager,
                       didUpdateLocations locations: [CLLocation]) {
    print("locationManager:didUpdateLocations \(locations)")
    guard let location = locations.last else {
      print("ERROR: MIA: locations.last")
      return
    }
    let region =
      Region(calendar: Calendars.gregorian,
             zone: Zones.autoUpdating, // default is GMT: https://git.io/fpAIZ
        locale: Locale.autoupdatingCurrent)
    let now = Date().in(region: region)
    let timestamp = location.timestamp.in(region: region)
    guard timestamp.isInside(date: now, granularity: .minute) else {
      print("\t skip stale location")
      return
    }

    self.latestLocation = location
    self.logLocationChange(location)
  }

  // analyze location in hours beginning: 8am, 4pm and midnight
  func logLocationChange(_ newLocation: CLLocation) {
    print("logLocationChange newLocation: \(newLocation)")
    guard let analytics = self.analytics else { return }
    let region =
      Region(calendar: Calendars.gregorian,
             zone: Zones.autoUpdating, // default is GMT: https://git.io/fpAIZ
             locale: Locale.autoupdatingCurrent)
    let now = Date().in(region: region)
    let timestamp = newLocation.timestamp.in(region: region)
    guard timestamp.isInside(date: now, granularity: .minute) else {
      print("\t skip stale location")
      return
    }
    let windowHourStarts = env.isPreProduction ? Array(0..<23) : [0, 8, 16]
    let windowHours = windowHourStarts.map { now.dateBySet(hour: $0, min: 0, secs: 0)! }
    let isInWindow: Bool = windowHours.contains { beginsAt -> Bool in
      let endsAt = 1.hours.from(beginsAt)!.in(region: region)
      return now.isInRange(date: beginsAt, and: endsAt)
    }
    guard isInWindow else {
      print("location changed outside window")
      return
    }
    analytics.log(.backgroundTrackingforLocation(newLocation.coordinate))
  }

  func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
    print("locationManager failed for region with identifier: \(region!.identifier) ")
    print(error)
  }

  func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    print("locationManager failed with the following error: \(error)")
  }

  enum RegionEvent {
    case enter(CLCircularRegion)
    case exit(CLCircularRegion)
  }
  var didReceiveRegion$: Observable<RegionEvent> {
    return
      locationManager.rx.didReceiveRegion
        .observeOn(Scheduler.background)
        .filterMap({ (manager: CLLocationManager, region: CLRegion, state: CLRegionEventState) -> FilterMap<RegionEvent> in
          guard let region = region as? CLCircularRegion else { return .ignore }
          switch state {
          case .enter: return .map(.enter(region))
          case .exit: return .map(.exit(region))
          case .monitoring: return .ignore
          }
        })
        .share()
  }

  var regionEntry$: Observable<CLCircularRegion> {
    return
      didReceiveRegion$
        .filterMap({ regionEvent -> FilterMap<CLCircularRegion> in
          guard case let .enter(region) = regionEvent else { return .ignore }
          return .map(region) })
        .share()
  }

  var regionExit$: Observable<CLCircularRegion> {
    return
      self.didReceiveRegion$
        .filterMap({ regionEvent -> FilterMap<CLCircularRegion> in
          guard case let .exit(region) = regionEvent else { return .ignore }
          return .map(region) })
        .share()
  }

  var location$: Observable<CLLocation> {
    return self.locationManager.rx.location.unwrap().share()
  }

  func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
    print("locationManager:didEnterRegion \(region)")
    self.analytics!.log(.regionEntered(source: "LocationManager"))
    // NOTE: see Notification.observeLocationManager()
  }

  var analytics: AnalyticsManager?
  var cache: Cache?
  static func sharedWith(
    analytics: AnalyticsManager,
    cache: Cache
    ) -> LocationManager {
    let manager = LocationManager.shared
    manager.analytics = analytics
    manager.cache = cache
    manager.observeBookmarks(from: cache)
    return manager
  }

  private func observeBookmarks(from cache: Cache) -> Void {
    cache.observePlaces$(.bookmarked)
      .subscribe(onNext: { [weak self] objects in
        self?.resetRegionMonitoring(places: objects)
      })
      .disposed(by: rx.disposeBag)
  }

  func simulate(enteredRegion region: CLRegion) {
    self.locationManager(self.locationManager, didEnterRegion: region)
  }

  func resetRegionMonitoring(places: [Place]) {
    let manager = locationManager
    manager.monitoredRegions.forEach { manager.stopMonitoring(for: $0) }
    places.forEach { manager.startMonitoring(for: $0.region) }
  }

}
