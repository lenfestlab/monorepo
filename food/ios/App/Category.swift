import UIKit
import Gloss

struct Category: JSONDecodable, Codable {
  let identifier: String
  let name: String?
  let imageURL: URL?

  init?(json: JSON) {
    self.identifier = ("identifier" <~~ json)!
    self.name = "name" <~~ json
    self.imageURL = "image_url" <~~ json
  }

}
