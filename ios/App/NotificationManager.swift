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

  func triggerForVenue(venue: Venue, radius: CLLocationDistance) -> UNLocationNotificationTrigger {
    let center = venue.coordinate()
    let region = CLCircularRegion(center: center, radius: radius, identifier: venue.title!)
    region.notifyOnEntry = true
    region.notifyOnExit = false
    let trigger = UNLocationNotificationTrigger(region: region, repeats: true)
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
  
  func trackVenue(venue: Venue, radius: CLLocationDistance, center:UNUserNotificationCenter) {
    let url = venue.images![0]
    getImage(url.absoluteString) { (image) in

      let content = UNMutableNotificationContent()
      content.title = venue.title!
      content.body = venue.blurb!
      content.categoryIdentifier = "POST_ENTERED"
      content.sound = UNNotificationSound.default()
      content.userInfo = ["VENUE_URL": venue.link?.absoluteString ?? "" ]
      if image != nil {
        let attachment = UNNotificationAttachment.create(identifier: "image", image: image!, options: [:])
        if attachment != nil {
          content.attachments = [attachment!]
        }
      }

      let trigger = self.triggerForVenue(venue: venue, radius: radius)
      let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
      center.add(request)
    }
  }
  
  func trackVenues(venues: [Venue], radius: CLLocationDistance) {
    let center = UNUserNotificationCenter.current()
    center.removeAllPendingNotificationRequests() // deletes pending scheduled notifications, there is a schedule limit qty
    
    for venue in venues {
      trackVenue(venue: venue, radius: radius, center: center)
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
