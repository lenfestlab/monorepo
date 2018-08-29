import UIKit
import Alamofire
import Gloss

class VenueDataStore: NSObject {

  // Temporary localhost server using http-server
  let url = "http://localhost:8081/venues.json"
  var query: String?
  
  func retrieveVenues(completion: @escaping (Bool, [Venue], Int) -> Void) {
    Alamofire.request(url).responseJSON { response in
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
      let venuesJSON = json!["venues"] as? [JSON]
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
