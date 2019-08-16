import ObjectMapper
import ObjectMapperAdditions
import ObjectMapperAdditionsRealm
import RealmSwift

class PlaceEvent: RealmSwift.Object, Mappable {

  enum Kind: String {
    case viewed, entered, exited, visited
    var name: String {
      return self.rawValue
    }
  }

  required convenience init?(map: Map) {
    self.init()
  }

  override static func primaryKey() -> String? {
    return "placeId"
  }
  override static func indexedProperties() -> [String] {
    return ["placeId"]
  }

  @objc dynamic var identifier = ""
  @objc dynamic var placeId = ""
  @objc dynamic var lastViewedAt: Date?
  @objc dynamic var lastEnteredAt: Date?
  @objc dynamic var lastExitedAt: Date?
  @objc dynamic var lastVisitedAt: Date?

  func mapping(map: Map) {
    identifier <-
      map["identifier"]
    lastViewedAt <-
      (map["last_viewed_at"], ISO8601DateTransform())
    lastEnteredAt <-
      (map["last_entered_at"], ISO8601DateTransform())
    lastExitedAt <-
      (map["last_exited_at"], ISO8601DateTransform())
    lastVisitedAt <-
      (map["last_visited_at"], ISO8601DateTransform())
    placeId <-
      map["place_identifier"]
  }

  var isRegionActive: Bool {
    guard
      let enteredAt = lastEnteredAt,
      let exitedAt = lastExitedAt
      else { return false }
    return exitedAt < enteredAt
  }

}
