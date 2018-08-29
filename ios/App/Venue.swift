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
    self.link = "link" <~~ json
    self.images = "images" <~~ json
    self.location = "location" <~~ json
  }
}


