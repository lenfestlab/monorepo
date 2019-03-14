import UIKit
import Alamofire
import Gloss
import CoreLocation

class NeighborhoodDataStore: NSObject {

  class func retrieve(completion: @escaping (Bool, [Neighborhood]?, Int) -> Void) {

    let env = Env()
    let url = "\(env.apiBaseUrlString)/nabes.json"
    Alamofire.request(url, method: .get, encoding: URLEncoding.default, headers: nil).responseJSON { response in
      guard let json = response.result.value as? JSON else {
        DispatchQueue.main.async { completion(false, [], 0) }
        return
      }
      var count = 0
      if let meta = json["meta"] as? JSON {
        count = meta["count"] as? Int ?? 0
      }
      guard let placesJSON = json["data"] as? [JSON] else {
        DispatchQueue.main.async { completion(false, [], 0) }
        return
      }
      guard let nabes = [Neighborhood].from(jsonArray: placesJSON) else {
        DispatchQueue.main.async {
          completion(false, [], 0)
        }
        return
      }
      DispatchQueue.main.async {
        completion(true, nabes, count)
      }
    }
  }
}
