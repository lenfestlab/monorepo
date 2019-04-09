import Foundation
import UIKit
import CoreLocation
import SVProgressHUD

private let concurrentPlaceQueue = DispatchQueue(label: "org.lenfestlab.food.placeQueue", attributes: .concurrent)

protocol PlaceStoreDelegate: class {
  func didSetPlaceFiltered()
  func filterText() -> String?
  func fetchedMapData()
}

let reuseIdentifier = "PlaceCell"

class PlaceStore: NSObject {

  var lastCoordinateUsed : CLLocationCoordinate2D?
  var path : String?

  var loading = false

  var filterModule = FilterModule()

  weak var delegate: PlaceStoreDelegate?

  private var unsafePlaces = [MapPlace]()

  private var places:[MapPlace] = [MapPlace]()
  {
    didSet
    {
      self.updateFilter(searchText: self.delegate?.filterText())
    }
  }

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
        self.unsafePlaces = self.places.filter {
          if let title = $0.place.name?.lowercased() {
            if title.contains(searchText.lowercased()) {
              return true
            }
          }
          return false
        }
      } else {
        self.unsafePlaces = self.places
      }

      DispatchQueue.main.async { [weak self] in
        self?.delegate?.didSetPlaceFiltered()
      }
    }
  }

  func fetchMapData(path: String, showLoadingIndicator: Bool, coordinate:CLLocationCoordinate2D, completionBlock: (() -> (Void))? = nil) {
    self.path = path
    self.lastCoordinateUsed = coordinate
    refresh(showLoadingIndicator: showLoadingIndicator, completionBlock: completionBlock)
  }

  func refresh(showLoadingIndicator: Bool, completionBlock: (() -> (Void))? = nil) {
    guard !self.loading else {
      completionBlock?()
      return
    }

    guard let path = self.path else {
      completionBlock?()
      return
    }

    guard let coordinate = self.lastCoordinateUsed else {
      completionBlock?()
      return
    }

    if showLoadingIndicator {
      SVProgressHUD.show()
      SVProgressHUD.setForegroundColor(UIColor.slate)
    }

    self.loading = true

    PlaceDataStore.retrieve(
      path: path,
      coordinate: coordinate,
      prices: self.filterModule.prices,
      ratings: self.filterModule.ratings,
      categories: self.filterModule.categories,
      neigborhoods: self.filterModule.nabes,
      authors: self.filterModule.authors,
      sort: self.filterModule.sortMode,
      limit: 1000) { (success, data, count) in
      var places = [MapPlace]()
      for place in data {
        places.append(MapPlace(place: place))
      }
      self.places = places

      self.loading = false

      self.delegate?.fetchedMapData()
      completionBlock?()

      if showLoadingIndicator {
        DispatchQueue.main.async {
          if places.count == 0 {
            SVProgressHUD.showError(withStatus: "No Results Found")
          } else {
            SVProgressHUD.dismiss()
          }
        }
      }
    }
  }

}
