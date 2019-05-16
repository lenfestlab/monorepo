import UIKit
import CoreLocation

let placeCellPadding : CGFloat = 35

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
    cell.setPlace(context: context, place: place, index: indexPath.row, showIndex: self.showIndex)
    cell.analytics = self.analytics
    cell.controllerIdentifierKey = self.controllerIdentifierKey
    return cell
  }

}

extension ListViewController { // UICollectionViewDelegate

  override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
    let mapPlace:MapPlace = self.placeStore.placesFiltered[indexPath.row]
    let place:Place = mapPlace.place
    analytics.log(.tapsOnCard(place: place, controllerIdentifierKey: self.controllerIdentifierKey))
    openPlace(place)
    return true
  }

  func openPlace(_ place: Place) {
    let detailViewController =
      DetailViewController(
        context: context,
        place: place)
    self.navigationController?.pushViewController(detailViewController, animated: true)
  }


}

extension ListViewController: UICollectionViewDelegateFlowLayout {

  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    let screenSize = UIScreen.main.bounds
    let screenWidth = screenSize.width - 2*placeCellPadding
    return CGSize(width: screenWidth, height: 240)
  }

}

class ListViewController: UICollectionViewController {

  var controllerIdentifierKey = "unknown"

  let placeStore : PlaceStore!
  let locationManager = LocationManager.shared
  var topPadding = CGFloat(64)

  var showIndex = false {
    didSet {
      self.collectionView.reloadData()
    }
  }

  private let context: Context
  private let analytics: AnalyticsManager
  @IBOutlet weak var settingsButton:UIButton!

  init(context: Context, placeStore: PlaceStore, categories: [Category] = []) {
    self.context = context
    self.analytics = context.analytics
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
