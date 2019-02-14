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
      var count = 0
      if let meta = json!["meta"] as? JSON {
        count = meta["count"] as? Int ?? 0
      }
      guard let placesJSON = json!["data"] as? [JSON] else {
        DispatchQueue.main.async { completion(false, [], 0) }
        return
      }
      guard let categories = [Category].from(jsonArray: placesJSON) else {
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
