import RxSwift
import RxCocoa
import RealmSwift
import RxRealm
import RxSwiftExt
import AlamofireImage

class Cache {

  init(env: Env) {
    // Realm
    Realm.Configuration.defaultConfiguration =
      Realm.Configuration(
        // clear cache on schema conflict
        deleteRealmIfMigrationNeeded: true)
    // log db location for Realm Browser
    if env.isPreProduction, let db = Realm.Configuration.defaultConfiguration.fileURL {
      print("realm db file: \(db.absoluteString)")
    }
  }

  var realm: Realm {
    return try! Realm()
  }

  lazy var asyncOpen$: Observable<Realm> = {
    return Observable.create { observer -> Disposable in
      Realm.asyncOpen { (realm, error) in
        if let err = error {
          observer.onError(err)
        } else if let realm = realm {
          observer.onNext(realm)
        }
        observer.onCompleted()
      }
      return Disposables.create()
    }
    .take(1)
    .share(replay: 1, scope: .whileConnected)
  }()

  func get<T: Object>(_ identifier: String) -> T? {
    return realm.object(ofType: T.self, forPrimaryKey: identifier)
  }
  func get<T: Object>(_ identifiers: [String]) -> [T] {
    return realm.objects(T.self).filter("(identifier IN %@)", identifiers).toArray()
  }

  func put<T: RealmSwift.Object>(_ newObjects: [T], overwriteLocalProperties: Bool = false) throws -> [T] {
    let realm = self.realm
    var results: [T] = []
    try realm.write {
      newObjects.forEach({ (newObject: T) in
        if !overwriteLocalProperties, let newObject = newObject as? PartialUpdatable {
          results.append(realm.create(T.self, value: newObject.asPartialDictionary(), update: .modified))
        } else {
          results.append(realm.create(T.self, value: newObject.asDictionary(), update: .modified))
        }
      })
    }
    return results
  }
  func put<T: RealmSwift.Object>(_ newObject: T, overwriteLocalProperties: Bool = false) throws -> T {
    var result: T!
    try realm.write {
      if !overwriteLocalProperties, let newObject = newObject as? PartialUpdatable {
        result = realm.create(T.self, value: newObject.asPartialDictionary(), update: .modified)
      } else {
        result = realm.create(T.self, value: newObject.asDictionary(), update: .modified)
      }
    }
    return result
  }

  private func asArray$<T: Object>(_ results: Results<T>) -> Observable<[T]> {
    return
      Observable.array(from: results, synchronousStart: false)
        .startWith(results.toArray())
        .share(replay: 1, scope: .whileConnected)
  }

  private func allObjects$<T: Object>() -> Observable<[T]> {
    return asArray$(realm.objects(T.self))
  }

  lazy var nabes$: Observable<[Neighborhood]> = {
    return allObjects$()
  }()

  lazy var authors$: Observable<[Author]> = {
    return allObjects$()
  }()

  var bookmarks: Results<Bookmark> {
    return
      realm.objects(Bookmark.self)
        .sorted(byKeyPath: "lastSavedAt", ascending: false)
        .filter("lastSavedAt != nil AND ((lastUnsavedAt == nil) OR (lastUnsavedAt < lastSavedAt))")
  }

  enum CategoryFilter {
    case guide
    case cuisine
  }
  func categories$(filter: CategoryFilter) -> Observable<[Category]> {
    var results = realm.objects(Category.self)
    switch filter {
    case .cuisine:
      results = results
        .filter("isCuisine = true")
    case .guide:
      results = results
        .filter("isCuisine = false")
        .sorted(byKeyPath: "displayStarts", ascending: false)
    }
    return asArray$(results)
  }

  lazy var cuisines$: Observable<[Category]> = {
    return categories$(filter: .cuisine)
  }()

  typealias Guide = Category
  static func orderedByIdentifier(_ ids: [String], _ guides: [Guide]) -> [Guide] {
    return ids.compactMap { identifier -> Guide? in
      return guides.first { $0.identifier == identifier }
    }
  }
  func guides$(guideGroup: GuideGroup) -> Observable<[Guide]> {
    let guideIdentifiers: [String] = guideGroup.guidesIdentifiers.toArray()
    return asArray$(
      realm.objects(Category.self)
        .filter("%@ IN guideGroups", guideGroup))
      .map { (guides: [Guide]) -> [Guide] in
        return Cache.orderedByIdentifier(guideIdentifiers, guides)
    }
  }

  lazy var guideGroups$: Observable<[GuideGroup]> = {
    return asyncOpen$
      .flatMapFirst( { [unowned self] realm -> Observable<[GuideGroup]> in
        return self.asArray$(
          realm
            .objects(GuideGroup.self)
            .sorted(byKeyPath: "priority", ascending: false))
      })
  }()

