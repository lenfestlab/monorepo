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
  @objc dynamic var imageURLString: String?
  var prices = List<Int>()
  var ratingOpt = RealmOptional<Int>()
  @objc dynamic var placeSummary: String?
  @objc dynamic var menu: String?
  @objc dynamic var notes: String?
  @objc dynamic var drinks: String?
  @objc dynamic var remainder: String?
  @objc dynamic var author: Author?
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
    imageURLString <-
      (map["image_url"], StringTransform())
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
    guard let imageURLString = imageURLString else { return nil }
    return URL(string: imageURLString)
  }

  var rating: Int? {
    return ratingOpt.value
  }

}
