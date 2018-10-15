import UIKit
import Gloss
import CoreLocation
import UserDefaultsStore

struct Location: JSONDecodable, Codable {
  let latitude: CLLocationDegrees
  let longitude: CLLocationDegrees
  
  init?(json: JSON) {
    self.latitude = ("lat" <~~ json)!
    self.longitude = ("lng" <~~ json)!
  }

}

struct Post: JSONDecodable, Codable, Identifiable {
  
  static let idKey = \Post.identifier
  
  var identifier: String
  let title: String?
  let blurb: String?
  let link: URL
  let imageURL: URL?
  
  init?(json: JSON) {
    self.identifier = ("identifier" <~~ json)!
    self.title = "title" <~~ json
    self.blurb = "blurb" <~~ json
    self.link = ("url" <~~ json)!
    self.imageURL = "image_url" <~~ json
  }
  
}

struct Place: JSONDecodable, Codable, Identifiable {
  
  static let idKey = \Place.identifier

  var identifier: String
  let title: String?
  let blurb: String?
  let imageURL: URL?
  let location: Location?
  let post: Post

  init?(json: JSON) {
    self.identifier = ("identifier" <~~ json)!
    self.title = "title" <~~ json
    self.blurb = "blurb" <~~ json
    self.imageURL = "image_url" <~~ json
    self.location = "location" <~~ json
    self.post = ("post" <~~ json)!
  }
  
  func coordinate() -> CLLocationCoordinate2D {
    return CLLocationCoordinate2D(latitude: (self.location?.latitude)!, longitude: (self.location?.longitude)!)
  }
}
