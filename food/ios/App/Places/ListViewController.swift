import UIKit
import CoreLocation

extension ListViewController { // UICollectionViewDataSource

  override func numberOfSections(in collectionView: UICollectionView) -> Int {
    return 1
  }

  override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return self.placeStore.placesFiltered.count
  }

  override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! PlaceCell

    // Configure the cell
    let mapPlace:MapPlace = self.placeStore.placesFiltered[indexPath.row]
    let place = mapPlace.place
    cell.setPlace(place: place, index: indexPath.row, showIndex: self.showIndex)
    return cell
  }

}

extension ListViewController { // UICollectionViewDelegate

  override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
    let mapPlace:MapPlace = self.placeStore.placesFiltered[indexPath.row]
    let place:Place = mapPlace.place
    analytics.log(.tapsOnViewArticle(post: place.post, currentLocation: self.locationManager.latestCoordinate))
    openPlace(place)
    return true
  }

  func openPlace(_ place: Place) {
    let detailViewController = DetailViewController(place: place)
    self.navigationController?.pushViewController(detailViewController, animated: true)
  }


}

extension ListViewController: UICollectionViewDelegateFlowLayout {

  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    let screenSize = UIScreen.main.bounds
    let screenWidth = screenSize.width - 2*padding
    return CGSize(width: screenWidth, height: 250)
  }

}

class ListViewController: UICollectionViewController {

  let placeStore : PlaceStore!
  let locationManager = LocationManager.shared
  let padding = CGFloat(10)
  var topPadding = CGFloat(64)

  var showIndex = false {
    didSet {
      self.collectionView.reloadData()
    }
  }

  private let analytics: AnalyticsManager
  @IBOutlet weak var settingsButton:UIButton!

  init(analytics: AnalyticsManager, placeStore: PlaceStore, categories: [Category] = []) {
    self.analytics = analytics
    self.placeStore = placeStore

    let layout = UICollectionViewFlowLayout()
    super.init(collectionViewLayout: layout)
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    self.navigationController?.styleController()

    let nib = UINib(nibName: "PlaceCell", bundle:nil)
    self.collectionView.register(nib, forCellWithReuseIdentifier: reuseIdentifier)
    self.collectionView.backgroundColor = UIColor.white
  }

  func fetchedMapData() {
    self.collectionView.contentOffset = CGPoint.zero
    self.collectionView.reloadData()
  }

  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
    return UIEdgeInsets(top: self.topPadding, left: 0, bottom: 0, right: 0)
  }

}
