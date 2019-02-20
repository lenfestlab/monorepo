import UIKit
import UserNotifications
import CoreLocation
import Alamofire
import UserDefaultsStore

class PlaceManager: NSObject {

  static let shared = PlaceManager()
  let placesStore = UserDefaultsStore<Place>(uniqueIdentifier: "places")!

  func placeForIdentifier(_ identifier: String) -> Place? {
    return placesStore.object(withId: identifier)
  }

  func removeAllMonitoredRegions() {
    for region in LocationManager.shared.locationManager.monitoredRegions {
      LocationManager.shared.locationManager.stopMonitoring(for: region) // asynchronous
    }
  }

  func trackPlaces(places: [Place]) {
    print("placeManager trackPlaces: \(places.count)")

    removeAllMonitoredRegions()

    try! placesStore.save(places)

    let center = UNUserNotificationCenter.current()
    for place in places {
      PlaceManager.trackPlace(place: place, radius: place.radius ?? 100, center: center)
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

  class func contentForPlace(place: Place, completionHandler: @escaping (UNMutableNotificationContent?) -> Void) {
    print("placeManager contentForPlace \(place)")
    if let url = place.imageURL {
      getImage(url.absoluteString) { (image) in
        contentForPlace(place: place, image: image, completionHandler: completionHandler)
      }
    } else {
      contentForPlace(place: place, image: nil, completionHandler: completionHandler)
    }
  }

  class func contentForPlace(place: Place, image: UIImage?, completionHandler: @escaping (UNMutableNotificationContent?) -> Void) {
    let title = place.title!

    let content = UNMutableNotificationContent()
    content.title = title
    content.body = place.blurb!
    content.categoryIdentifier = "POST_ENTERED"
    content.sound = UNNotificationSound.default

    guard let post = place.post else {
      completionHandler(nil)
      return
    }

    let placeURLString = post.link?.absoluteString

    var userInfo = [
      "SHARE_DATA": [
        "string":[
          UIActivity.ActivityType.message: ShareManager.messageCopyForPlace(place),
          UIActivity.ActivityType.mail: ShareManager.mailCopyForPlace(place),
          UIActivity.ActivityType.postToTwitter: ShareManager.twitterCopyForPlace(place),
          UIActivity.ActivityType.postToFacebook: ShareManager.facebookCopyForPlace(place)
        ],
        "subject":[
          UIActivity.ActivityType.mail: ShareManager.mailSubjectForPlace(place),
        ]
      ],
      "identifier": place.identifier
      ] as [String : Any]

    userInfo["PLACE_URL"] = placeURLString

    content.userInfo = userInfo
    if image != nil {
      let attachment = UNNotificationAttachment.create(identifier: "image", image: image!, options: [:])
      if attachment != nil {
        content.attachments = [attachment!]
      } else {
        print("ERROR: notification attachment nil \(placeURLString ?? "no url")")
      }
    }

    completionHandler(content)
  }


  class func trackPlace(place: Place, radius: CLLocationDistance, center:UNUserNotificationCenter) {
//    print("placeManager trackPlace: \(place) \n")
    let region = self.regionForPlace(place: place, radius: radius)
    LocationManager.shared.locationManager.startMonitoring(for: region)
  }

}
