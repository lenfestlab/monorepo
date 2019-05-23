import CoreLocation
import ObjectMapper
import ObjectMapperAdditions
import ObjectMapperAdditionsRealm
import RealmSwift
import DifferenceKit

extension Place: Differentiable {}

class Place: RealmSwift.Object, Mappable {
  required convenience init?(map: Map) {
    self.init()
  }

  override static func primaryKey() -> String? {
    return "identifier"
  }

  @objc dynamic var identifier = ""
  @objc dynamic var name: String?
  @objc dynamic var phone: String?
  @objc dynamic var address: String?
  @objc dynamic var websiteURLString: String?
  @objc dynamic var reservationsURLString: String?
  @objc dynamic var location: Location?
  var triggerRadiusOpt = RealmOptional<Double>()
  var visitRadiusOpt = RealmOptional<Double>()
  var categories = List<Category>()
  var nabes = List<Neighborhood>()
  @objc dynamic var post: Post?
  // distance from current location
  var distanceOpt = RealmOptional<Double>()
  // distance from Philly central, for sorting Guides centered there by default
  @objc dynamic var distanceDefault: Double = Double.infinity

  let bookmarks = LinkingObjects(fromType: Bookmark.self, property: "place")

  func mapping(map: Map) {
    identifier <-
      (map["identifier"], StringTransform())
    name <-
      (map["name"], StringTransform())
    phone <-
      (map["phone"], StringTransform())
    address <-
      (map["address"], StringTransform())
    location <-
      map["location"]
    websiteURLString <-
      (map["website"], StringTransform())
    reservationsURLString <-
      (map["reservations_url"], StringTransform())
    distanceOpt <-
      (map["distance"], RealmOptionalTransform())
    triggerRadiusOpt <-
      (map["trigger_radius"], RealmOptionalTransform())
    visitRadiusOpt <-
      (map["visit_radius"], RealmOptionalTransform())
    categories <-
      (map["categories"], ListTransform<Category>())
    nabes <-
      (map["nabes"], ListTransform<Neighborhood>())
    post <-
      map["post"]
  }

  var distance: Double? {
    set {
      distanceOpt.value = newValue
    }
    get {
      return distanceOpt.value
    }
  }

  var triggerRadius: Double? {
    return triggerRadiusOpt.value
  }

  var visitRadius: Double? {
    return visitRadiusOpt.value
  }

  var website: URL? {
    guard let websiteURLString = websiteURLString else { return nil }
    return URL(string: websiteURLString)
  }

  var reservationsURL: URL? {
    guard let reservationsURLString = reservationsURLString else { return nil }
    return URL(string: reservationsURLString)
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

  func distance(from other: Place) -> Double? {
    guard
      let location = self.location?.nativeLocation,
      let otherLocation = other.location?.nativeLocation
      else { return nil }
    return location.distance(from: otherLocation)
  }
  func distance(from otherLocation: CLLocation) -> Double? {
    guard let location = self.location?.nativeLocation else { return nil }
    return location.distance(from: otherLocation)
  }

  override var description: String {
    guard let name = self.name else { return "???" }
    return name
  }
  override var debugDescription: String {
    return description
  }

}
