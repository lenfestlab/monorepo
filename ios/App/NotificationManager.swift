import UIKit
import CoreLocation
import UserNotifications
import Alamofire

protocol NotificationManagerDelegate: class {
  func recievedNotification(_ notificationManager: NotificationManager, response: UNNotificationResponse)
}

class NotificationManager: NSObject, UNUserNotificationCenterDelegate {

  static let shared = NotificationManager()

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
    super.init()
    notificationCenter = UNUserNotificationCenter.current()
    notificationCenter?.delegate = self
    refreshAuthorizationStatus {}
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
    delegate?.recievedNotification(self, response: response)
  }

  
}
