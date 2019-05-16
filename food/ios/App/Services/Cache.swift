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

  lazy var cuisines$: Observable<[Category]> = {
    return categories$(filter: .cuisine)
  }()

  lazy var guides$: Observable<[Category]> = {
    return categories$(filter: .guide)
  }()

  lazy var nabes$: Observable<[Neighborhood]> = {
    var query = realm.objects(Neighborhood.self)
    return
      Observable.array(from: query, synchronousStart: true)
        .share()
  }()

  lazy var authors$: Observable<[Author]> = {
    var query = realm.objects(Author.self)
    return
      Observable.array(from: query, synchronousStart: true)
        .share()
  }()

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

  enum CategoryFilter {
    case none
    case guide
    case cuisine
  }
  func categories$(filter: CategoryFilter) -> Observable<[Category]> {
    var query = realm.objects(Category.self)
    switch filter {
    case .none:
      print("NOOP")
    case .cuisine:
      query = query.filter("isCuisine = true")
    case .guide:
      query = query.filter("isCuisine = false")
    }
    return
      Observable.array(from: query, synchronousStart: true)
        .share()
  }
  func categoryChanges$(_ filter: CategoryFilter) -> Observable<RealmChangeset> {
    var query = realm.objects(Category.self)
    switch filter {
    case .none:
      print("NOOP")
    case .cuisine:
      query = query.filter("isCuisine = true")
    case .guide:
      query = query.filter("isCuisine = false")
    }
    return
      Observable.arrayWithChangeset(from: query, synchronousStart: true)
        .map({ (categories: [Category], changeset: RealmChangeset?) -> RealmChangeset? in
          return changeset
        })
        .unwrap()
        .share()
  }

  enum PlaceFilter {
    case all
    case bookmarked
    case category(_ identifier: String)
  }
  func observePlaces$(_ filter: PlaceFilter = .all) -> Observable<[Place]> {
    guard case .bookmarked = filter else { return Observable.just([]) }
    let query =
      realm.objects(Bookmark.self)
        .sorted(byKeyPath: "lastSavedAt", ascending: false)
        .filter("lastSavedAt != nil AND ((lastUnsavedAt == nil) OR (lastUnsavedAt < lastSavedAt))")
    return
      Observable.array(from: query, synchronousStart: true)
        .map({ $0.compactMap({ $0.place }) })
        .share(replay: 1, scope: .whileConnected)
  }
  var bookmarks: [Bookmark] {
    return realm.objects(Bookmark.self).toArray()
  }

  lazy var defaultPlaces$: Observable<[Place]> = {
    return observePlaces$()
  }()

  lazy var bookmarked$: Observable<[Place]> = {
    return observePlaces$(.bookmarked)
  }()

  func patchBookmark(
    _ placeId: String,
    toSaved: Bool
    ) -> Void {
    let realm = self.realm
    let existing = realm.object(ofType: Bookmark.self, forPrimaryKey: placeId)
    try? realm.write {
      if let bookmark = existing {
        bookmark.lastSavedAt = Date()
      } else {
        let bookmark = Bookmark()
        bookmark.place = realm.object(ofType: Place.self, forPrimaryKey: placeId)
        bookmark.lastUnsavedAt = Date()
        bookmark.placeId = placeId
        realm.add(bookmark, update: true)
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
