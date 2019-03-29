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
  let imageURL: URL?
  let prices: Array<Int>?
  let rating: Int?
  var link: URL? = URL(string: "http://media.philly.com/storage/special_projects/best-restaurants-philadelphia-philly-2018.html")
  var linkShort: URL?
  var placeSummary: String?
  var menu: String?
  var notes: String?
  var drinks: String?
  var remainder: String?
  var author: Author?
  var images: [Img]?

  init?(json: JSON) {
    self.identifier = ("identifier" <~~ json)!
    self.blurb = "blurb" <~~ json
    self.title = "title" <~~ json
    self.imageURL = "image_url" <~~ json
    self.prices = "prices" <~~ json
    self.rating = "rating" <~~ json
    self.placeSummary = "details.place_summary" <~~ json
    self.menu = "details.menu" <~~ json
    self.notes = "details.notes" <~~ json
    self.drinks = "details.drinks" <~~ json
    self.remainder = "details.remainder" <~~ json
    self.author = "author" <~~ json
    self.images = "images" <~~ json
  }

  var publicationName: String? { return "" }
  var publicationTwitter: String? { return "" }

}


struct Place: JSONDecodable, Codable, Identifiable {

  static let key = "saved-place-identifiers"

  static let idKey = \Place.identifier

  var name: String?
  var phone: String?
  var identifier: String
  var address: String?
  let location: Location?
  let post: Post?
  let website: URL?
  let radius: Double?
  let distance: Double?
  let nabes: [Neighborhood]?
  let categories: [Category]?

  init?(json: JSON) {
    self.identifier = ("identifier" <~~ json)!
    self.phone = "phone" <~~ json
    self.address = "address" <~~ json
    self.location = "location" <~~ json
    self.post = "post" <~~ json
    self.radius = "radius" <~~ json
    self.distance = "distance" <~~ json
    self.name = "name" <~~ json
    self.nabes = "nabes" <~~ json
    self.categories = "categories" <~~ json
    self.website = "website" <~~ json
  }

  var title: String? {
    return post?.title
  }

  var blurb: String? {
    return post?.blurb
  }

  var imageURL: URL? {
    return post?.imageURL
  }

  func coordinate() -> CLLocationCoordinate2D {
    return CLLocationCoordinate2D(latitude: (self.location?.latitude)!, longitude: (self.location?.longitude)!)
  }

}


struct Img: JSONDecodable, Codable {

  var url: URL?
  var credit: String?
  var caption: String?

  init?(json: JSON) {
    self.url = "url" <~~ json
    self.credit = "credit" <~~ json
    self.caption = "caption" <~~ json
  }

}
