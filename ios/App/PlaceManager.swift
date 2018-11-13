import UIKit
import UserNotifications
import CoreLocation
import Alamofire
import UserDefaultsStore

class PlaceManager: NSObject {

  static let shared = PlaceManager()
  let placesStore = UserDefaultsStore<Place>(uniqueIdentifier: "places")!
  let locationManager = LocationManager.shared

  func placeForIdentifier(_ identifier: String) -> Place? {
    return placesStore.object(withId: identifier)
  }
  
  func removeAllMonitoredRegions() {
    for region in locationManager.locationManager.monitoredRegions {
      locationManager.locationManager.stopMonitoring(for: region) // asynchronous
    }
  }
  
  func trackPlaces(places: [Place]) {
    print("placeManager trackPlaces: \(places)")

    removeAllMonitoredRegions()
    
    try! placesStore.save(places)
    
    let center = UNUserNotificationCenter.current()
    for place in places {
      self.trackPlace(place: place, radius: place.radius ?? 100, center: center)
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
    print("placeManager contentForPlace \(place)")
    if let url = place.imageURL {
      getImage(url.absoluteString) { (image) in
        contentForPlace(place: place, image: image, completionHandler: completionHandler)
      }
    } else {
      contentForPlace(place: place, image: nil, completionHandler: completionHandler)
    }
  }
  
  class func contentForPlace(place: Place, image: UIImage?, completionHandler: @escaping (UNMutableNotificationContent) -> Void) {
    let title = place.title!

    let content = UNMutableNotificationContent()
    content.title = title
    content.body = place.blurb!
    content.categoryIdentifier = "POST_ENTERED"
    content.sound = UNNotificationSound.default()

    let env = Env()
    let placeURLString = place.post.link.absoluteString
//    let placeURL: URL = URL(string: placeURLString)!
    let shareCopy: String = [
      title,
      placeURLString,
      "\n",
      "via the \(env.appName) app \(env.appMarketingUrlString)"
      ].joined(separator: "\n")

    content.userInfo = [
      "PLACE_URL": placeURLString,
      "SHARE_COPY": shareCopy,
      "identifier": place.identifier
    ]
    if image != nil {
      let attachment = UNNotificationAttachment.create(identifier: "image", image: image!, options: [:])
      if attachment != nil {
        content.attachments = [attachment!]
      } else {
        print("ERROR: notification attachment nil \(placeURLString)")
      }
    }
    
    completionHandler(content)
  }

  
  func trackPlace(place: Place, radius: CLLocationDistance, center:UNUserNotificationCenter) {
    print("placeManager trackPlace: \(place) \n")
    let region = PlaceManager.regionForPlace(place: place, radius: radius)
    locationManager.locationManager.startMonitoring(for: region)
  }


  class var randomMonitoredRegion: CLRegion? {
    guard let place = shared.placesStore.allObjects().randomElement() else {
      return nil
    }
    return regionForPlace(place: place, radius: 50)
  }

}
