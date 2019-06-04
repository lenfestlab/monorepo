import UIKit
import RxSwift
import RxCocoa
import AlamofireImage
import RxRealm
import DifferenceKit

class GuidesViewController: UITableViewController, Contextual {

  var context: Context

  typealias Guide = Category
  private let guides$: Observable<[Guide]>
  private var guides: [Guide] = []

  init(context: Context) {
    self.context = context
    self.guides$ = context.cache.guides$

    super.init(nibName: nil, bundle: nil)
    navigationItem.hidesBackButton = true

    // eager fetch images
    guides$
      .map({ $0.compactMap({ $0.imageURL }) })
      .observeOn(Scheduler.background)
      .flatMapFirst({ [unowned self] urls -> Observable<[Image]> in
        let loader = UIImageView.af_sharedImageDownloader
        return self.cache.loadImages$(Array(urls), withLoader: loader)
      })
      .subscribe()
      .disposed(by: rx.disposeBag)
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    let nib = UINib.init(nibName: "GuideCell", bundle: nil)
    self.tableView.register(nib, forCellReuseIdentifier: "reuseIdentifier")
    self.navigationController?.styleController()
    self.navigationItem.title = "Guides"
    self.tableView.separatorStyle = .none
    self.tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 15, right: 0);

    guides$
      .map({ [weak self] newGuides -> StagedChangeset<[Guide]> in
        return StagedChangeset(source: (self?.guides ?? []), target: newGuides)
      })
      .bind(onNext: { [weak self] changeset in
        guard let `self` = self else { return }
        self.tableView.reload(using: changeset, with: .fade, setData: { guides in
          self.guides = guides
        })
      })
      .disposed(by: rx.disposeBag)
  }


  // MARK: - Table view data source

  override func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }

  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return guides.count
  }

  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath) as! GuideCell
    let guide = guides[indexPath.row]
    cell.setCategory(category: guide)
    return cell
  }

  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let category = guides[indexPath.row]
    context.analytics.log(.tapsOnGuideCell(category: category))
    let placeController = GuideViewController(context: context, category: category)
    placeController.title = category.name
    placeController.topBarIsHidden = true
    self.navigationController?.pushViewController(placeController, animated: true)
  }

}
