import ObjectMapper
import ObjectMapperAdditions
import ObjectMapperAdditionsRealm
import RealmSwift

class Post: RealmSwift.Object, Mappable {

  required convenience init?(map: Map) {
    self.init()
  }

  override static func primaryKey() -> String? {
    return "identifier"
  }

  @objc dynamic var identifier: String?
  @objc dynamic var urlString: String?
  @objc dynamic var title: String?
  @objc dynamic var blurb: String?
  var prices = List<Int>()
  var ratingOpt = RealmOptional<Int>()
  @objc dynamic var placeSummary: String?
  @objc dynamic var menu: String?
  @objc dynamic var notes: String?
  @objc dynamic var drinks: String?
  @objc dynamic var remainder: String?
  @objc dynamic var author: Author?
  @objc dynamic var publishedAt: Date?
  var images = List<Img>()

  func mapping(map: Map) {
    identifier <-
      (map["identifier"], StringTransform())
    urlString <-
      (map["url"], StringTransform())
    title <-
      (map["title"], StringTransform())
    blurb <-
      (map["blurb"], StringTransform())
    prices <-
      (map["prices"], RealmTransform())
    ratingOpt <-
      (map["rating"], RealmOptionalTransform())
    placeSummary <-
      (map["details.place_summary"], StringTransform())
    menu <-
      (map["details.menu"], StringTransform())
    notes <-
      (map["details.notes"], StringTransform())
    drinks <-
      (map["details.drinks"], StringTransform())
    remainder <-
      (map["details.remainder"], StringTransform())
    publishedAt <-
      (map["published_at"], ISO8601DateTransform())
    author <-
      map["author"]
    images <-
      (map["images"], ListTransform<Img>())
  }

  var url: URL? {
    guard let urlString = urlString else { return nil }
    return URL(string: urlString)
  }

  var imageURL: URL? {
    return images.first?.url
  }

  var rating: Int? {
    return ratingOpt.value
  }

}
