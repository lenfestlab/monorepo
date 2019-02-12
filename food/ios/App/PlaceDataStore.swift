import UIKit
import Alamofire
import Gloss
import CoreLocation

class PlaceDataStore: NSObject {

  func retrievePlaces(coordinate: CLLocationCoordinate2D,
                      prices: [Int]? = nil,
                      ratings: [Int]? = nil,
                      limit: Int,
                      completion: @escaping (Bool, [Place], Int) -> Void) {

    let (latitude, longitude) = (coordinate.latitude, coordinate.longitude)
    print("fetchData: \(latitude) \(longitude)")

    let env = Env()
    var url = "\(env.apiBaseUrlString)/places.json"

    url = String(format: "%@?lat=%f", url, latitude)
    url = String(format: "%@&lng=%f", url, longitude)
    url = String(format: "%@&limit=%i", url, limit)

    if let prices = prices, prices.count > 0 {
      url = String(format: "%@&prices=%@", url, prices.map({ String($0) }).joined(separator: ","))
    }
    if let ratings = ratings, ratings.count > 0 {
      url = String(format: "%@&ratings=%@", url, ratings.map({ String($0) }).joined(separator: ","))
    }

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
      guard let places = [Place].from(jsonArray: placesJSON!) else {
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
