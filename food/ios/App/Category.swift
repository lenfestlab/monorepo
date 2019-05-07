import UIKit
import Gloss
import ObjectMapper
import RealmSwift

struct Category: JSONDecodable, Codable {
  let identifier: String
  let name: String?
  let description: String?
  let imageURL: URL?
  let isCuisine: Bool?

  init?(json: JSON) {
    self.identifier = ("identifier" <~~ json)!
    self.name = "name" <~~ json
    self.description = "description" <~~ json
    self.imageURL = "image_url" <~~ json
    self.isCuisine = ("is_cuisine" <~~ json)
  }

}


class CategoryObject: RealmSwift.Object, Mappable {
  @objc dynamic var identifier = ""
  @objc dynamic var name = ""
  @objc dynamic var desc = ""
  @objc dynamic var imageURLString = ""
  @objc dynamic var isCuisine = false

  required convenience init?(map: Map) {
    self.init()
  }

  override static func primaryKey() -> String? {
    return "identifier"
  }

  func mapping(map: Map) {
    identifier <- map["identifier"]
    name <- map["name"]
    desc <- map["description"]
    imageURLString <- map["image_url"]
    isCuisine <- map["is_cuisine"]
  }
}

public protocol Persistable {
  associatedtype RealmObject: RealmSwift.Object
  init(_ object: RealmObject)
}

extension Category: Persistable {
  public init(_ object: CategoryObject) {
    identifier = object.identifier
    name = object.name
    description = object.desc
    imageURL = URL(string: object.imageURLString)
    isCuisine = object.isCuisine
  }
}
