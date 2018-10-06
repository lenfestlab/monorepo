import UIKit
import CoreLocation
import UserNotifications

protocol LocationManagerDelegate: class {
  func authorized(_ locationManager: LocationManager)
  func notAuthorized(_ locationManager: LocationManager)
  func locationUpdated(_ locationManager: LocationManager, coordinate: CLLocationCoordinate2D)
}

class LocationManager: NSObject, CLLocationManagerDelegate {

  static let shared = LocationManager()

  weak var delegate: LocationManagerDelegate?
  var locationManager:CLLocationManager?
  var authorized = false

  func startMonitoringSignificantLocationChanges() {
    locationManager?.startMonitoringSignificantLocationChanges()
  }

  func startUpdatingLocation() {
    locationManager?.startUpdatingLocation()
  }

  override init() {
    super.init()
    locationManager = CLLocationManager()
    locationManager?.desiredAccuracy = kCLLocationAccuracyThreeKilometers
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
    
    self.delegate?.locationUpdated(self, coordinate: latestLocation.coordinate)
  }

  func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
    print("Monitoring failed for region with identifier: \(region!.identifier)")
  }
  
  func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    print("Location Manager failed with the following error: \(error)")
  }

  func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
    if region is CLCircularRegion {
      
      let identifier = region.identifier
      
      var identifiers = UserDefaults.standard.array(forKey: "recieved-notification-identifiers") as? [String]
      if identifiers == nil {
        identifiers = []
      }

      if identifiers!.contains(identifier)  {
        print(identifiers!)
      } else {
        identifiers?.append(identifier)
        UserDefaults.standard.set(identifiers, forKey: "recieved-notification-identifiers")
        
        let venue = VenueManager.shared.venueForIdentifier(identifier: identifier)
        if venue != nil {
          VenueManager.contentForVenue(venue: venue!) { (content) in
            let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
            let center = UNUserNotificationCenter.current()            
            center.add(request)
          }
        }
      }
      
    }
  }
  
}
