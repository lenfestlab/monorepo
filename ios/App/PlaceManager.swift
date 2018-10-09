import UIKit
import UserNotifications
import CoreLocation
import Alamofire
import UserDefaultsStore

class PlaceManager: NSObject {

  static let shared = PlaceManager()
  let placesStore = UserDefaultsStore<Place>(uniqueIdentifier: "places")!

  func placeForIdentifier(identifier: String) -> Place? {
    return placesStore.object(withId: identifier)
  }
  
  func removeAllMonitoredRegions() {
    for region in (LocationManager.shared.locationManager?.monitoredRegions)! {
      LocationManager.shared.locationManager?.stopMonitoring(for: region)
    }
  }
  
  func trackPlaces(places: [Place], radius: CLLocationDistance) {
    
    removeAllMonitoredRegions()
    
    try! placesStore.save(places)
    
    let center = UNUserNotificationCenter.current()
    for place in places {
      PlaceManager.trackPlace(place: place, radius: radius, center: center)
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
  
  class func regionForPlace(place: Place, radius: CLLocationDistance) -> CLCircularRegion {
    let center = place.coordinate()
    let region = CLCircularRegion(center: center, radius: radius, identifier: place.identifier)
    region.notifyOnEntry = true
    region.notifyOnExit = false
    return region
  }
  
  class func contentForPlace(place: Place, completionHandler: @escaping (UNMutableNotificationContent) -> Void) {
    if let url = place.imageURL {
      getImage(url.absoluteString) { (image) in
        contentForPlace(place: place, image: image, completionHandler: completionHandler)
      }
    } else {
      contentForPlace(place: place, image: nil, completionHandler: completionHandler)
    }
  }
  
  class func contentForPlace(place: Place, image: UIImage?, completionHandler: @escaping (UNMutableNotificationContent) -> Void) {
    let content = UNMutableNotificationContent()
    content.title = place.title!
    content.body = place.blurb!
    content.categoryIdentifier = "POST_ENTERED"
    content.sound = UNNotificationSound.default()
    content.userInfo = ["PLACE_URL": place.post.link.absoluteString, "identifier": place.identifier ]
    if image != nil {
      let attachment = UNNotificationAttachment.create(identifier: "image", image: image!, options: [:])
      if attachment != nil {
        content.attachments = [attachment!]
      }
    }
    
    completionHandler(content)
  }
  
  class func trackPlace(place: Place, radius: CLLocationDistance, center:UNUserNotificationCenter) {
    let region = self.regionForPlace(place: place, radius: radius)
    LocationManager.shared.locationManager?.startMonitoring(for: region)
  }

}
