import UIKit
import CoreLocation
import UserNotifications
import Alamofire

protocol NotificationManagerDelegate: class {
  func recievedNotification(_ notificationManager: NotificationManager, response: UNNotificationResponse)
  func recievedPingMeLater(_ notificationManager: NotificationManager, identifier: String)
}

class NotificationManager: NSObject, UNUserNotificationCenterDelegate {

  static let shared = NotificationManager()

  weak var delegate: NotificationManagerDelegate?
  var notificationCenter:UNUserNotificationCenter?
  var authorizationStatus:UNAuthorizationStatus = .notDetermined
  
  func refreshAuthorizationStatus(completionHandler: @escaping (UNAuthorizationStatus) -> Void) {
    notificationCenter?.getNotificationSettings { (settings) in
      print("Checking notification status")
      self.authorizationStatus = settings.authorizationStatus
      completionHandler(settings.authorizationStatus)
    }
  }
  
  override init() {
    super.init()
    notificationCenter = UNUserNotificationCenter.current()
    notificationCenter?.delegate = self
    refreshAuthorizationStatus { (status) in }
    setCategories()
  }
  
  func setCategories(){
    let laterAction = UNNotificationAction(identifier: "later", title: "Ping Me Later", options: [])
    let alarmCategory = UNNotificationCategory(identifier: "POST_ENTERED", actions: [laterAction], intentIdentifiers: [], options: [])
    UNUserNotificationCenter.current().setNotificationCategories([alarmCategory])
  }

  func requestAuthorization(completionHandler: @escaping (UNAuthorizationStatus, Error?) -> Void){
    let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
    UNUserNotificationCenter.current().requestAuthorization(options: authOptions) { (granted, error) in
      self.refreshAuthorizationStatus(completionHandler: { (status) in
        if granted {
          print("NotificationCenter Authorization Granted!")
        }
        completionHandler(status, error)
      })
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
        var identifiers = NotificationManager.identifiers()
        identifiers[identifier] = Date(timeIntervalSinceNow: 60 * 60 * 24)
        NotificationManager.saveIdentifiers(identifiers)
        delegate?.recievedPingMeLater(self, identifier: identifier)
      }
    } else {
      delegate?.recievedNotification(self, response: response)
    }
    
    completionHandler()
  }

  class func identifiers() -> [String: Date] {
    var identifiers = UserDefaults.standard.dictionary(forKey: "recieved-notification-identifiers") as? [String: Date]
    if identifiers == nil {
      identifiers = [:]
    }
    return identifiers!
  }
  
  class func saveIdentifiers(_ identifiers: [String : Date]) {
    UserDefaults.standard.set(identifiers, forKey: "recieved-notification-identifiers")
  }

  
}
