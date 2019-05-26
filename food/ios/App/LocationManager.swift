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

  var authorizationStatus: CLAuthorizationStatus = .notDetermined {
    didSet {
      NotificationCenter.default.post(name: .locationAuthorizationUpdated, object: nil)
    }
  }

  let defaultCoordinate =
    CLLocationCoordinate2D(
      latitude: 39.9526,
      longitude: -75.1652)

  lazy var defaultLocation = {() -> CLLocation in
    return
      CLLocation(
        latitude: defaultCoordinate.latitude,
        longitude:defaultCoordinate.longitude)
  }()

  weak var authorizationDelegate: LocationManagerAuthorizationDelegate?
  var locationManager:CLLocationManager

  func startMonitoringSignificantLocationChanges() {
    locationManager.startMonitoringSignificantLocationChanges()
  }

  func startUpdatingLocation() {
    locationManager.startUpdatingLocation()
  }

  let env: Env
  let analytics: AnalyticsManager?
  init(env: Env, analytics: AnalyticsManager) {
    self.env = env
    self.analytics = analytics
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
    let status = CLLocationManager.authorizationStatus()
    authorizationStatusUpdated(status: status)
  }

  func authorizationStatusUpdated(status: CLAuthorizationStatus) {
    self.authorizationStatus = status

    switch status {
    case .notDetermined:
      // Request when-in-use authorization initially
      locationManager.requestAlwaysAuthorization()
    case .restricted, .denied:
      guard let authDelegate = authorizationDelegate else { return }
      authDelegate.notAuthorized(self, status: status)
    case .authorizedWhenInUse, .authorizedAlways:
      self.startMonitoringSignificantLocationChanges()
      guard let authDelegate = authorizationDelegate else { return }
      authDelegate.authorized(self, status: status)
    @unknown default: fatalError()
    }
  }

  func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
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
    return latestLocation?.coordinate
  }

  func locationManager(_ manager: CLLocationManager,
                       didUpdateLocations locations: [CLLocation]) {
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
    guard timestamp.isInside(date: now, granularity: .minute) else { return }
    self.latestLocation = location
    self.logLocationChange(location)
  }

  // analyze location in hours beginning: 8am, 4pm and midnight
  func logLocationChange(_ newLocation: CLLocation) {
    guard let analytics = self.analytics else { return }
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
    return self.locationManager.rx.location
      .unwrap()
      .distinctUntilChanged()
      .share()
  }

  func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
    self.analytics!.log(.regionEntered(source: "LocationManager"))
    // NOTE: see Notification.observeLocationManager()
  }

  func simulate(enteredRegion region: CLRegion) {
    self.locationManager(self.locationManager, didEnterRegion: region)
  }

  func resetRegionMonitoring(latestRegions regions: [CLCircularRegion]) {
    let manager = locationManager
    manager.monitoredRegions.forEach { manager.stopMonitoring(for: $0) }
    regions.forEach { manager.startMonitoring(for: $0) }
  }

}
