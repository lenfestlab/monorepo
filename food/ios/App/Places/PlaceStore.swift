import Foundation
import UIKit
import CoreLocation
import RxSwift
import RxRelay
import RxRealm

let concurrentPlaceQueue = DispatchQueue(label: "org.lenfestlab.food.placeQueue", attributes: .concurrent)

@objc protocol PlaceStoreDelegate: class {
  func didSetPlaceFiltered()
  func filterText() -> String?
  func fetchedMapData()
}

let reuseIdentifier = "PlaceCell"

class PlaceStore: NSObject, Contextual {

  var context: Context
  let target: Api.Target

  private let mapPlaces$ = BehaviorRelay<[MapPlace]>(value: [])
  private var mapPlaces: [MapPlace] {
    return mapPlaces$.value
  }

  init(target: Api.Target, context: Context) {
    self.context = context
    self.target = target
    super.init()
  }

  func beginObservingCache() {
    guard case .placesBookmarked = target else { return }
    cache.observePlaces$(.bookmarked)
      .map({ $0.map { MapPlace(place: $0) } })
      .subscribe(onNext: { [unowned self] mapPlaces in
        self.mapPlaces$.accept(mapPlaces)
        self.updateFilter(searchText: self.delegate?.filterText())
        self.delegate?.fetchedMapData()
      })
      .disposed(by: rx.disposeBag)
  }

  var lastCoordinateUsed : CLLocationCoordinate2D?

  var loading = false

  var filterModule = FilterModule()

  weak var delegate: PlaceStoreDelegate?

  private var unsafePlaces = [MapPlace]()

  var placesFiltered: [MapPlace] {
    var placesFilteredCopy: [MapPlace]!
    concurrentPlaceQueue.sync {
      placesFilteredCopy = self.unsafePlaces
    }
    return placesFilteredCopy
  }

  func updateFilter(searchText: String?) {
    concurrentPlaceQueue.async(flags: .barrier) { [weak self] in
      guard let self = self else {
        return
      }

      if let searchText = searchText, searchText.count > 0{
        self.unsafePlaces = self.mapPlaces.filter {
          if let title = $0.place.name?.lowercased() {
            if title.contains(searchText.lowercased()) {
              return true
            }
          }
          return false
        }
      } else {
        self.unsafePlaces = self.mapPlaces
      }

      DispatchQueue.main.async { [weak self] in
        self?.delegate?.didSetPlaceFiltered()
      }
    }
  }

  func refresh(completionBlock: (([MapPlace]) -> (Void))? = nil) {
    guard !self.loading else {
      completionBlock?([])
      return
    }

    guard let coordinate = self.lastCoordinateUsed else {
      completionBlock?([])
      return
    }

    self.loading = true

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
      .observeOn(Scheduler.main)
      .map({ $0.map { MapPlace(place: $0) } })
      .subscribe(onNext: { [weak self] mapPlaces in
        guard let `self` = self else { return }
        self.mapPlaces$.accept(mapPlaces)
        self.updateFilter(searchText: self.delegate?.filterText())
        self.delegate?.fetchedMapData()
        self.loading = false
        completionBlock?(mapPlaces)
      })
      .disposed(by: rx.disposeBag)
  }

}
