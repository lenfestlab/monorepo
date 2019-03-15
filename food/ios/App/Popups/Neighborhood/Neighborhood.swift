import UIKit
import Gloss

struct Neighborhood: JSONDecodable, Codable {
  let identifier: String
  let name: String

  init?(json: JSON) {
    self.identifier = ("identifier" <~~ json)!
    self.name = ("name" <~~ json)!
  }

}
