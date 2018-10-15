import UIKit
import CoreLocation
import UserNotifications
import Alamofire

protocol NotificationManagerDelegate: class {
  func recievedNotification(_ notificationManager: NotificationManager, response: UNNotificationResponse)
}

class NotificationManager: NSObject, UNUserNotificationCenterDelegate {

  static let shared = NotificationManager()

  var identifiers:[String: Date]

  weak var delegate: NotificationManagerDelegate?
  var notificationCenter:UNUserNotificationCenter?
  var authorizationStatus:UNAuthorizationStatus = .notDetermined
  
  func refreshAuthorizationStatus(completionHandler: @escaping () -> Void) {
    notificationCenter?.getNotificationSettings { (settings) in
      print("Checking notification status")
      self.authorizationStatus = settings.authorizationStatus
      completionHandler()
    }
  }
  
  override init() {
    var identifiers = UserDefaults.standard.dictionary(forKey: "recieved-notification-identifiers") as? [String: Date]
    if identifiers == nil {
      identifiers = [:]
    }
    self.identifiers = identifiers!

    super.init()
    notificationCenter = UNUserNotificationCenter.current()
    notificationCenter?.delegate = self
    refreshAuthorizationStatus {}
    setCategories()
  }
  
  func setCategories(){
    let laterAction = UNNotificationAction(identifier: "later", title: "Ping Me Later", options: [])
    let alarmCategory = UNNotificationCategory(identifier: "POST_ENTERED", actions: [laterAction], intentIdentifiers: [], options: [])
    UNUserNotificationCenter.current().setNotificationCategories([alarmCategory])
  }

  func requestAuthorization(completionHandler: @escaping (Bool, Error?) -> Void){
    let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
    UNUserNotificationCenter.current().requestAuthorization(options: authOptions) { (granted, error) in
      self.refreshAuthorizationStatus {
        if granted {
          print("NotificationCenter Authorization Granted!")
        }
        completionHandler(granted,error)
      }
    }
  }
  
  func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
    completionHandler([.alert, .sound])
  }
  
  
  func userNotificationCenter(_ center: UNUserNotificationCenter,
                              didReceive response: UNNotificationResponse,
                              withCompletionHandler completionHandler: @escaping () -> Void) {
    let actionIdentifier = response.actionIdentifier
    if actionIdentifier == "later"{
      if let identifier = response.notification.request.content.userInfo["identifier"] as? String {
        var identifiers = NotificationManager.shared.identifiers
        identifiers[identifier] = Date(timeIntervalSinceNow: 60 * 60 * 24)
        NotificationManager.shared.saveIdentifiers(identifiers)
      }
    } else {
      delegate?.recievedNotification(self, response: response)
    }
    
    completionHandler()
  }
  
  func saveIdentifiers(_ identifiers: [String : Date]) {
    UserDefaults.standard.set(identifiers, forKey: "recieved-notification-identifiers")
    self.identifiers = identifiers
  }

  
}
