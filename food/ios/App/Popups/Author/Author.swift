import UIKit
import Gloss

struct Author: JSONDecodable, Codable {
  let identifier: String
  let first: String
  let last: String

  init?(json: JSON) {
    self.identifier = ("identifier" <~~ json)!
    self.first = ("first" <~~ json)!
    self.last = ("last" <~~ json)!
  }

  var name : String {
    return "\(self.first) \(self.last)"
  }

}
