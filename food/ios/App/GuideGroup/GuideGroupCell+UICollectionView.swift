import UIKit

extension GuideGroupCell: UICollectionViewDelegate {

  func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {

    if let context = context {
      if self.numberOfGuides() == 1, let guide = self.guideGroup?.guides.first {
        let place:Place = guide.places[indexPath.row]
        if collectionView.indexOfMajorCell() == indexPath.row {
      //      analytics.log(.tapsOnCard(place: place, controllerIdentifierKey: self.controllerIdentifierKey, locationManager.latestLocation))
          let detailViewController = DetailViewController(context: context, place: place)
          navigationController?.pushViewController(detailViewController, animated: true)
        } else {
          scrollToItem(at: indexPath)
          self.currentPlace = place
        }
        return true
      }

      if let category = self.guideGroup?.guides[indexPath.row] {
    //    context.analytics.log(.tapsOnGuideCell(category: category))
        let placeController = GuideViewController(context: context, category: category)
        placeController.title = category.name
        placeController.topBarIsHidden = true
        self.navigationController?.pushViewController(placeController, animated: true)
      }
    }

    return true
  }

}

extension GuideGroupCell: UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    if self.guideGroup?.guides.count == 1 {
      let padding = placeCellPadding
      let view = collectionView
      let width = view.frame.size.width - 2*padding
      return CGSize(width: width, height: view.frame.size.height)
    }
    return CGSize(width: 160, height: 216)
  }
}

extension GuideGroupCell: UICollectionViewDataSource {

  func numberOfGuides() -> Int? {
    return self.guideGroup?.guides.count
  }

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
    if self.numberOfGuides() == 1, let guide = self.guideGroup?.guides.first, let context = context {
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

