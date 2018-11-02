import UIKit
import CoreLocation
import UserNotifications

protocol LocationManagerDelegate: class {
  func locationUpdated(_ locationManager: LocationManager, coordinate: CLLocationCoordinate2D)
  func regionEngtered(_ locationManager: LocationManager, region: CLCircularRegion)
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
    locationManager.startMonitoringSignificantLocationChanges()
  }

  func startUpdatingLocation() {
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
    let status = CLLocationManager.authorizationStatus()
    authorizationStatusUpdated(status: status)
  }

  func authorizationStatusUpdated(status: CLAuthorizationStatus) {
    switch status {
    case .notDetermined:
      // Request when-in-use authorization initially
      locationManager.requestAlwaysAuthorization()
      break

    case .restricted, .denied:
      authorized = false
      authorizationDelegate?.notAuthorized(self, status: status)
      break

    case .authorizedWhenInUse, .authorizedAlways:
      authorized = true
      authorizationDelegate?.authorized(self, status: status)
      break
    }
  }

  func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
    if status != .notDetermined {
      authorizationStatusUpdated(status: status)
    }
  }

  func locationManager(_ manager: CLLocationManager,
                       didUpdateLocations locations: [CLLocation]) {
    let latestLocation: CLLocation = locations[locations.count - 1]
    let latitude = String(latestLocation.coordinate.latitude)
    let longitude = String(latestLocation.coordinate.longitude)
    print("\(latitude) \(longitude)")

    self.delegate?.locationUpdated(self, coordinate: latestLocation.coordinate)
  }

  func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
    print("Monitoring failed for region with identifier: \(region!.identifier)")
    print(error)
  }

  func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    print("Location Manager failed with the following error: \(error)")
  }

  func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
    if region is CLCircularRegion {
      self.delegate?.regionEngtered(self, region: region as! CLCircularRegion)

      let env = Env()
      if env.isPreProduction && MotionManager.shared.shouldSkipNotifications {
        print("skip due to motion state")
        return
      }

      let identifier = region.identifier
      var identifiers = NotificationManager.shared.identifiers
      let sendAgainAt = identifiers[identifier]
      let now = Date(timeIntervalSinceNow: 0)
      if sendAgainAt != nil && sendAgainAt?.compare(now) == ComparisonResult.orderedDescending  {
        print(identifiers)
      } else if let place = PlaceManager.shared.placeForIdentifier(identifier) {
          identifiers[identifier] = Date(timeIntervalSinceNow: 60 * 60 * 24 * 10000)
          NotificationManager.shared.saveIdentifiers(identifiers)

          PlaceManager.contentForPlace(place: place) { (content) in
            let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
            let center = UNUserNotificationCenter.current()
            center.add(request)
        }
      }

    }
  }

}
