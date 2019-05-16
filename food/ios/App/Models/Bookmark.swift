import ObjectMapper
import ObjectMapperAdditions
import ObjectMapperAdditionsRealm
import RealmSwift

class Bookmark: RealmSwift.Object, Mappable {

  required convenience init?(map: Map) {
    self.init()
  }

  // NOTE: bookmarks initiated client-side before identifier set by server;
  // prefer place identifier for cache key.
  override static func primaryKey() -> String? {
    return "placeId"
  }

  @objc dynamic var identifier = "" // server-set
  @objc dynamic var place: Place?
  @objc dynamic var placeId: String? // ease queries
  @objc dynamic var lastSavedAt: Date?
  @objc dynamic var lastUnsavedAt: Date?
  @objc dynamic var lastEnteredAt: Date?
  @objc dynamic var lastExitedAt: Date?
  @objc dynamic var lastNotifiedAt: Date?

  func mapping(map: Map) {
    identifier <-
      map["identifier"]
    place <-
      map["place"]
    placeId = place?.identifier
    lastSavedAt <-
      (map["last_saved_at"], ISO8601DateTransform())
    lastUnsavedAt <-
      (map["last_unsaved_at"], ISO8601DateTransform())
    lastEnteredAt <-
      (map["last_entered_at"], ISO8601DateTransform())
    lastExitedAt <-
      (map["last_exited_at"], ISO8601DateTransform())
    lastNotifiedAt <-
      (map["last_notified_at"], ISO8601DateTransform())
  }

  var isSaved: Bool {
    guard let savedAt = lastSavedAt else { return false }
    if let unsavedAt = lastUnsavedAt, unsavedAt > savedAt { return false }
    return true
  }

}
