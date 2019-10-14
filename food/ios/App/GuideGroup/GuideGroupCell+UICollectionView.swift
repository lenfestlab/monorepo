import UIKit

let guideCollectionCellSize = CGSize(width: 170, height: 216)

extension GuideGroupCell {

  func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
    guard let context = context, let collectionView = self.collectionView else {
      return
    }


    if self.numberOfGuides() == 1, let guide = self.guideGroup?.guides.first {
      let itemWidth = collectionView.collectionViewFlowLayout.itemSize.width
      let snapToIndex = collectionView.indexOfMajorCell(itemWidth: itemWidth)
      let place:Place = guide.places[snapToIndex]
      context.analytics.log(.swipesCarousel(place: place))
      return
    }

    let itemWidth = guideCollectionCellSize.width
    let snapToIndex = collectionView.indexOfMajorCell(itemWidth: itemWidth)
    if let category = self.guideGroup?.guides[snapToIndex] {
      context.analytics.log(.swipesGuideGroupCarousel(guide: category))
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
      if self.numberOfGuides() == 1, let guide = self.guideGroup?.guides.first {
        let place:Place = guide.places[indexPath.row]
        context.analytics.log(.tapsOnCard(place: place, controllerIdentifierKey: self.controllerIdentifierKey, nil))
        let detailViewController = DetailViewController(context: context, place: place)
        navigationController?.pushViewController(detailViewController, animated: true)
        return true
      }

      if let category = self.guideGroup?.guides[indexPath.row] {
        context.analytics.log(.tapsOnGuideCell(category: category))
        openGuide(context: context, guide: category)
        return true
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
      return CGSize(width: width, height: 234)
    }
    return guideCollectionCellSize
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

