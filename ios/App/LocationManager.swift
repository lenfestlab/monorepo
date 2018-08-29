//
//  LocationManager.swift
//  App
//
//  Created by Ajay Chainani on 8/29/18.
//

import UIKit
import CoreLocation

protocol LocationManagerDelegate {
  func authorized(_ locationManager: LocationManager)
  func notAuthorized(_ locationManager: LocationManager)
}

class LocationManager: NSObject, CLLocationManagerDelegate {

  var delegate: LocationManagerDelegate?
  var locationManager:CLLocationManager?

  override init() {
    super.init()
    locationManager = CLLocationManager()
    locationManager?.desiredAccuracy = kCLLocationAccuracyHundredMeters // less batery ussage
    locationManager?.pausesLocationUpdatesAutomatically = false
    locationManager?.allowsBackgroundLocationUpdates = true
    locationManager?.delegate = self
  }
  
  func enableBasicLocationServices() {
    switch CLLocationManager.authorizationStatus() {
    case .notDetermined:
      // Request when-in-use authorization initially
      locationManager?.requestAlwaysAuthorization()
      break
      
    case .restricted, .denied:
      delegate?.notAuthorized(self)
      break
      
    case .authorizedWhenInUse, .authorizedAlways:
      delegate?.authorized(self)
      locationManager?.startUpdatingLocation()
      break
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
