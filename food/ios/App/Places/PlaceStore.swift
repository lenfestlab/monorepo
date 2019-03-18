import Foundation
import UIKit
import CoreLocation

protocol PlaceStoreDelegate: class {
  func didSetPlaceFiltered()
  func filterText() -> String?
  func fetchedMapData()
}

let reuseIdentifier = "PlaceCell"

class FilterModule : NSObject {
  var ratings = [Int]()
  var prices = [Int]()
  var categories = [Category]()
  var nabes = [Neighborhood]()
  var authors = [Author]()
  var sortMode : SortMode = .distance
}

class PlaceStore: NSObject {

  var filterModule = FilterModule()

  weak var delegate: PlaceStoreDelegate?

  var placesFiltered = [MapPlace]()
  {
    didSet
    {
      self.delegate?.didSetPlaceFiltered()
    }
  }

  var places:[MapPlace] = [MapPlace]()
  {
    didSet
    {
      self.updateFilter(searchText: self.delegate?.filterText())
    }
  }

  func updateFilter(searchText: String?) {
    if let searchText = searchText, searchText.count > 0{
      placesFiltered = self.places.filter {
        if let title = $0.place.name?.lowercased() {
          if title.contains(searchText.lowercased()) {
            return true
          }
        }
        return false
      }
    } else {
      placesFiltered = self.places
    }
  }

  func fetchMapData(coordinate:CLLocationCoordinate2D, completionBlock: (() -> (Void))? = nil) {
    PlaceDataStore.retrieve(coordinate: coordinate,
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

      self.delegate?.fetchedMapData()
      completionBlock?()
    }
  }

}
