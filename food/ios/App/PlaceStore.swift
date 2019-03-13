import Foundation
import UIKit
import CoreLocation

protocol PlaceStoreDelegate: class {
  func didSetPlaceFiltered()
  func filterText() -> String?
  func fetchedMapData()
}

let reuseIdentifier = "PlaceCell"

class PlaceStore: NSObject {

  var ratings = [Int]()
  var prices = [Int]()
  var categories = [Category]()
  var sortMode : SortMode = .distance

  weak var delegate: PlaceStoreDelegate?
  let dataStore = PlaceDataStore()

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
    dataStore.retrievePlaces(coordinate: coordinate, prices: self.prices, ratings: self.ratings, categories: self.categories, sort: self.sortMode, limit: 1000) { (success, data, count) in
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
