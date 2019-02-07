import UIKit
import CoreLocation
import UserNotifications
import Alamofire

protocol NotificationManagerDelegate: class {
  func present(_ vc: UIViewController, animated: Bool)
  func openInSafari(url: URL)
}

class NotificationManager: NSObject, UNUserNotificationCenterDelegate {

  static let shared = NotificationManager()

  var analytics: AnalyticsManager?

  static func sharedWith(analytics: AnalyticsManager) -> NotificationManager {
    let manager = NotificationManager.shared
    manager.analytics = analytics
    return manager
  }

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
    let alarmCategory =
      UNNotificationCategory(identifier: "POST_ENTERED",
                             actions: [laterAction, shareAction],
                             intentIdentifiers: [],
                             options: [])
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
    let userInfo = response.notification.request.content.userInfo
    let actionIdentifier = response.actionIdentifier

    if actionIdentifier == "later" {
      if let identifier = response.notification.request.content.userInfo["identifier"] as? String {
        var identifiers = NotificationManager.shared.identifiers
        identifiers[identifier] = Date(timeIntervalSinceNow: 60 * 60 * 24)
        NotificationManager.shared.saveIdentifiers(identifiers)
        guard let place = PlaceManager.shared.placeForIdentifier(identifier) else {
          print("ERROR: MIA: place for analytics event")
          return
        }
        let post = place.post
        let coordinate = LocationManager.latestCoordinate
        self.analytics!.log(.tapsPingMeLaterInNotificationCTA(post: post, currentLocation: coordinate))
      }
    } else {
      self.receivedNotification(response: response)
    }

    if let messageID = userInfo[gcmMessageIDKey] {
      print("gcm: Message ID: \(messageID)")
      if
        let urlString = userInfo["url"] as? String,
        let url = URL(string: urlString),
        UIApplication.shared.canOpenURL(url) {
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
      }
    }

    completionHandler()
  }

  func saveIdentifiers(_ identifiers: [String : Date]) {
    UserDefaults.standard.set(identifiers, forKey: "received-notification-identifiers")
    self.identifiers = identifiers
  }

  private func receivedNotification(response: UNNotificationResponse) {
    print("notificationManager receivedNotification: \(response)")
    let userInfo = response.notification.request.content.userInfo
    if response.notification.request.content.categoryIdentifier == "POST_ENTERED" {
      guard
        let urlString: String = userInfo["PLACE_URL"] as? String,
        let url: URL = URL(string: urlString) else {
          print("MIA: share URL")
          return
      }
      guard let delegate = self.delegate else {
        print("ERROR: MIA: NotificationManager.shared.delegate")
        return
      }
      let coordinate = LocationManager.shared.latestCoordinate
      if response.actionIdentifier == "share" {
        self.analytics!.log(.tapsShareInNotificationCTA(url: url, currentLocation: coordinate))
        guard let data = response.notification.request.content.userInfo["SHARE_DATA"] as? [String:[UIActivityType:String]] else {
          print("MIA: share copy")
          return
        }
        let activityItems: [Any] = [
          ShareItemSource(data: data),
        ]
        let activityViewController =
          UIActivityViewController(
            activityItems: activityItems,
            applicationActivities: nil)
        delegate.present(activityViewController, animated: true)

      } else if let identifier = response.notification.request.content.userInfo["identifier"] as? String {

        if let place = PlaceManager.shared.placeForIdentifier(identifier) {
          self.analytics!.log(.tapsNotificationDefaultTapToClickThrough(post: place.post, currentLocation: coordinate))
        } else {
          print("WARN: MIA: place for identifier \(identifier); analytics event dropped")
        }
        delegate.openInSafari(url: url)
      }
    }
  }

}
