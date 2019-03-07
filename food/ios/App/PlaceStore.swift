import Foundation
import UIKit


protocol PlaceStoreDelegate: class {
  func didSetPlaceFiltered()
  func filterText() -> String?
}

class PlaceStore: NSObject {
  let reuseIdentifier = "PlaceCell"

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

}
