import Alamofire
import RxAlamofire
import RxSwift
import RxCocoa
import RxSwiftExt
import RxRelay
import Gloss
import ObjectMapper
import RealmSwift

fileprivate let cacheKeyAuthToken = "auth-token"
fileprivate let cacheKeyEmail = "email"

class Api {

  typealias Result<T> = Swift.Result<T, Error>

  enum ApiError: Error {
    case parse
    case auth
    case missingSelf
  }

  let env: Env
  let cache: Cache
  let locationManager: LocationManager

  init(
    env: Env,
    cache: Cache,
    locationManager: LocationManager
    ) {
    self.env = env
    self.cache = cache
    self.locationManager = locationManager
  }

  typealias AuthToken = String
  let authToken$$ = BehaviorRelay<AuthToken?>(value: {() -> String? in
    let defaults = UserDefaults.standard
    guard let token = defaults.value(forKey: cacheKeyAuthToken) as? String else {
      return nil
    }
    return token
  }())
  lazy var authToken$ = { () -> Observable<AuthToken> in
    return self.authToken$$
      .asObservable()
      .unwrap()
      .distinctUntilChanged()
      .do(onNext: { [unowned self] token in
        let defaults = UserDefaults.standard
        defaults.setValue(token, forKey: cacheKeyAuthToken)
        defaults.synchronize()
      })
      .share(replay: 1, scope: .whileConnected)
  }()
  var authToken: AuthToken? {
    set {
      authToken$$.accept(newValue)
    }
    get {
      return authToken$$.value
    }
  }

  typealias Email = String
  let email$$ = BehaviorRelay<Email?>(value: {() -> Email? in
    let defaults = UserDefaults.standard
    guard let email = defaults.value(forKey: cacheKeyEmail) as? String else {
      return nil
    }
    return email
  }())
  lazy var email$ = {() -> Observable<Email?> in
    return email$$
      .asObservable()
      .distinctUntilChanged()
      .do(onNext: { [unowned self] email in
        let defaults = UserDefaults.standard
        defaults.setValue(email, forKey: cacheKeyEmail)
        defaults.synchronize()
      })
      .share(replay: 1, scope: .whileConnected)
  }()
  var email: String? {
    set {
      email$$.accept(newValue)
    }
    get {
      return email$$.value
    }
  }

  func registerInstall$() -> Observable<Void> {
    return patchInstall$(params: [:])
  }

  func updateEmail$(email: String) -> Observable<Void> {
    return patchInstall$(params: ["email" : email])
  }

  func updateGcmToken$(_ token: String) -> Observable<Void> {
    return patchInstall$(params: ["gcm_token" : token])
  }

  private func patchInstall$(params: [String: Any]) -> Observable<Void> {
    let url = "\(env.apiBaseUrlString)/installs/\(env.installationId)"
    return
      RxAlamofire
        .requestJSON(.patch, url, parameters: params)
        .observeOn(Scheduler.background)
        .map({ _response, json -> (String, String?) in
          guard
            let json = json as? JSON,
            let authToken = json["auth_token"] as? AuthToken
            else { throw ApiError.parse }
          let email = json["email"] as? String
          return (authToken, email)
        })
        .observeOn(Scheduler.main)
        .map({ (token, email) -> Void in
          self.authToken = token
          self.email = email
        })
  }


  func getPlace$(_ identifier: String) -> Observable<Result<Place>> {
    return
      RxAlamofire
        .requestJSON(.get, "\(env.apiBaseUrlString)/places/\(identifier)")
        .observeOn(Scheduler.background)
        .retry(2)
        .map({ _response, json -> Result<Place> in
          guard
            let json = json as? JSON,
            let placeJSON = json["place"] as? JSON,
            let place = Place(JSON: placeJSON)
            else { return Result.failure(ApiError.parse) }
          return Result.success(place)
        })
        .catchError({ error -> Observable<Result<Place>> in
          return Observable.just(Result.failure(error))
        })
  }

  private func patchBookmark(
    _ identifier: String,
    _ params: [String: Any]
    ) -> Observable<Bookmark> {
    let url = "\(env.apiBaseUrlString)/bookmarks"
    var params = params
    params["place_id"] = identifier
    if let authToken = self.authToken { params["auth_token"] = authToken }
    return
      RxAlamofire
        .requestJSON(.patch, url, parameters: params)
        .observeOn(Scheduler.background)
        .retry(2)
        .map({ [weak self] (_response, json) -> Bookmark in
          guard
            let `self` = self,
            let json = json as? JSON,
            let data = json["bookmark"] as? JSON,
            let bookmark = Bookmark(JSON: data)
            else { throw ApiError.parse }
          return try self.cache.put(bookmark)
        })
        .flatMap({ (object: Bookmark) -> Observable<Bookmark> in
          return Observable.just(object)
            .map({ ThreadSafeReference(to: $0) })
            .observeOn(Scheduler.main)
            .map({ ref -> Bookmark? in
              let realm = try Realm()
              return realm.resolve(ref)
            })
            .unwrap()
        })
  }

  func recordRegionChange$(
    _ identifier: String,
    isEntering: Bool
    ) -> Observable<Bookmark> {
    let key = isEntering ? "last_entered_at" : "last_exited_at"
    return patchBookmark(identifier, [key : Date() ])
  }

