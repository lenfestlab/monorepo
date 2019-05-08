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

  var nativeLocation: CLLocation {
    return CLLocation(
      latitude: self.latitude,
      longitude: self.longitude)
  }

}

struct Post: JSONDecodable, Codable, Identifiable {
  
  static let idKey = \Post.identifier

  var identifier: String
  var url: URL?
  let title: String?
  let blurb: String?
  let imageURL: URL?
  let prices: Array<Int>?
  let rating: Int?
  var link: URL?
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
    self.url = "url" <~~ json
    self.blurb = "blurb" <~~ json
    self.title = "title" <~~ json
    self.imageURL = "image_url" <~~ json
    self.link = "url" <~~ json
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
  let triggerRadius: Double?
  let distance: Double?
  let nabes: [Neighborhood]?
  let categories: [Category]?
  let visitRadius: Double?
  var reservationsURL: URL?

  init?(json: JSON) {
    self.identifier = ("identifier" <~~ json)!
    self.phone = "phone" <~~ json
    self.address = "address" <~~ json
    self.location = "location" <~~ json
    self.post = "post" <~~ json
    self.triggerRadius = "trigger_radius" <~~ json
    self.distance = "distance" <~~ json
    self.name = "name" <~~ json
    self.nabes = "nabes" <~~ json
    self.categories = "categories" <~~ json
    self.website = "website" <~~ json
    self.visitRadius = "visit_radius" <~~ json
    self.reservationsURL = "reservations_url" <~~ json
  }

  var visitRadiusMax: Double {
    return visitRadius ?? Place.defaultRadius
  }

  var title: String? {
    guard
      let name = name,
      let post = post,
      let author = post.author
      else { return nil }
    return "\(name) reviewed by \(author.name)"
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

  static let defaultRadius: Double = 100

  var region: CLCircularRegion {
    let center = coordinate()
    let radius = self.triggerRadius ?? Place.defaultRadius
    let region =
      CLCircularRegion(
        center: center,
        radius: radius,
        identifier: identifier)
    region.notifyOnEntry = true
    region.notifyOnExit = true
    return region
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
