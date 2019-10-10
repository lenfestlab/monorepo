import UIKit

extension GuideGroupCell: UICollectionViewDelegate {

  func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
    if let context = context {
            if collectionView.indexOfMajorCell() == indexPath.row {
              let mapPlace = mapPlaces[indexPath.row]
              let place = mapPlace.place
        //      analytics.log(.tapsOnCard(place: place, controllerIdentifierKey: self.controllerIdentifierKey, locationManager.latestLocation))
              let detailViewController = DetailViewController(context: context, place: place)
              navigationController?.pushViewController(detailViewController, animated: true)
            } else {
              scrollToItem(at: indexPath)
              let mapPlace = mapPlaces[indexPath.row]
              self.currentPlace = mapPlace
            }
    }
    return true
  }

}

extension GuideGroupCell: UICollectionViewDataSource {

  func numberOfSections(in collectionView: UICollectionView) -> Int {
    return 1
  }

  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return mapPlaces.count
  }

  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PlaceCell.reuseIdentifier, for: indexPath) as! PlaceCell

    // Configure the cell
    let mapPlace:MapPlace = mapPlaces[indexPath.row]
    let place = mapPlace.place
    if let context = context {
        cell.setPlace(context: context, place: place, index: indexPath.row, showIndex: self.showIndex)
    }
    return cell
  }
}

