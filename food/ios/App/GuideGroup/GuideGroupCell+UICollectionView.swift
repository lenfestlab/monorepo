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

extension GuideGroupCell: UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    return CGSize(width: 160, height: 206)
  }
}

extension GuideGroupCell: UICollectionViewDataSource {

  func numberOfSections(in collectionView: UICollectionView) -> Int {
    return 1
  }

  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    if self.guideGroup?.guides.count == 1, let guide = self.guideGroup?.guides.first {
      return guide.places.count 
    }
    return self.guideGroup?.guides.count ?? 0
  }

  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    if self.guideGroup?.guides.count == 1, let guide = self.guideGroup?.guides.first, let context = context {
      let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PlaceCell.reuseIdentifier, for: indexPath) as! PlaceCell
      let place:Place = guide.places[indexPath.row]
      cell.setPlace(context: context, place: place, index: indexPath.row, showIndex: self.showIndex)
      return cell
    }

    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: GuideCollectionCell.reuseIdentifier, for: indexPath) as! GuideCollectionCell
    if let guide = self.guideGroup?.guides[indexPath.row] {
      cell.setCategory(category: guide)
    }
    return cell
  }
}

