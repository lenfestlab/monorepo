import UIKit
import RxSwift
import RxCocoa
import AlamofireImage
import RxRealm
import DifferenceKit

class GuideGroupViewController: UITableViewController, Contextual {

  var context: Context

  private let guideGroups$: Observable<[GuideGroup]>
  private var guideGroups: [GuideGroup] = []

  init(context: Context) {
    self.context = context
    self.guideGroups$ = context.cache.guideGroups$

    super.init(nibName: nil, bundle: nil)
    navigationItem.hidesBackButton = true
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    let nib = UINib.init(nibName: "GuideGroupCell", bundle: nil)
    self.tableView.register(nib, forCellReuseIdentifier: "reuseIdentifier")
    self.navigationController?.styleController()
    self.navigationItem.title = "Guides"
    self.tableView.separatorStyle = .none
    self.tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 15, right: 0);

    guideGroups$
      .map({ [weak self] newGuideGroups -> StagedChangeset<[GuideGroup]> in
        return StagedChangeset(source: (self?.guideGroups ?? []), target: newGuideGroups)
      })
      .bind(onNext: { [weak self] changeset in
        guard let `self` = self else { return }
        self.tableView.reload(using: changeset, with: .fade, setData: { guideGroups in
          self.guideGroups = guideGroups
        })
      })
      .disposed(by: rx.disposeBag)
  }


  // MARK: - Table view data source

  override func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }

  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return guideGroups.count
  }

  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath) as! GuideGroupCell
    let guideGroup = guideGroups[indexPath.row]
    cell.setGuideGroup(guideGroup: guideGroup)
    cell.navigationController = self.navigationController
    cell.context = context
    return cell
  }

}
