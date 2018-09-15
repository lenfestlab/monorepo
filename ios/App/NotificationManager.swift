import UIKit
import CoreLocation
import UserNotifications
import Alamofire

class NotificationManager: NSObject, UNUserNotificationCenterDelegate {

  var notificationCenter:UNUserNotificationCenter?

  override init() {
    super.init()
    notificationCenter = UNUserNotificationCenter.current()
    notificationCenter?.delegate = self
  }
  
  func requestAuthorization(){
    notificationCenter?.requestAuthorization(options: [.alert, .badge, .sound]) { (granted, error) in
      if granted {
        print("NotificationCenter Authorization Granted!")
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
    print(url)
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
      content.categoryIdentifier = "alarm"
      content.sound = UNNotificationSound.default()

      if image != nil {
        let attachment = UNNotificationAttachment.create(identifier: "image", image: image!, options: [:])
        content.attachments = [attachment!]
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
  
}
