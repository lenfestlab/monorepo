//
//  NotificationViewController.swift
//  GRE Tweets
//
//  Created by Ajay Chainani on 8/31/18.
//  Copyright © 2018 Ajay Chainani. All rights reserved.
//

import UIKit
import UserNotifications

class NotificationViewController: UIViewController, UNUserNotificationCenterDelegate {

  @IBOutlet weak var doneButton: UIButton!

  override func viewDidLoad() {
    super.viewDidLoad()
    
    doneButton.layer.cornerRadius = 5.0
    doneButton.clipsToBounds = true
    // Do any additional setup after loading the view.
  }
  
  @IBAction func skip(sender: UIButton) {
    let application = UIApplication.shared
    let appDelegate = application.delegate as? AppDelegate
    appDelegate?.showHomeScreen()
  }

  @IBAction func done(sender: UIButton) {
    let application = UIApplication.shared
    let appDelegate = application.delegate as? AppDelegate
    self.setupRemoteNotifications(application, completionHandler: { (_, _) in
      DispatchQueue.main.async {
//        UserDefaults.standard.set(true, forKey: "onboarding-completed")
        appDelegate?.showHomeScreen()
      }
    })
  }
  
  func setupRemoteNotifications(_ application: UIApplication, completionHandler: @escaping (Bool, Error?) -> Swift.Void) {
    UNUserNotificationCenter.current().delegate = self
    
    let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
    UNUserNotificationCenter.current().requestAuthorization(options: authOptions) { (success, error) in
      completionHandler(success, error)
    }
  }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
