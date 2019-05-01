import UIKit
import Alamofire
import Gloss

struct Bookmark: JSONDecodable, Codable {
  let identifier: String
  let place: Place?
  let lastSavedAt: Date?
  let lastUnsavedAt: Date?
  let lastEnteredAt: Date?
  let lastExitedAt: Date?

  init?(json: JSON) {
    self.identifier = ("identifier" <~~ json)!
    self.place = "place" <~~ json
    self.lastSavedAt = Decoder.decode(dateISO8601ForKey: "last_saved_at")(json)
    self.lastUnsavedAt = Decoder.decode(dateISO8601ForKey: "last_unsaved_at")(json)
    self.lastEnteredAt = Decoder.decode(dateISO8601ForKey: "last_entered_at")(json)
    self.lastExitedAt = Decoder.decode(dateISO8601ForKey: "last_exited_at")(json)
  }

  var isSaved: Bool {
    guard let savedAt = lastSavedAt else { return false }
    if let unsavedAt = lastUnsavedAt, unsavedAt > savedAt { return false }
    return true
  }

}

func updateBookmark(
  placeId: String,
  toSaved: Bool,
  bookmarkHandler: ((Bookmark)->Void)?,
  completion: ((Bool) -> Void)?) {
  let env = Env()
  var params: [String: Any] = ["place_id": placeId]
  if let authToken = Installation.authToken() {
    params["auth_token"] = authToken
  }
  let url = "\(env.apiBaseUrlString)/bookmarks"
  params[(toSaved ? "last_saved_at" : "last_unsaved_at")] = Date()
  Alamofire.request(url, method: .patch, parameters:params).responseJSON { response in
    guard
      let json = response.result.value as? JSON
      else {
        DispatchQueue.main.async { completion?(false) }
        return print("MIA: parsed response")
    }
    if
      let bookmarkJSON = json["bookmark"] as? JSON,
      let bookmark = Bookmark(json: bookmarkJSON) {
      bookmarkHandler?(bookmark)
    }
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
    let savedBookmarks = bookmarks.filter({ $0.isSaved })
    let trackablePlaces: [Place] = savedBookmarks.compactMap({$0.place})
    print(trackablePlaces)
    Bookmark.cacheLatest(places: trackablePlaces)
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
