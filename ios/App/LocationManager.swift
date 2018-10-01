import UIKit
import CoreLocation

protocol LocationManagerDelegate: class {
  func authorized(_ locationManager: LocationManager)
  func notAuthorized(_ locationManager: LocationManager)
}

class LocationManager: NSObject, CLLocationManagerDelegate {

  static let shared = LocationManager()

  weak var delegate: LocationManagerDelegate?
  var locationManager:CLLocationManager?
  var authorized = false

  func startUpdatingLocation() {
    locationManager?.startUpdatingLocation()
  }

  override init() {
    super.init()
    locationManager = CLLocationManager()
    locationManager?.desiredAccuracy = kCLLocationAccuracyHundredMeters // less batery ussage
    locationManager?.pausesLocationUpdatesAutomatically = false
    locationManager?.allowsBackgroundLocationUpdates = true
    locationManager?.delegate = self
  }
  
  func enableBasicLocationServices() {
    let status = CLLocationManager.authorizationStatus()
    authorizationStatusUpdated(status: status)
  }
  
  func authorizationStatusUpdated(status: CLAuthorizationStatus) {
    switch status {
    case .notDetermined:
      // Request when-in-use authorization initially
      locationManager?.requestAlwaysAuthorization()
      break
      
    case .restricted, .denied:
      authorized = false
      delegate?.notAuthorized(self)
      break
      
    case .authorizedWhenInUse, .authorizedAlways:
      authorized = true
      delegate?.authorized(self)
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
  }

}
