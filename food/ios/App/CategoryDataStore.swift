import UIKit
import Alamofire
import Gloss
import CoreLocation

class CategoryDataStore: NSObject {

  func retrieveCategories(completion: @escaping (Bool, [Category]?, Int) -> Void) {

    let env = Env()
    let url = "\(env.apiBaseUrlString)/categories.json"

    Alamofire.request(url, method: .get, parameters: nil, encoding: URLEncoding.default, headers: nil).responseJSON { response in
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
      guard let categories = [Category].from(jsonArray: placesJSON!) else {
        DispatchQueue.main.async {
          completion(false, [], 0)
        }
        return
      }
      DispatchQueue.main.async {
        completion(true, categories, count)
      }
    }
  }
}
