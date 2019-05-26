import UIKit
import RxRelay

protocol AuthorViewControllerDelegate: class {
  func authorsUpdated(_ viewController: AuthorViewController, authors: [Author])
}

class AuthorViewController: UITableViewController {

  weak var delegate: AuthorViewControllerDelegate?

  let alphabet = ["A","B","C","D", "E", "F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z"]

  @objc func applyFilter() {
    self.delegate?.authorsUpdated(self, authors: self.selected)
  }

  @IBAction func clearAll() {
    self.delegate?.authorsUpdated(self, authors: [])
  }

  var sorted = [Character : [Author]]()
  var selected = [Author]()
  var context: Context
  private var authors$ = BehaviorRelay<[Author]>(value: [])
  private var authors: [Author] {
    return authors$.value
  }


  init(context: Context, selected: [Author]) {
    self.context = context
    self.selected = selected
    super.init(nibName: nil, bundle: nil)
    navigationItem.hidesBackButton = true
    context.cache.authors$.bind(to: authors$).disposed(by: self.rx.disposeBag)
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    self.tableView.separatorInset = .zero
    self.tableView.allowsMultipleSelection = true
    self.tableView.sectionIndexColor = .lightGreyBlue
    self.tableView.rowHeight = 56

    self.title = "Authors"

    let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
    let clear = UIBarButtonItem(title: "Clear All", style: .plain, target: self, action: #selector(clearAll))
    let apply = UIBarButtonItem(title: "Apply", style: .done, target: self, action: #selector(applyFilter))
    self.toolbarItems = [clear, space, apply]

    self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "reuseIdentifier")
    self.navigationController?.styleController()

    for string in self.alphabet {
      if let character = string.first {
        self.sorted[character] = [Author]()
      }
    }

    self.authors$.asDriver()
      .drive(onNext: { [unowned self] objects in
        var newSorted = [Character : [Author]]()
        self.alphabet.forEach({ str in newSorted[str.first!] = [Author]() })
        objects.sorted(by: { $0.name < $1.name }).forEach({ object in
          if let character = object.name.uppercased().first {
            newSorted[character]?.append(object)
          }
        })
        self.sorted = newSorted
        self.tableView.reloadData()
      }).disposed(by: self.rx.disposeBag)

  }

  // MARK: - Table view data source

  override func numberOfSections(in tableView: UITableView) -> Int {
    return self.alphabet.count
  }

  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if let character = self.alphabet[section].first {
      if let categories = self.sorted[character] {
        return categories.count
      }
    }
    return 0
  }

  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

    if let author = self.authorAtIndexPath(indexPath) {
      cell.textLabel?.text = author.name
    }

    cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 15)
    cell.selectionStyle = .none
    cell.textLabel?.font = UIFont.largeBook

    return cell
  }

  func authorAtIndexPath(_ indexPath: IndexPath) -> Author? {
    if let character = self.alphabet[indexPath.section].first {
      if let authors = self.sorted[character] {
        let author = authors[indexPath.row]
        return author
      }
    }
    return nil
  }

  override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    guard let nabe = self.authorAtIndexPath(indexPath)  else {
      return
    }

    let categoryIds = self.selected.map { $0.identifier }
    let selected = categoryIds.contains(nabe.identifier)
    if selected {
      tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
      cell.accessoryType  = .checkmark
    } else {
      tableView.deselectRow(at: indexPath, animated: false)
      cell.accessoryType  = .none
    }

  }

  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let cell = tableView.cellForRow(at: indexPath)
    cell?.accessoryType  = .checkmark

    if let nabe = self.authorAtIndexPath(indexPath) {
      self.selected.append(nabe)
    }
  }

  override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
    let cell = tableView.cellForRow(at: indexPath)
    cell?.accessoryType  = .none

    if let category = self.authorAtIndexPath(indexPath) {
      let categoryIds = self.selected.map { $0.identifier }
      if let index = categoryIds.firstIndex(of: category.identifier) {
        self.selected.remove(at: index)
      }
    }
  }

}
