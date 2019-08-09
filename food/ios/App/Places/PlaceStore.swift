import Foundation
import UIKit
import CoreLocation
import RxSwift
import RxRelay
import RxRealm
import DifferenceKit

typealias PlacesChangeset = StagedChangeset<[Place]>
typealias PlacesChangesetClosure = ((_ places: [Place]) -> Void)

protocol PlaceStoreDelegate: class {
  func didSetPlaceFiltered()
  func filterText() -> String?
  func fetchedData(_ changeset: PlacesChangeset, _ setData: PlacesChangesetClosure)
}

class PlaceStore: NSObject, Contextual {

  var context: Context
  let target: Api.Target

  private let places$$ = PublishRelay<[Place]>()
  lazy var places$ = { () -> Observable<[Place]> in
    return places$$
      .asObservable()
      .share()
  }()
  var places: [Place] = [] // maintained by DifferenceKit setData closure

  typealias SearchString = String?
  private let searchText$$ = BehaviorRelay<SearchString>(value: nil)
  lazy var searchText$ = { () -> Observable<SearchString> in
    return searchText$$
      .asObservable()
      .distinctUntilChanged()
      .share()
  }()

  init(target: Api.Target, context: Context) {
    self.context = context
    self.target = target
    super.init()
  }

  func beginObservingPlaces() {
    let placesCached$: Observable<[Place]>
    switch target {
    case .placesAll:
      placesCached$ =
        Observable.combineLatest(
          locationManager.latestOrDefaultLocation$,
          cache.defaultPlaces$)
          .map({ [weak self] (location, places) -> [Place] in
            // sort first set of places using best-available location
            guard
              let `self` = self,
              let currentLocation = self.locationManager.latestLocation
              else { return places }
            return places.sorted(by: { (p1, p2) -> Bool in
              guard
                let l1 = p1.nativeLocation,
                let l2 = p2.nativeLocation
                else { return false }
              let d1 = currentLocation.distance(from: l1)
              let d2 = currentLocation.distance(from: l2)
              return d1 <= d2
            })
          })
        .take(1)
    case .placesCategorizedIn(let identifier):
      placesCached$ = cache.observePlaces$(.category(identifier))
    case .placesBookmarked:
      placesCached$ = cache.bookmarkedPlaces$
    }

    Observable.combineLatest(
      searchText$,
      Observable.concat(
        placesCached$,
        places$)
      )
      .map({ (searchText, places) -> [Place] in
        guard let searchText = searchText, searchText.isNotEmpty
          else { return places }
        return places.filter({
          let lowered = searchText.lowercased().replacingOccurrences(of: "’", with: "")
          guard let title = $0.title?.lowercased().replacingOccurrences(of: "’", with: "") else { return false }
          if title.folding(options: .diacriticInsensitive, locale: .current).contains(lowered) {
            return true
          }
          if title.contains(lowered) {
            return true
          }
          return false
        })
      })
      // calculate collection changes from prior render
      .map({ [unowned self] newPlaces -> StagedChangeset<[Place]> in
        return StagedChangeset(source: self.places, target: newPlaces)
      })
      .subscribe(onNext: { [unowned self] changeset in
        self.delegate?.fetchedData(changeset, { [unowned self] latestPlaces in
          self.places = latestPlaces
        })
      })
      .disposed(by: rx.disposeBag)
  }

  var loading = false

  var filterModule = FilterModule()

  weak var delegate: PlaceStoreDelegate?

  func updateFilter(searchText: String?) {
    self.searchText$$.accept(searchText)
    self.delegate?.didSetPlaceFiltered()
  }

  func refresh(completionBlock: (([Place]) -> (Void))? = nil) {
    guard !self.loading else {
      completionBlock?([])
      return
    }
    self.loading = true

    let coordinate: CLLocationCoordinate2D =
      locationManager.latestCoordinate ??
        locationManager.defaultLocation.coordinate

    self.api.getPlaces$(
      target: self.target,
      lat: coordinate.latitude,
      lng: coordinate.longitude,
      prices: self.filterModule.prices,
      ratings: self.filterModule.ratings,
      categories: self.filterModule.categories,
      neigborhoods: self.filterModule.nabes,
      authors: self.filterModule.authors,
      sort: self.filterModule.sortMode,
      limit: 1000)
      .subscribe(onNext: { [weak self] places in
        guard let `self` = self else { return }
        self.places$$.accept(places)
        self.updateFilter(searchText: self.delegate?.filterText())
        self.loading = false
        completionBlock?(places)
      })
      .disposed(by: rx.disposeBag)
  }

}
