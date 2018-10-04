import UIKit
import CoreLocation
import UserNotifications
import Alamofire
import Gloss

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

  func triggerForCoordinate(center: CLLocationCoordinate2D, radius: CLLocationDistance, identifier: String) -> UNLocationNotificationTrigger {
    let region = CLCircularRegion(center: center, radius: radius, identifier: identifier)
    region.notifyOnEntry = true
    region.notifyOnExit = false
    let trigger = UNLocationNotificationTrigger(region: region, repeats: false)
    return trigger
  }

  func getImage(_ url:String,handler: @escaping (UIImage?)->Void) {
    Alamofire.request(url, method: .get).responseImage { response in
      if let data = response.result.value {
        handler(data)
      } else {
        handler(nil)
      }
    }
  }
  
  func silentNotification(userInfo: [AnyHashable : Any], center:UNUserNotificationCenter) {
    let content = UNMutableNotificationContent()
    content.sound = UNNotificationSound.default()
    content.userInfo = userInfo
    content.categoryIdentifier = "SILENT"
    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 2, repeats: false)
    let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
    center.add(request)
  }
  
  func trackVenue(venue: Venue, radius: CLLocationDistance, center:UNUserNotificationCenter) {
    print("tracking venue: \(venue.title!)")
    let url = venue.image!
    getImage(url.absoluteString) { (image) in
      
      let json = venue.toJSON()!
      let content = UNMutableNotificationContent()
      content.title = venue.title!
      content.body = venue.blurb!
      content.categoryIdentifier = "POST_ENTERED"
      content.sound = UNNotificationSound.default()
      content.userInfo = json
      if image != nil {
        let attachment = UNNotificationAttachment.create(identifier: "image", image: image!, options: [:])
        if attachment != nil {
          content.attachments = [attachment!]
        }
      }
      
      let trigger = self.triggerForCoordinate(center: venue.coordinate(), radius: radius, identifier: venue.title!)
      let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
      center.add(request)
    }
  }

  
  func setCategories(){
    let laterAction = UNNotificationAction(identifier: "later", title: "Ping Me Later", options: [])
    let alarmCategory = UNNotificationCategory(identifier: "POST_ENTERED", actions: [laterAction], intentIdentifiers: [], options: [])
    UNUserNotificationCenter.current().setNotificationCategories([alarmCategory])
  }
  
  func trackVenues(venues: [Venue], radius: CLLocationDistance) {
    setCategories()
    
    let center = UNUserNotificationCenter.current()
    center.removeAllPendingNotificationRequests() // deletes pending scheduled notifications, there is a schedule limit qty
    
    for venue in venues {
      trackVenue(venue: venue, radius: radius, center: center)
    }
  }
  
  func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
    
    let content = notification.request.content
    if content.categoryIdentifier == "SILENT" {
      let venue = Venue.init(json: content.userInfo as! JSON)
      trackVenue(venue: venue!, radius: 100, center:center)
    }
    
    completionHandler([.alert, .sound])
  }
  
  func userNotificationCenter(_ center: UNUserNotificationCenter,
                              didReceive response: UNNotificationResponse,
                              withCompletionHandler completionHandler: @escaping () -> Void) {
    let identifier = response.actionIdentifier
    if identifier == "later"{
      let userInfo = response.notification.request.content.userInfo
      silentNotification(userInfo: userInfo, center: center)
    } else {
      delegate?.recievedNotification(self, response: response)
    }
    
    completionHandler()
  }

  
}
