import UIKit

extension UICollectionView {

  var collectionViewFlowLayout: UICollectionViewFlowLayout {
    return self.collectionViewLayout as! UICollectionViewFlowLayout
  }

  func indexOfMajorCell() -> Int {
    let itemWidth = self.collectionViewFlowLayout.itemSize.width
    let offset = self.collectionViewFlowLayout.collectionView!.contentOffset.x
    let proportionalOffset = offset / itemWidth
    let index = Int(round(proportionalOffset))
    let numberOfItems = self.numberOfItems(inSection: 0)
    let safeIndex = max(0, min(numberOfItems - 1, index))
    return safeIndex
  }

}

extension MapViewController: UICollectionViewDelegate {

  func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
    if collectionView.indexOfMajorCell() == indexPath.row {
      let mapPlace = mapPlaces[indexPath.row]
      let place = mapPlace.place
      analytics.log(.tapsOnCard(place: place, controllerIdentifierKey: self.controllerIdentifierKey))
      let detailViewController = DetailViewController(context: context, place: place)
      navigationController?.pushViewController(detailViewController, animated: true)
    } else {
      scrollToItem(at: indexPath)
      let mapPlace = mapPlaces[indexPath.row]
      self.currentPlace = mapPlace
    }
    return true
  }

}

extension MapViewController: UICollectionViewDataSource {

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
    cell.setPlace(context: context, place: place, index: indexPath.row, showIndex: self.showIndex)
    return cell
  }
}

