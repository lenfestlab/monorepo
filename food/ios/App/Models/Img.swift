import ObjectMapper
import ObjectMapperAdditions
import ObjectMapperAdditionsRealm
import RealmSwift

class Img: RealmSwift.Object, Mappable {
  required convenience init?(map: Map) {
    self.init()
  }
  override static func primaryKey() -> String? {
    return "identifier"
  }

  @objc dynamic var identifier = ""
  @objc dynamic var urlString: String?
  @objc dynamic var credit: String?
  @objc dynamic var caption: String?

  func mapping(map: Map) {
    identifier <-
      (map["identifier"], StringTransform())
    urlString <-
      (map["url"], StringTransform())
    credit <-
      (map["credit"], StringTransform())
    caption <-
      (map["caption"], StringTransform())
  }

  var url: URL? {
    guard let urlString = urlString else { return nil }
    return URL(string: urlString)
  }

}