  enum PlaceFilter {
    case all
    case bookmarked
    case category(_ identifier: String)
  }
  func observePlaces$(_ filter: PlaceFilter = .all) -> Observable<[Place]> {
    switch filter {
    case .all:
      return asArray$(realm.objects(Place.self)
        .sorted(byKeyPath: "distanceOpt"))
    case .bookmarked:
      return
        asArray$(bookmarks)
          .map({ $0.compactMap({ $0.place }) })
    case .category(let identifier):
      guard let category = realm.object(ofType: Category.self, forPrimaryKey: identifier)
        else { return Observable.just([]) }
      return asArray$(realm.objects(Place.self)
        .filter("%@ IN categories", category)
        .sorted(byKeyPath: "distanceOpt"))
    }
  }

  lazy var defaultPlaces$: Observable<[Place]> = {
    return observePlaces$(.all)
  }()

  lazy var bookmarkedPlaces$: Observable<[Place]> = {
    return observePlaces$(.bookmarked)
  }()

  var isEmpty$: Observable<Bool> {
    return observePlaces$()
      .map({ places in
        return places.isEmpty
      })
      .distinctUntilChanged()
      .share()
  }

  func observePlace$(_ place: Place) -> Observable<Place> {
    return Observable.from(object: place)
  }

  func patchBookmark(
    _ placeId: String,
    toSaved: Bool
    ) -> Void {
    let bookmark = Bookmark()
    bookmark.placeId = placeId
    bookmark.place = realm.object(ofType: Place.self, forPrimaryKey: placeId)
    if toSaved {
      bookmark.lastSavedAt = Date()
    } else {
      bookmark.lastUnsavedAt = Date()
    }
    let _ = try? put(bookmark)
  }

  func patchBookmark(_ placeId: String, lastNotifiedAt: Date) -> Void {
    let bookmark = Bookmark()
    bookmark.placeId = placeId
    bookmark.place = self.realm.object(ofType: Place.self, forPrimaryKey: placeId)
    bookmark.lastNotifiedAt = lastNotifiedAt
    let _ = try? put(bookmark)
  }

  func isSaved(_ placeId: String) -> Bool {
    guard
      let existing = realm.object(ofType: Bookmark.self, forPrimaryKey: placeId)
      else { return false }
    return existing.isSaved
  }

  func bookmark$(_ placeId: String) -> Observable<Bookmark?> {
    let query = realm.objects(Bookmark.self).filter("placeId = %@", placeId)
    return Observable.array(from: query).map({ $0.first })
  }

  func isSaved$(_ placeId: String) -> Observable<Bool> {
    return bookmark$(placeId)
      .unwrap()
      .map({ $0.isSaved })
      .startWith(isSaved(placeId))
      .share()
  }

  func loadImages$(_ urls: [URL], withLoader loader: ImageDownloader) -> Observable<[Image]> {
    return Observable.zip( urls.map({ url in
      return Observable.just(url)
        .observeOn(Scheduler.background)
        .flatMap({ [unowned self] url in
          return self.loadImage$(url, withLoader: loader)
        })
    }))
  }

  private func loadImage$(_ url: URL, withLoader loader: ImageDownloader) -> Observable<Image> {
    let request = URLRequest(url: url)
    return Observable.create { observer in
      let receipt = loader.download(request, completion: { response in
        switch response.result {
        case .success(let image):
          observer.onNext(image)
        case .failure(let error):
          observer.onError(error)
        }
        observer.onCompleted()
      })
      return Disposables.create {
        guard let receipt = receipt else { return }
        loader.cancelRequest(with: receipt)
      }
    }
  }

  lazy var viewedPlaces$: Observable<[Place]> = {
    return asArray$(realm.objects(PlaceEvent.self))
      .map({ [unowned self] placeEvents -> [Place] in
        let placeIds: [String] = placeEvents.compactMap({$0.placeId})
        return self.get(placeIds)
      })
      .share(replay: 1, scope: .whileConnected)
  }()

  lazy var recentPlaceEvents$: Observable<[PlaceEvent]> = {
    return asArray$(realm.objects(PlaceEvent.self)
        .sorted(byKeyPath: "lastEnteredAt", ascending: false))
  }()

  func observeVisitedAt$(_ placeId: String) -> Observable<Date?> {
    guard
      let event = realm.object(ofType: PlaceEvent.self, forPrimaryKey: placeId)
      else { return Observable.just(nil) }
    return Observable.from(object: event, emitInitialValue: false)
      .map({ $0.lastVisitedAt })
      .unwrap()
  }

}
