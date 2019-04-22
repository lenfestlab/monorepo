import UIKit
import Gloss

struct Category: JSONDecodable, Codable {
  let identifier: String
  let name: String?
  let description: String?
  let imageURL: URL?

  init?(json: JSON) {
    self.identifier = ("identifier" <~~ json)!
    self.name = "name" <~~ json
    self.description = "description" <~~ json
    self.imageURL = "image_url" <~~ json
  }

}
