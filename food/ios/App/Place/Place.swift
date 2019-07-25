import CoreLocation
import ObjectMapper
import ObjectMapperAdditions
import ObjectMapperAdditionsRealm
import RealmSwift
import DifferenceKit
import PhoneNumberKit

// A PhoneNumberKit instance is relatively expensive to allocate...
let phoneNumberKit = PhoneNumberKit()

extension Place: Differentiable {}

class Place: RealmSwift.Object, Mappable {
  required convenience init?(map: Map) {
    self.init()
  }

  override static func primaryKey() -> String? {
    return "identifier"
  }

  override static func ignoredProperties() -> [String] {
    return ["phoneURL"]
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
  var distanceOpt = RealmOptional<Double>()

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
    // NOTE: prefer local distance calculations
    distanceOpt <- (map["distance"], RealmOptionalTransform())
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

  enum MapsService { case google, apple }
  func mapsURL(_ service: MapsService) -> URL? {
    guard
      let name = name,
      let address = address,
      let q = "\(name) \(address)".addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
      else { print("MIA: name or addres"); return nil }
    switch service {
    case .google: // http://bit.ly/2EIa6Ri
      return URL(string: "https://maps.google.com/?q=\(q)")
    case .apple: // https://apple.co/2EKhImo
      return URL(string: "https://maps.apple.com/?q=\(q)")
    }
  }

  var hasMapsURL: Bool {
    if let _ = self.mapsURL(.apple) {
      return true
    } else {
      return false
    }
  }

  lazy var phoneURL: URL? = { () -> URL? in
    guard let rawNumber = self.phone
      else { print("MIA: phone"); return nil }
    guard let parsedNumber = try? phoneNumberKit.parse(rawNumber)
      else { print("MIA: parsedNumber"); return nil }
    let formattedNumber = phoneNumberKit.format(parsedNumber, toType: .e164)
    guard let telURL = URL(string: "tel://\(formattedNumber)")
      else { print("MIA: telURL"); return nil }
    return telURL
  }()

  var websiteURL: URL? {
    guard
      let websiteURLString = websiteURLString,
      websiteURLString.hasPrefix("http") // prevent crashing on incomplete URLs
      else { return nil }
    return URL(string: websiteURLString)
  }

  var reservationsURL: URL? {
    guard let reservationsURLString = reservationsURLString else { return nil }
    return URL(string: reservationsURLString)
  }

  var postURL: URL? {
    return post?.url
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

  var coordinate: CLLocationCoordinate2D {
    return CLLocationCoordinate2D(latitude: (self.location?.latitude)!, longitude: (self.location?.longitude)!)
  }

  static let defaultRadius: Double = 50

  var region: CLCircularRegion {
    let center = coordinate
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

  var nativeLocation: CLLocation? {
    return location?.nativeLocation
  }

  func distanceFrom(_ other: Place) -> Double? {
    guard
      let location = self.nativeLocation,
      let otherLocation = other.nativeLocation
      else { return nil }
    return location.distance(from: otherLocation)
  }
  func distanceFrom(_ otherLocation: CLLocation) -> Double? {
    guard let location = self.nativeLocation else { return nil }
    return location.distance(from: otherLocation)
  }

  override var description: String {
    guard let name = self.name else { return "???" }
    var desc = name
    if let distance = self.distance {
      desc.append(" [\(distance)]")
    }
    return desc
  }
  override var debugDescription: String {
    return description
  }

  var cuisines: [Category] {
    return categories.filter({ $0.isCuisine })
  }
  var guides: [Category] {
    return categories.filter({ !$0.isCuisine })
  }

}
