import UIKit
import CoreLocation
import UserNotifications
import SwiftDate

extension CLAuthorizationStatus: CustomStringConvertible, CustomDebugStringConvertible {
  public var description: String {
    switch self {
    case .notDetermined: return "not-determined"
    case .restricted: return "restricted"
    case .denied: return "denied"
    case .authorizedAlways: return "authorized-always"
    case .authorizedWhenInUse: return "authorized-when-in-use"
    }
  }
  public var debugDescription: String {
    return description
  }
}

@objc protocol LocationManagerAuthorizationDelegate: class {
  @objc optional func locationUpdated(_ locationManager: LocationManager, location: CLLocation)
  func authorized(_ locationManager: LocationManager, status: CLAuthorizationStatus)
  func notAuthorized(_ locationManager: LocationManager, status: CLAuthorizationStatus)
}

class LocationManager: NSObject, CLLocationManagerDelegate {

  static let shared = LocationManager()

  let dataStore = PlaceDataStore()
  let env: Env


  weak var authorizationDelegate: LocationManagerAuthorizationDelegate?
  var locationManager:CLLocationManager
  var authorized = false

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

  func enableBasicLocationServices() {
    print("locationManager enableBasicLocationServices")
    let status = CLLocationManager.authorizationStatus()
    authorizationStatusUpdated(status: status)
  }

  func authorizationStatusUpdated(status: CLAuthorizationStatus) {
    print("locationManager authorizationStatusUpdated: \(status.rawValue)")
    switch status {
    case .notDetermined:
      // Request when-in-use authorization initially
      locationManager.requestAlwaysAuthorization()
    case .restricted, .denied:
      authorized = false
      guard let authDelegate = authorizationDelegate else {
        print("ERROR: MIA: LocationManaager.authorizationDelegate")
        return }
      authDelegate.notAuthorized(self, status: status)
    case .authorizedWhenInUse, .authorizedAlways:
      authorized = true
      self.startMonitoringSignificantLocationChanges()
      guard let authDelegate = authorizationDelegate else {
        print("ERROR: MIA: LocationManaager.authorizationDelegate")
        return }
      authDelegate.authorized(self, status: status)
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
        authorizationDelegate?.locationUpdated?(self, location: location)
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
    let coordinate = location.coordinate
    self.fetchData(coordinate: coordinate)
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
    analytics.log(.locationChanged(newLocation.coordinate))
  }

  func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
    print("locationManager failed for region with identifier: \(region!.identifier) ")
    print(error)
  }

  func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    print("locationManager failed with the following error: \(error)")
  }

  func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
    print("locationManager:didEnterRegion \(region)")
    self.analytics!.log(.regionEntered(source: "LocationManager"))

    guard let region = region as? CLCircularRegion else {
      print("\n ERROR: MIA: region")
      return
    }

    let identifier = region.identifier
    var identifiers = NotificationManager.shared.identifiers

    if let sendAgainAt = identifiers[identifier], sendAgainAt.isInFuture {
      print("NOTE: notification scheduled in the future, skip")
      return
    }

    guard let place = PlaceManager.shared.placeForIdentifier(identifier) else {
      print("ERROR: MIA: place \(identifier)")
      return
    }

    if MotionManager.shared.skipNotifications {
      self.analytics!.log(.notificationSkipped(region.center))
      print("\n WARN: MotionManager.shared.skipNotifications is true")
      return
    }

    print("\t place \(place)")
    identifiers[identifier] = Date(timeIntervalSinceNow: 60 * 60 * 24 * 10000)
    NotificationManager.shared.saveIdentifiers(identifiers)
    sendNotificationForPlace(place)
  }

  func sendNotificationForPlace(_ place: Place) {
    PlaceManager.contentForPlace(place: place) { (content) in
      if let content = content {
        self.analytics!.log(.notificationShown(post: place.post, currentLocation: place.coordinate()))
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
        let center = UNUserNotificationCenter.current()
        center.add(request, withCompletionHandler: { (error) in
          if let error = error {
            print("\n\t ERROR: \(error)")
          } else {
            print("\n\t request fulfilled \(request)")
          }
        })
      }
    }
  }

  var analytics: AnalyticsManager?
  static func sharedWith(analytics: AnalyticsManager) -> LocationManager {
    let manager = LocationManager.shared
    manager.analytics = analytics
    return manager
  }


  func simulate(enteredRegion region: CLRegion) {
    self.locationManager(self.locationManager, didEnterRegion: region)
  }

  func fetchData(coordinate: CLLocationCoordinate2D, trackResults: Bool = true) {
    dataStore.retrievePlaces(coordinate: coordinate, limit: 10) { [unowned self] (success, data, count) in
      if self.authorized && trackResults {
        PlaceManager.shared.trackPlaces(places: data)
      }
    }
  }

}
