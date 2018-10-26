import UIKit
import CoreLocation
import UserNotifications
import Alamofire

protocol NotificationManagerDelegate: class {
  func receivedNotification(_ notificationManager: NotificationManager, response: UNNotificationResponse)
  func receivedPingMeLater(_ notificationManager: NotificationManager, identifier: String)
}

class NotificationManager: NSObject, UNUserNotificationCenterDelegate {

  static let shared = NotificationManager()

  var identifiers:[String: Date]

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
    var identifiers = UserDefaults.standard.dictionary(forKey: "received-notification-identifiers") as? [String: Date]
    if identifiers == nil {
      identifiers = [:]
    }
    self.identifiers = identifiers!

    super.init()
    notificationCenter = UNUserNotificationCenter.current()
    notificationCenter?.delegate = self
    refreshAuthorizationStatus { (status) in }
    setCategories()
  }

  func setCategories(){
    let laterAction = UNNotificationAction(identifier: "later", title: "Ping Me Later", options: [])
    let shareAction = UNNotificationAction(identifier: "share", title: "Share", options: [.foreground])
    let alarmCategory = UNNotificationCategory(identifier: "POST_ENTERED", actions: [laterAction, shareAction], intentIdentifiers: [], options: [])
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
    print("notificationmanager userNotificationCenter willPresent: \(notification) withCompletionHandler")
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
        delegate?.receivedPingMeLater(self, identifier: identifier)
      }
    } else {
      delegate?.receivedNotification(self, response: response)
    }

    completionHandler()
  }

  func saveIdentifiers(_ identifiers: [String : Date]) {
    UserDefaults.standard.set(identifiers, forKey: "received-notification-identifiers")
    self.identifiers = identifiers
  }


}
