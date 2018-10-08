import UIKit
import UserNotifications
import CoreLocation
import Alamofire
import UserDefaultsStore

class VenueManager: NSObject {

  static let shared = VenueManager()
  var data:[String: Venue] = [:]
  let venuesStore = UserDefaultsStore<Venue>(uniqueIdentifier: "venues")!

  func venueForIdentifier(identifier: String) -> Venue? {
    return venuesStore.object(withId: identifier)
  }
  
  
  func trackVenues(venues: [Venue], radius: CLLocationDistance) {
    
    try! venuesStore.save(venues)
    
    let center = UNUserNotificationCenter.current()
//    center.removeAllPendingNotificationRequests() // deletes pending scheduled notifications, there is a schedule limit qty
    
    for venue in venues {
      trackVenue(venue: venue, radius: radius, center: center)
    }
  }
  
  class func getImage(_ url:String,handler: @escaping (UIImage?)->Void) {
    Alamofire.request(url, method: .get).responseImage { response in
      if let data = response.result.value {
        handler(data)
      } else {
        handler(nil)
      }
    }
  }
  
  func regionForVenue(venue: Venue, radius: CLLocationDistance) -> CLCircularRegion {
    let center = venue.coordinate()
    let region = CLCircularRegion(center: center, radius: radius, identifier: venue.title!)
    region.notifyOnEntry = true
    region.notifyOnExit = false
    return region
  }
  
  class func contentForVenue(venue: Venue, completionHandler: @escaping (UNMutableNotificationContent) -> Void) {
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
      
      completionHandler(content)
    }
  }
  
  func trackVenue(venue: Venue, radius: CLLocationDistance, center:UNUserNotificationCenter) {
    let region = self.regionForVenue(venue: venue, radius: radius)
    LocationManager.shared.locationManager?.startMonitoring(for: region)
  }

}
