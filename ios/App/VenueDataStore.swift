import UIKit
import Alamofire
import Gloss
import CoreLocation

class VenueDataStore: NSObject {

  func retrieveVenues(latitude: CLLocationDegrees, longitude: CLLocationDegrees, completion: @escaping (Bool, [Venue], Int) -> Void) {

    let bundle = Bundle(for: type(of: self))
    let envName = bundle.object(forInfoDictionaryKey: "ENV_NAME") as! String
    let prot = (envName == "prod") ? "https" : "http"
    let apiHost = bundle.object(forInfoDictionaryKey: "API_HOST") as! String
    let url = "\(prot)://\(apiHost)/posts.json"

    let params = ["latitude": latitude, "longitude": longitude, "limit": 20]
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
      let venuesJSON = json!["data"] as? [JSON]
      if (venuesJSON == nil) {
        DispatchQueue.main.async { completion(false, [], 0) }
        return
      }
      guard let venues = [Venue].from(jsonArray: venuesJSON!) else {
        print("Error")
        DispatchQueue.main.async {
          completion(false, [], 0)
        }
        return
      }
      DispatchQueue.main.async {
        completion(true, venues, count)
      }
    }
  }
}
