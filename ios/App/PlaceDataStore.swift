import UIKit
import Alamofire
import Gloss
import CoreLocation

class PlaceDataStore: NSObject {

  func retrievePlaces(latitude: CLLocationDegrees, longitude: CLLocationDegrees, completion: @escaping (Bool, [Place], Int) -> Void) {

    let env = Env()
    let url = "\(env.apiBaseUrlString)/places.json"

    let params = ["lat": latitude, "lng": longitude, "limit": 19]
    Alamofire.request(url, parameters: params).responseJSON { response in
      let json = response.result.value as? JSON
      if (json == nil) {
        DispatchQueue.main.async { completion(false, [], 0) }
        return
      }
      let meta = json!["meta"] as? JSON
      var count = 0
      if (meta != nil) {
        count = meta!["count"] as! Int
      }
      let placesJSON = json!["data"] as? [JSON]
      if (placesJSON == nil) {
        DispatchQueue.main.async { completion(false, [], 0) }
        return
      }
      guard let places = [Place].from(jsonArray: placesJSON!) else {
        print("Error")
        DispatchQueue.main.async {
          completion(false, [], 0)
        }
        return
      }
      DispatchQueue.main.async {
        completion(true, places, count)
      }
    }
  }
}
