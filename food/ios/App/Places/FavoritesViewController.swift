import UIKit

class FavoritesViewController: PlacesViewController {

  init(context: Context) {
    super.init(target: .placesBookmarked, context: context)
    loadViewIfNeeded()
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    self.listViewController.controllerIdentifierKey = "my-list"
    self.mapViewController.controllerIdentifierKey = "my-list"

    self.title = "My List"

    self.topBarIsHidden = true

    self.view.addSubview(self.emptyView)
  }

  lazy var emptyView : EmptyView = {
    let view = EmptyView()
    view.emptyImageView.image = UIImage(named: "no-favorites")
    view.emptyTitleLabel.text = "Your plate is empty!"
    view.clearButton.isHidden = true
    view.backgroundColor = .white
    return view
  }()

  override func viewWillLayoutSubviews() {
    super.viewWillLayoutSubviews()

    self.emptyView.frame = self.view.bounds
  }

  override func fetchedData(_ changeset: PlacesChangeset, _ setData: PlacesChangesetClosure) {
    super.fetchedData(changeset, setData)
    self.emptyView.isHidden = !isEmpty()
  }

}
