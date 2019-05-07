import Alamofire
import RxAlamofire
import RxSwift
import RxCocoa
import RxSwiftExt
import Gloss
import ObjectMapper

class Api {

  typealias Result<T> = Swift.Result<T, Error>

  enum ApiError: Error {
    case parse
    case auth
  }

  let env: Env
  let cache: Cache

  init(env: Env, cache: Cache) {
    self.env = env
    self.cache = cache
  }

  func getPlace$(_ identifier: String) -> Observable<Result<Place>> {
    return
      RxAlamofire
        .requestJSON(.get, "\(env.apiBaseUrlString)/places/\(identifier)")
        .observeOn(Scheduler.background)
        .map({ _response, json -> Result<Place> in
          guard
            let json = json as? JSON,
            let placeJSON = json["place"] as? JSON,
            let place = Place(json: placeJSON)
            else { return Result.failure(ApiError.parse) }
          return Result.success(place)
        })
        .catchError({ error -> Observable<Result<Place>> in
          return Observable.just(Result.failure(error))
        })
  }

  func recordRegionChange$(
    _ identifier: String,
    isEntering: Bool
    ) -> Observable<Result<Bookmark>> {
    let url = "\(env.apiBaseUrlString)/bookmarks"
    var params: [String: Any] = [ "place_id" : identifier ]
    if let authToken = Installation.authToken() { params["auth_token"] = authToken }
    params[(isEntering ? "last_entered_at" : "last_exited_at")] = Date()
    return
      RxAlamofire
        .requestJSON(.patch, url, parameters: params)
        .observeOn(Scheduler.background)
        .map({ _response, json -> Result<Bookmark> in
          guard
            let json = json as? JSON,
            let oJSON = json["bookmark"] as? JSON,
            let bookmark = Bookmark(json: oJSON)
            else { return Result.failure(ApiError.parse) }
          return Result.success(bookmark)
        })
        .retry(3)
        .catchError({ error -> Observable<Result<Bookmark>> in
          return Observable.just(Result.failure(error))
        })
  }

  func recordVisit$(_ identifier: String) -> Observable<Result<Bookmark>> {
    let url = "\(env.apiBaseUrlString)/bookmarks"
    var params: [String: Any] = [ "place_id" : identifier ]
    if let authToken = Installation.authToken() { params["auth_token"] = authToken }
    params["last_visited_at"] = Date()
    return
      RxAlamofire
        .requestJSON(.patch, url, parameters: params)
        .observeOn(Scheduler.background)
        .map({ _response, json -> Result<Bookmark> in
          guard
            let json = json as? JSON,
            let oJSON = json["bookmark"] as? JSON,
            let bookmark = Bookmark(json: oJSON)
            else { return Result.failure(ApiError.parse) }
          return Result.success(bookmark)
        })
        .retry(3)
        .catchError({ error -> Observable<Result<Bookmark>> in
          return Observable.just(Result.failure(error))
        })
  }

  var refreshCategories$: Observable<[UIImage]> {
    let url = "\(env.apiBaseUrlString)/categories"
    return
      RxAlamofire
        .requestJSON(.get, url)
        .observeOn(Scheduler.background)
        .map({ [weak self] _response, json -> [Category] in
          guard
            let json = json as? JSON,
            let data = json["data"] as? [JSON]
            else { throw ApiError.parse }
          let objects = [CategoryObject].init(JSONArray: data)
          // write to cache
          try self?.cache.replaceCategories(objects)
          return objects.map({Category($0) })
        })
        .flatMapLatest({ [weak self] categories -> Observable<[UIImage]> in
          guard let `self` = self else { return Observable.just([]) }
          let urls = categories.compactMap({ $0.imageURL })
          return self.cache.loadImages$(urls)
        })
        .debug("refreshCategories$")
  }

}
