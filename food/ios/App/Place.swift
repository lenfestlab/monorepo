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
  let blurb: String?
  let imageURL: URL?
  let price: Array<Int>?
  let rating: Int?

  init?(json: JSON) {
    self.identifier = ("identifier" <~~ json)!
    self.blurb = "blurb" <~~ json
    self.imageURL = "image_url" <~~ json
    self.price = "price" <~~ json
    self.rating = "rating" <~~ json
  }

  // TODO: refactor to drop or replace
  var title: String? {
    var res = ""
    if let bells = self.rating {
      res.append("Bells: \(bells) \t")
    }
    if let price = self.price {
      res.append("price: \(price)")
    }
    return res
  }
  var link: URL! { return URL(string: "https://google.com") }
  var linkShort: URL! { return URL(string: "https://google.com") }
  var publicationName: String? { return "" }
  var publicationTwitter: String? { return "" }
}

struct Place: JSONDecodable, Codable, Identifiable {
  
  static let idKey = \Place.identifier

  var identifier: String
  let location: Location?
  let post: Post
  let radius: Double?

  init?(json: JSON) {
    self.identifier = ("identifier" <~~ json)!
    self.location = "location" <~~ json
    self.post = ("post" <~~ json)!
    self.radius = "radius" <~~ json
  }

  var title: String? {
    return post.title
  }

  var blurb: String? {
    return post.blurb
  }

  var imageURL: URL? {
    return post.imageURL
  }

  func coordinate() -> CLLocationCoordinate2D {
    return CLLocationCoordinate2D(latitude: (self.location?.latitude)!, longitude: (self.location?.longitude)!)
  }

}