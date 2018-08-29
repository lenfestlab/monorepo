import UIKit
import CoreLocation
import UserNotifications

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
  
  func triggerForVenue(venue: Venue) -> UNLocationNotificationTrigger {
    let center = CLLocationCoordinate2D(latitude: (venue.location?.latitude)!, longitude: (venue.location?.longitude)!)
    let region = CLCircularRegion(center: center, radius: 2000.0, identifier: venue.title!)
    region.notifyOnEntry = true
    region.notifyOnExit = false
    let trigger = UNLocationNotificationTrigger(region: region, repeats: true)
    return trigger
  }

  func trackVenues(venues: [Venue]) {
    let center = UNUserNotificationCenter.current()
    center.removeAllPendingNotificationRequests() // deletes pending scheduled notifications, there is a schedule limit qty
    
    for venue in venues {
      let content = UNMutableNotificationContent()
      content.title = venue.title!
      content.body = venue.blurb!
      content.categoryIdentifier = "alarm"
      content.sound = UNNotificationSound.default()
      let trigger = self.triggerForVenue(venue: venue)
      let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
      center.add(request)
    }
  }
  
  func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
    completionHandler([.alert, .sound])
  }


}
