import UIKit
import Gloss
import CoreLocation

struct Location: JSONDecodable {
  let latitude: CLLocationDegrees?
  let longitude: CLLocationDegrees?
  
  init?(json: JSON) {
    self.latitude = "lat" <~~ json
    self.longitude = "lng" <~~ json
  }
}

struct Venue: JSONDecodable {
  let title: String?
  let blurb: String?
  let link: URL?
  let images: [URL]?
  let location: Location?
  
  init?(json: JSON) {
    self.title = "title" <~~ json
    self.blurb = "blurb" <~~ json
    self.link = "url" <~~ json
    self.images = "image_urls" <~~ json
    self.location = "location" <~~ json
  }

  func coordinate() -> CLLocationCoordinate2D {
    return CLLocationCoordinate2D(latitude: (self.location?.latitude)!, longitude: (self.location?.longitude)!)
  }
}


