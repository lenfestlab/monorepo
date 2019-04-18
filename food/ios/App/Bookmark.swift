import UIKit
import Alamofire
import Gloss

struct Bookmark: JSONDecodable, Codable {
  let identifier: String
  let place: Place?

  init?(json: JSON) {
    self.identifier = ("identifier" <~~ json)!
    self.place = "place" <~~ json
  }
}


func createBookmark(placeId: String, completion: ((Bool) -> Void)?) {
  let env = Env()
  var params: [String: Any] = ["place_id": placeId]

  if let authToken = Installation.authToken() {
    params["auth_token"] = authToken
  }

  let url = "\(env.apiBaseUrlString)/bookmarks"
  Alamofire.request(url, method:.post, parameters:params).responseJSON { response in
    guard (response.result.value as? JSON) != nil else {
      DispatchQueue.main.async { completion?(false) }
      return
    }

    DispatchQueue.main.async {
      completion?(true)
    }

    Place.save(identifier: placeId)
    NotificationCenter.default.post(name: .favoritesUpdated, object: nil)
  }
}

func deleteBookmark(placeId: String, completion: ((Bool) -> Void)?) {
  let env = Env()
  var params: [String: Any] = ["place_id": placeId]

  if let authToken = Installation.authToken() {
    params["auth_token"] = authToken
  }

  let url = "\(env.apiBaseUrlString)/bookmarks"
  Alamofire.request(url, method:.delete, parameters:params).responseJSON { response in
    guard (response.result.value as? JSON) != nil else {
      DispatchQueue.main.async { completion?(false) }
      return
    }


    DispatchQueue.main.async {
      completion?(true)
    }

    Place.remove(identifier: placeId)
    NotificationCenter.default.post(name: .favoritesUpdated, object: nil)
  }
}
