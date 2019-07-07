import Foundation
import CoreLocation

extension CLLocationCoordinate2D {
  func distance(from other: CLLocationCoordinate2D) -> CLLocationDistance {
    let this = CLLocation(latitude: self.latitude, longitude: self.longitude)
    let that = CLLocation(latitude: other.latitude, longitude: other.longitude)
    return this.distance(from: that)
  }
}
