import ObjectMapper
import ObjectMapperAdditions
import ObjectMapperAdditionsRealm
import RealmSwift

class Author: RealmSwift.Object, Mappable {

  required convenience init?(map: Map) {
    self.init()
  }

  override static func primaryKey() -> String? {
    return "identifier"
  }

  @objc dynamic var identifier: String = ""
  @objc dynamic var first: String?
  @objc dynamic var last: String?

  func mapping(map: Map) {
    identifier <-
      (map["identifier"], StringTransform())
    first <-
      (map["first"], StringTransform())
    last <-
      (map["last"], StringTransform())
  }

  var name : String {
    return "\(self.first ?? "") \(self.last ?? "")"
  }

}
