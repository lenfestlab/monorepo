//
//  CategoryViewController.swift
//  App
//
//  Created by Ajay Chainani on 2/13/19.
//

import UIKit

protocol CategoryViewControllerDelegate: class {
  func categoriesUpdated(_ viewController: CategoryViewController, categories: [Category])
}

class CategoryViewController: UITableViewController {

  weak var categoryFilterDelegate: CategoryViewControllerDelegate?

  var categories = [Category]()

  override func viewDidLoad() {
    super.viewDidLoad()

    self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "reuseIdentifier")
    self.tableView.allowsMultipleSelection = true
    self.style()
    self.title = "Filter"
    self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(dismissFilter))
    self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Apply", style: .plain, target: self, action: #selector(applyFilter))
    self.view.backgroundColor = UIColor.beige()

    let store = CategoryDataStore()
    store.retrieveCategories { (success, categories, count) in
      if let categories = categories {
        self.categories = categories
      }
    }
  }

  @objc func dismissFilter() {
    self.dismiss(animated: true, completion: nil)
  }

  @objc func applyFilter() {
    var selectedCategories = [Category]()

    for indexPath in self.tableView?.indexPathsForSelectedRows ?? [] {
      let category = self.categories[indexPath.row]
      selectedCategories.append(category)
    }

    self.categoryFilterDelegate?.categoriesUpdated(self, categories: selectedCategories)
  }
  // MARK: - Table view data source

  override func numberOfSections(in tableView: UITableView) -> Int {
    // #warning Incomplete implementation, return the number of sections
    return 1
  }

  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    // #warning Incomplete implementation, return the number of rows
    return self.categories.count
  }

   override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
   let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

    let category = self.categories[indexPath.row]

    let selected = tableView.indexPathsForSelectedRows?.contains(indexPath) ?? false

   // Configure the cell...
    cell.textLabel?.text = category.name
    cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 15)
    cell.selectionStyle = .none
    cell.accessoryType  = selected ? .checkmark : .none
    return cell
   }

  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let cell = tableView.cellForRow(at: indexPath)
    cell?.accessoryType  = .checkmark
  }

  override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
    let cell = tableView.cellForRow(at: indexPath)
    cell?.accessoryType  = .none
  }

  /*
   // Override to support conditional editing of the table view.
   override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
   // Return false if you do not want the specified item to be editable.
   return true
   }
   */

  /*
   // Override to support editing the table view.
   override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
   if editingStyle == .delete {
   // Delete the row from the data source
   tableView.deleteRows(at: [indexPath], with: .fade)
   } else if editingStyle == .insert {
   // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
   }
   }
   */

  /*
   // Override to support rearranging the table view.
   override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

   }
   */

  /*
   // Override to support conditional rearranging of the table view.
   override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
   // Return false if you do not want the item to be re-orderable.
   return true
   }
   */

  /*
   // MARK: - Navigation

   // In a storyboard-based application, you will often want to do a little preparation before navigation
   override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
   // Get the new view controller using segue.destination.
   // Pass the selected object to the new view controller.
   }
   */

}
