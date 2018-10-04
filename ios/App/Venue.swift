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
  
  func toJSON() -> JSON? {
    return jsonify([
      "lat" ~~> self.latitude,
      "lng" ~~> self.longitude,
      ])
  }

}

struct Venue: JSONDecodable {
  let title: String?
  let blurb: String?
  let link: URL?
  let images: [URL]?
  var image: URL?
  let location: Location?
  
  init?(json: JSON) {
    self.images = "image_urls" <~~ json
    self.image = "image" <~~ json
    if self.image == nil {
      self.image = self.images?[0]
    }
    self.title = "title" <~~ json
    self.blurb = "blurb" <~~ json
    self.link = "url" <~~ json
    self.location = "location" <~~ json
  }

  func coordinate() -> CLLocationCoordinate2D {
    return CLLocationCoordinate2D(latitude: (self.location?.latitude)!, longitude: (self.location?.longitude)!)
  }
  
  func toJSON() -> JSON? {
    return jsonify([
      "title" ~~> self.title,
      "blurb" ~~> self.blurb,
      "url" ~~> self.link?.absoluteString,
      "image" ~~> self.image,
      "location" ~~> self.location?.toJSON(),
      ])
  }

}


