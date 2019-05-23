import RxSwift
import RxCocoa
import RealmSwift
import RxRealm
import AlamofireImage

class Cache {

  init() {
    // Realm
    Realm.Configuration.defaultConfiguration =
      Realm.Configuration(
        // clear cache on schema conflict
        deleteRealmIfMigrationNeeded: true)
  }

  var realm: Realm {
    return try! Realm()
  }

  func replace<T: RealmSwift.Object>(_ newObjects: [T]) throws -> Void {
    let realm = self.realm
    try realm.write {
      let oldObjects = realm.objects(T.self)
      realm.delete(oldObjects)
      realm.add(newObjects, update: true)
    }
  }

  func put<T: RealmSwift.Object>(_ newObjects: [T]) throws -> Void {
    let realm = self.realm
    try realm.write {
      realm.add(newObjects, update: true)
    }
  }
  func put<T: RealmSwift.Object>(_ newObject: T) throws -> Void {
    let realm = self.realm
    try realm.write {
      realm.add(newObject, update: true)
    }
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
    return realm.objects(Bookmark.self)
      .sorted(byKeyPath: "lastSavedAt", ascending: false)
      .filter("lastSavedAt != nil AND ((lastUnsavedAt == nil) OR (lastUnsavedAt < lastSavedAt))")
  }

  lazy var bookmarks$: Observable<[Bookmark]> = {
    return asArray$(bookmarks)
  }()

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

  lazy var guides$: Observable<[Category]> = {
    return categories$(filter: .guide)
  }()

  enum PlaceFilter {
    case all
    case bookmarked
    case category(_ identifier: String)
  }
  func observePlaces$(_ filter: PlaceFilter = .all) -> Observable<[Place]> {
    switch filter {
    case .all:
      return allObjects$()
    case .bookmarked:
      return
        bookmarks$
          .map({ $0.compactMap({ $0.place }) })
          .share(replay: 1, scope: .whileConnected)
    case .category(let identifier):
      guard let category = realm.object(ofType: Category.self, forPrimaryKey: identifier)
        else { return Observable.just([]) }
      let places = self.places(in: category)
      return
        Observable.array(from: places, synchronousStart: false)
          .startWith(places.toArray())
          .share()
    }
  }

  lazy var defaultPlaces$: Observable<[Place]> = {
    return observePlaces$(.all)
  }()

  lazy var bookmarkedPlaces$: Observable<[Place]> = {
    return observePlaces$(.bookmarked)
  }()

  private var places: Results<Place> {
    return realm.objects(Place.self)
  }

  private func places(in category: Category) -> Results<Place> {
    return places.filter("%@ IN categories", category)
  }

  var isEmpty: Bool {
    return places.isEmpty
  }

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
    let realm = self.realm
    let existing = realm.object(ofType: Bookmark.self, forPrimaryKey: placeId)
    try? realm.write {
      let bookmark = existing ?? { () -> Bookmark in
        let bookmark = Bookmark()
        bookmark.placeId = placeId
        bookmark.place = realm.object(ofType: Place.self, forPrimaryKey: placeId)
        realm.add(bookmark, update: true)
        return bookmark
      }()
      if toSaved {
        bookmark.lastSavedAt = Date()
      } else {
        bookmark.lastUnsavedAt = Date()
      }
    }
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
      return self.loadImage$(url, withLoader: loader)
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

}
