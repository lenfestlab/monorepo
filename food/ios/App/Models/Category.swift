import ObjectMapper
import ObjectMapperAdditions
import ObjectMapperAdditionsRealm
import RealmSwift

class Category: RealmSwift.Object, Mappable {

  required convenience init?(map: Map) {
    self.init()
  }

  override static func primaryKey() -> String? {
    return "identifier"
  }

  @objc dynamic var identifier = ""
  @objc dynamic var name: String = ""
  @objc dynamic var desc: String?
  @objc dynamic var imageURLString: String?
  @objc dynamic var isCuisine: Bool = false
  @objc dynamic var displayStarts: Date?
  @objc dynamic var displayEnds: Date?

  let places = LinkingObjects(fromType: Place.self, property: "categories")

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
  }

  var imageURL: URL? {
    guard let imageURLString = imageURLString else { return nil }
    return URL(string: imageURLString)
  }

}
