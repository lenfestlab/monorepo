import CoreLocation
import ObjectMapper
import ObjectMapperAdditions
import ObjectMapperAdditionsRealm
import RealmSwift

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
  @objc dynamic var categoryNames: String?
  @objc dynamic var websiteURLString: String?
  @objc dynamic var reservationsURLString: String?
  @objc dynamic var location: Location?
  var triggerRadiusOpt = RealmOptional<Double>()
  var distanceOpt = RealmOptional<Double>()
  var visitRadiusOpt = RealmOptional<Double>()
  var categories = List<Category>()
  var nabes = List<Neighborhood>()
  @objc dynamic var post: PostObject?

  let bookmarks = LinkingObjects(fromType: Bookmark.self, property: "place")

  func mapping(map: Map) {
    identifier <-
      (map["identifier"], StringTransform())
    name <-
      (map["name"], StringTransform())
    categoryNames <-
      (map["category_names"], StringTransform())
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
    triggerRadiusOpt <-
      (map["trigger_radius"], RealmOptionalTransform())
    visitRadiusOpt <-
      (map["visit_radius"], RealmOptionalTransform())
    distanceOpt <-
      (map["distance"], RealmOptionalTransform())
    categories <-
      (map["categories"], ListTransform<Category>())
    nabes <-
      (map["nabes"], ListTransform<Neighborhood>())
    post <-
      map["post"]
  }

  var triggerRadius: Double? {
    return triggerRadiusOpt.value
  }
  var distance: Double? {
    return distanceOpt.value
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

}
