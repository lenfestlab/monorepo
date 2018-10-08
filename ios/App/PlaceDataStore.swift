import UIKit
import Alamofire
import Gloss
import CoreLocation

class PlaceDataStore: NSObject {

  func retrievePlaces(latitude: CLLocationDegrees, longitude: CLLocationDegrees, completion: @escaping (Bool, [Place], Int) -> Void) {

    let bundle = Bundle(for: type(of: self))
    let envName = bundle.object(forInfoDictionaryKey: "ENV_NAME") as! String
    let prot = (envName == "prod") ? "https" : "http"
    let apiHost = bundle.object(forInfoDictionaryKey: "API_HOST") as! String
    let url = "\(prot)://\(apiHost)/places.json"

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
