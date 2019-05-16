import UIKit
import RxSwift
import RxCocoa
import AlamofireImage
import RxRealm

class GuidesViewController: UITableViewController, Contextual {

  var context: Context

  private var categories$ = BehaviorRelay<[Category]>(value: [])
  private var categories: [Category] {
    return categories$.value
  }
  typealias Guide = Category
  private let guides$: Observable<[Guide]>

  init(context: Context) {
    self.context = context
    self.guides$ = context.cache.categories$(filter: .guide)

    super.init(nibName: nil, bundle: nil)
    navigationItem.hidesBackButton = true

    // bind to cache
    guides$
      .bind(to: categories$)
      .disposed(by: rx.disposeBag)

    guides$
      .flatMapFirst({ [unowned self] guides -> Observable<[Image]> in
        let urls = guides.compactMap({ $0.imageURL })
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

    // NOTE: buffer tableView updates while view visible to avoid thrashing
    let outOfFocus$ =
      Observable.merge([
        rx.methodInvoked(#selector(UIViewController.viewWillAppear(_:))).mapTo(true),
        rx.methodInvoked(#selector(UIViewController.viewDidDisappear(_:))).mapTo(false)
        ])
        .startWith(false)
        .not()
        .share()

    guides$
      .pausableBuffered(outOfFocus$, limit: nil, flushOnCompleted: true, flushOnError: true)
      .do(onNext: { [weak self] _ in
        self?.tableView.reloadData()
      })
      .subscribe()
      .disposed(by: rx.disposeBag)

  }


  // MARK: - Table view data source

  override func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }

  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return self.categories.count
  }

  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath) as! GuideCell

    let category = self.categories[indexPath.row]

    cell.setCategory(category: category)

    return cell
  }

  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let category = self.categories[indexPath.row]
    context.analytics.log(.tapsOnGuideCell(category: category))
    let placeController = GuideViewController(context: context, category: category)
    placeController.additionalSafeAreaInsets.bottom = 49
    placeController.title = category.name
    placeController.topBarIsHidden = true
    placeController.hidesBottomBarWhenPushed = true
    self.navigationController?.pushViewController(placeController, animated: true)
  }

}
