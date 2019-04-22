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

func updateBookmark(placeId: String, toSaved: Bool, completion: ((Bool) -> Void)?) {
  let env = Env()
  var params: [String: Any] = ["place_id": placeId]
  if let authToken = Installation.authToken() {
    params["auth_token"] = authToken
  }
  let url = "\(env.apiBaseUrlString)/bookmarks"
  let method: HTTPMethod = toSaved ? .post : .delete
  Alamofire.request(url, method: method, parameters:params).responseJSON { response in
    guard
      let _ = response.result.value as? JSON
      else {
        DispatchQueue.main.async { completion?(false) }
        return print("MIA: parsed response") }
    fetchBookmarks(completion)
  }
}

func fetchBookmarks(_ completion: ((Bool)->Void)?) {
  let env = Env()
  var params: [String: Any] = [:]
  if let authToken = Installation.authToken() { params["auth_token"] = authToken }
  let url = "\(env.apiBaseUrlString)/bookmarks"
  Alamofire.request(url, method: .get, parameters:params).responseJSON { response in
    guard
      let json = response.result.value as? JSON,
      let bookmkarksJSON = json["data"] as? [JSON],
      let bookmarks = [Bookmark].from(jsonArray: bookmkarksJSON)
      else {
        DispatchQueue.main.async { completion?(false) }
        return print("MIA: parsed bookmarks") }
    print(bookmarks)
    let places: [Place] = bookmarks.compactMap({$0.place})
    print(places)
    Bookmark.cacheLatest(places: places)
    completion?(true)
  }
}

extension Bookmark {
  static func cacheLatest(places: [Place]) {
    // reset region monitoring
    LocationManager.shared.resetRegionMonitoring(places: places)
    // update cache
    Place.save(identifiers: places.map({ $0.identifier }))
    NotificationCenter.default.post(name: .favoritesUpdated, object: nil)
  }
}