  func recordNotification$(
    _ identifier: String
    ) -> Observable<Bookmark> {
    let now = Date()
    cache.patchBookmark(identifier, lastNotifiedAt: now)
    return patchBookmark(identifier, ["last_notified_at": now])
  }

  func recordVisit$(_ identifier: String) -> Observable<Bookmark> {
    return patchBookmark(identifier, ["last_visited_at": Date()])
  }

  func updateBookmark$(
    _ placeId: String,
    toSaved: Bool
    ) -> Observable<Bookmark> {
    self.cache.patchBookmark(placeId, toSaved: toSaved)
    return self.patchBookmark(placeId, [
      (toSaved ? "last_saved_at" : "last_unsaved_at") : Date() ])
      .do(onError: { [weak self] _ in
        self?.cache.patchBookmark(placeId, toSaved: !toSaved)
      })
      .observeOn(Scheduler.main)
      .share()
  }

  func updateBookmarks$() -> Observable<[Bookmark]> {
    let url = "\(env.apiBaseUrlString)/bookmarks"
    return
      authToken$
        .flatMapFirst({ authToken -> Observable<[Bookmark]> in
          let params: [String: Any] = ["auth_token": authToken]
          return RxAlamofire
            .requestJSON(.get, url, parameters: params)
            .observeOn(Scheduler.background)
            .retry(2)
            .map({ [weak self] _response, json -> [Bookmark] in
              guard
                let `self` = self,
                let json = json as? JSON,
                let data = json["data"] as? [JSON]
                else { throw ApiError.parse }
              let bookmarks: [Bookmark] = [Bookmark].init(JSONArray: data)
              return try self.cache.put(bookmarks)
            })
            .flatMap({ (objects: [Bookmark]) -> Observable<[Bookmark]> in
              return Observable.just(objects)
                .map({ $0.map({ ThreadSafeReference(to: $0) }) })
                .observeOn(Scheduler.main)
                .map({ refs in
                  let realm = try Realm()
                  return refs.compactMap(realm.resolve)
                })
            })
        })
  }

  enum Target {
    case placesAll
    case placesBookmarked
    case placesCategorizedIn(_ categoryIdentifier: String)

    var path: String {
      switch self {
      case .placesAll:
        return "places.json"
      case .placesBookmarked:
        return "places.json?bookmarked=1"
      case .placesCategorizedIn(let identifier):
        return "places.json?categories=\(identifier)"
      }
    }

    var urlString: String {
      let env = Env()
      return "\(env.apiBaseUrlString)/\(self.path)"
    }
  }

  func getPlaces$(
    target: Target,
    lat: Double,
    lng: Double,
    prices: [Int] = [],
    ratings: [Int] = [],
    categories: [Category] = [],
    neigborhoods: [Neighborhood] = [],
    authors: [Author] = [],
    sort: SortMode = .distance,
    limit: Int = 1000
    ) -> Observable<[Place]> {
    let category_ids = categories.map { $0.identifier }
    let nabe_ids = neigborhoods.map { $0.identifier }
    let author_ids = authors.map { $0.identifier }
    var params: [String: Any] = [
      "lat": lat,
      "lng": lng,
      "limit": limit,
      "prices": prices,
      "ratings": ratings,
      "categories": category_ids,
      "nabes": nabe_ids,
      "authors": author_ids,
      "sort": sort.rawValue.lowercased(),
    ]
    if let authToken = self.authToken { params["auth_token"] = authToken }
    return
      RxAlamofire
        .requestJSON(.get, target.urlString, parameters: params)
        .observeOn(Scheduler.background)
        .map({ (_response, json) -> [Place] in
          guard
            let json = json as? JSON,
            let data = json["data"] as? [JSON]
            else { throw ApiError.parse }
          return [Place](JSONArray: data)
        })
        // recalculate distance locally
        .do(onNext: { [weak self] places in
          guard let currentLocation = self?.locationManager.latestLocation
            else { return print("MIA: currentLocation") }
          places.forEach({ place in
            if let placeLocation = place.location?.nativeLocation {
              let distance = currentLocation.distance(from: placeLocation)
              place.distance = distance
            }
          })
        })
        .map({ [weak self] (places: [Place]) in
          guard let `self` = self else { throw ApiError.missingSelf }
          return try self.cache.put(places)
        })
        // if sorted by distance, re-sort using local distance calculations
        .map({ (places: [Place]) in
          guard case SortMode.distance = sort else { return places }
          return places.sorted(by: {
            guard let d1 = $0.distance, let d2 = $1.distance else { return false }
            return d1 <= d2
          })
        })
        // map thread-unsafe realm objects back to main thread
        .flatMap({ (objects: [Place]) -> Observable<[Place]> in
          return Observable.just(objects)
            .map({ $0.map({ ThreadSafeReference(to: $0) }) })
            .observeOn(Scheduler.main)
            .map({ refs -> [Place] in
              let realm = try Realm()
              return refs.compactMap(realm.resolve)
            })
        })
        .share()
  }

  func updateDefaultPlaces$(lat: Double, lng: Double) -> Observable<[Place]> {
    return getPlaces$(target: .placesAll, lat: lat, lng: lng)
  }

}
