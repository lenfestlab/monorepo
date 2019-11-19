import UIKit

let guideCollectionCellSize = CGSize(width: 170, height: 236)

extension GuideGroupCell {

  func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
    self.collectionView.contentInset = UIEdgeInsets.zero
    
    guard let context = context, let collectionView = self.collectionView else {
      return
    }


    if self.numberOfGuides() == 1, let guide = self.guides.first {
      let itemWidth = collectionView.collectionViewFlowLayout.itemSize.width
      let snapToIndex = collectionView.indexOfMajorCell(itemWidth: itemWidth)
      let place:Place = guide.nearestPlaces[snapToIndex]
      context.analytics.log(.swipesCarousel(place: place))
      return
    }

    let itemWidth = guideCollectionCellSize.width
    let snapToIndex = collectionView.indexOfMajorCell(itemWidth: itemWidth)
    let guide = guides[snapToIndex]
    if let guideGroup = self.guideGroup {
      context.analytics.log(.swipesGuideGroupCarousel(guideGroup: guideGroup, guide: guide))
    }
  }

}

extension GuideGroupCell: UICollectionViewDelegate {

  func openGuide(context: Context, guide: Category) {
    let placeController = GuideViewController(context: context, category: guide)
    placeController.title = guide.name
    placeController.topBarIsHidden = true
    self.navigationController?.pushViewController(placeController, animated: true)
  }

  func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {

    if let context = context {
      if self.numberOfGuides() == 1, let guide = self.guides.first {
        let place:Place = guide.nearestPlaces[indexPath.row]
        context.analytics.log(.tapsOnCard(place: place, controllerIdentifierKey: self.controllerIdentifierKey, nil))
        let detailViewController = DetailViewController(context: context, place: place)
        navigationController?.pushViewController(detailViewController, animated: true)
        return true
      }

      let category = self.guides[indexPath.row]
      context.analytics.log(.tapsOnGuideCell(category: category))
      openGuide(context: context, guide: category)
      return true
    }

    return true
  }

}

extension GuideGroupCell: UICollectionViewDelegateFlowLayout {

  func itemSize() -> CGSize {
    if self.guideGroup?.guidesCount == 1 {
      return CGSize(width: 320, height: 234)
    }
    return guideCollectionCellSize
  }

  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    return self.itemSize()
  }
}

extension GuideGroupCell: UICollectionViewDataSource {

  func numberOfGuides() -> Int? {
    return self.guides.count
  }

  func numberOfSections(in collectionView: UICollectionView) -> Int {
    return 1
  }

  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    if self.guides.count == 1, let guide = self.guides.first {
      return guide.places.count
    }
    return self.guides.count
  }

  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    if self.numberOfGuides() == 1, let guide = self.guides.first, let context = context {
      let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PlaceCell.reuseIdentifier, for: indexPath) as! PlaceCell
      let sortedPlaces = guide.nearestPlaces
      let place: Place = sortedPlaces[indexPath.row]
      cell.setPlace(context: context, place: place, index: indexPath.row, showIndex: self.showIndex)
      return cell
    }

    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: GuideCollectionCell.reuseIdentifier, for: indexPath) as! GuideCollectionCell
    let guide = self.guides[indexPath.row]
    cell.setCategory(category: guide)
    return cell
  }
}
