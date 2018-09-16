//
//  SettingsViewController.swift
//  App
//
//  Created by Ajay Chainani on 9/14/18.
//

import UIKit

class SettingsViewController: UITableViewController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.title = "Settings"
    self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(title: "Done", style: .plain, target: self, action: #selector(dismissViewController))

    // Uncomment the following line to preserve selection between presentations
    // self.clearsSelectionOnViewWillAppear = false
    
    tableView.rowHeight = UITableViewAutomaticDimension
    tableView.estimatedRowHeight = 125
    let nib = UINib.init(nibName: "SettingsToggleCell", bundle: nil)
    tableView.register(nib, forCellReuseIdentifier: "reuseIdentifier")
    tableView.allowsSelection = false

    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem
  }
  
  @objc func dismissViewController() {
    dismiss(animated: true, completion: nil)
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  // MARK: - Table view data source
  
  override func numberOfSections(in tableView: UITableView) -> Int {
    return 2
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 1
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell:SettingsToggleCell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath) as! SettingsToggleCell
    
    if indexPath.section == 0 {
      cell.titleLabel.text = "Enable Notifications"
      cell.descriptionLabel.text = "This App uses push notifications to send you related articles based on where you are."
    } else {
      cell.titleLabel.text = "Access Location"
      cell.descriptionLabel.text = "This App serves best with access to your location. Map and notification features uses your location to display and send content from your nearby locations."
    }
    return cell
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
   // Get the new view controller using segue.destinationViewController.
   // Pass the selected object to the new view controller.
   }
   */
  
}
