import UIKit
import RxSwift
import RxCocoa

class GuidesViewController: UITableViewController {

  private let context: Context
  private let bag = DisposeBag()
  private var categories$ = BehaviorRelay<[Category]>(value: [])
  private var categories: [Category] {
    return categories$.value
  }
  typealias Guide = Category
  private let guides$: Driver<[Guide]>

  init(context: Context) {
    self.context = context
    self.guides$ =
      self.context.cache.guides$
        .asDriver(onErrorJustReturn: [])

    super.init(nibName: nil, bundle: nil)
    navigationItem.hidesBackButton = true
    // kick off fetch immediately
    self.context.api.refreshCategories$.subscribe().disposed(by: bag)
    // bind to cache
    guides$.drive(categories$).disposed(by: bag)
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

    // reload table on cache changes
    self.guides$.drive(onNext: { [weak self] _ in
        self?.tableView.reloadData()
      })
      .disposed(by: bag)
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
