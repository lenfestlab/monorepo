import UIKit
import Gloss
import CoreLocation
import UserDefaultsStore

struct Location: JSONDecodable, Codable {
  let latitude: CLLocationDegrees?
  let longitude: CLLocationDegrees?
  
  init?(json: JSON) {
    self.latitude = "lat" <~~ json
    self.longitude = "lng" <~~ json
  }
}

struct Place: JSONDecodable, Codable, Identifiable {
  
  static let idKey = \Place.identifier

  var identifier: String
  let title: String?
  let blurb: String?
  let link: URL?
  let images: [URL]?
  let location: Location?
  
  init?(json: JSON) {
//    self.identifier = ("identifier" <~~ json)!
    self.identifier = ("title" <~~ json)!
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
