import UIKit
import CoreLocation
import UserNotifications

protocol LocationManagerDelegate: class {
  func locationUpdated(_ locationManager: LocationManager, coordinate: CLLocationCoordinate2D)
}

protocol LocationManagerAuthorizationDelegate: class {
  func authorized(_ locationManager: LocationManager, status: CLAuthorizationStatus)
  func notAuthorized(_ locationManager: LocationManager, status: CLAuthorizationStatus)
}

class LocationManager: NSObject, CLLocationManagerDelegate {

  static let shared = LocationManager()

  weak var delegate: LocationManagerDelegate?
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
      authorizationDelegate?.notAuthorized(self, status: status)
    case .authorizedWhenInUse, .authorizedAlways:
      authorized = true
      authorizationDelegate?.authorized(self, status: status)
      self.startMonitoringSignificantLocationChanges()
    }
  }

  func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
    if status != .notDetermined {
      authorizationStatusUpdated(status: status)
    }
  }

  func locationManager(_ manager: CLLocationManager,
                       didUpdateLocations locations: [CLLocation]) {
    print("locationManager:didUpdateLocations \(locations)")
    let latestLocation: CLLocation = locations[locations.count - 1]
    let latitude = String(latestLocation.coordinate.latitude)
    let longitude = String(latestLocation.coordinate.longitude)
    print("\t \(latitude) \(longitude)")

    self.delegate?.locationUpdated(self, coordinate: latestLocation.coordinate)
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

    if let region = region as? CLCircularRegion {

      if MotionManager.shared.skipNotifications {
        self.analytics!.log(.notificationSkipped(region.center))
        return
      }

      let identifier = region.identifier
      var identifiers = NotificationManager.shared.identifiers
      let sendAgainAt = identifiers[identifier]
      let now = Date()
      if sendAgainAt != nil && sendAgainAt?.compare(now) == ComparisonResult.orderedDescending  {
        print("\t sendAgainAt \(sendAgainAt!)")
      } else if let place = PlaceManager.shared.placeForIdentifier(identifier) {
        print("\t place \(place)")
        identifiers[identifier] = Date(timeIntervalSinceNow: 60 * 60 * 24 * 10000)
        NotificationManager.shared.saveIdentifiers(identifiers)

        PlaceManager.contentForPlace(place: place) { (content) in
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

}
