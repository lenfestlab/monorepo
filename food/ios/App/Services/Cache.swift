import RxSwift
import RxCocoa
import RealmSwift
import RxRealm
import AlamofireImage
import Kingfisher
import RxKingfisher

struct Cache {

  static let config: Realm.Configuration =
    Realm.Configuration(
      // clear cache on schema conflict
      deleteRealmIfMigrationNeeded: true)

  var realm: Realm {
    return try! Realm(configuration: Cache.config)
  }

  func replaceCategories(_ newObjects: [CategoryObject]) throws -> Void {
    try realm.write {
      let oldObjects = realm.objects(CategoryObject.self)
      realm.delete(oldObjects)
      realm.add(newObjects, update: true)
    }
  }

  var guides$: Observable<[Category]> {
    let query = realm.objects(CategoryObject.self).filter("isCuisine = false")
    return
      Observable.array(from: query, synchronousStart: true)
        .map({ return $0.map({ Category($0) }) })
        .share()
  }

  func loadImages$(_ urls: [URL]) -> Observable<[Image]> {
    let images$ = urls.map {
      KingfisherManager.shared.rx.retrieveImage(with: $0).asObservable()
    }
    return
      Observable
        .zip(images$)
        .observeOn(Scheduler.background)
  }

}
