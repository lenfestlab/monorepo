import ObjectMapper
import ObjectMapperAdditions
import ObjectMapperAdditionsRealm
import RealmSwift
import DifferenceKit

extension Category: Differentiable {}

class Category: RealmSwift.Object, Mappable {

  required convenience init?(map: Map) {
    self.init()
  }

  override static func primaryKey() -> String? {
    return "identifier"
  }
  override static func indexedProperties() -> [String] {
    return ["isCuisine", "displayStarts", "displayEnds"]
  }

  @objc dynamic var identifier = ""
  @objc dynamic var name: String = ""
  @objc dynamic var desc: String?
  @objc dynamic var imageURLString: String?
  @objc dynamic var isCuisine: Bool = false
  @objc dynamic var displayStarts: Date?
  @objc dynamic var displayEnds: Date?
  var guideGroups = List<GuideGroup>()

  let places = LinkingObjects(fromType: Place.self, property: "categories")

  var nearestPlaces: [Place] {
    return self.places.sorted(byKeyPath: "distanceOpt").toArray()
  }

  func mapping(map: Map) {
    identifier <-
      (map["identifier"], StringTransform())
    name <-
      (map["name"], StringTransform())
    desc <-
      (map["description"], StringTransform())
    imageURLString <-
      (map["image_url"], StringTransform())
    isCuisine <-
      (map["is_cuisine"], BoolTransform())
    displayStarts <-
      (map["display_starts"], ISO8601JustDateTransform())
    displayEnds <-
      (map["display_ends"], ISO8601JustDateTransform())
    guideGroups <-
      (map["guide_groups"], ListTransform<GuideGroup>())
  }

  var imageURL: URL? {
    guard let imageURLString = imageURLString else { return nil }
    return URL(string: imageURLString)
  }

}
