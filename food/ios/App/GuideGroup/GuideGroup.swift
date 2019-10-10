import ObjectMapper
import ObjectMapperAdditions
import ObjectMapperAdditionsRealm
import RealmSwift
import DifferenceKit

extension GuideGroup: Differentiable {}

class GuideGroup: RealmSwift.Object, Mappable {

  required convenience init?(map: Map) {
    self.init()
  }

  override static func primaryKey() -> String? {
    return "identifier"
  }

  @objc dynamic var identifier = ""
  @objc dynamic var title: String = ""
  @objc dynamic var desc: String = ""
  @objc dynamic var priority: Int = 0
  var guides = List<Category>()

  func mapping(map: Map) {
    identifier <-
      (map["identifier"], StringTransform())
    title <-
      (map["title"], StringTransform())
    desc <-
      (map["description"], StringTransform())
    priority <-
      (map["priority"], IntTransform())
    guides <-
      (map["guides"], ListTransform<Category>())
  }

}
