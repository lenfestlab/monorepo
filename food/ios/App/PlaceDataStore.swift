import UIKit
import Alamofire
import Gloss
import CoreLocation

class PlaceDataStore: NSObject {

  func retrievePlaces(coordinate: CLLocationCoordinate2D,
                      prices: [Int] = [],
                      ratings: [Int] = [],
                      categories: [Category] = [],
                      limit: Int,
                      completion: @escaping (Bool, [Place], Int) -> Void) {

    let (latitude, longitude) = (coordinate.latitude, coordinate.longitude)
    print("fetchData: \(latitude) \(longitude)")

    let category_ids = categories.map { $0.identifier }

    let params: [String: Any] = [
      "lat": latitude,
      "lng": longitude,
      "limit": limit,
      "prices": prices,
      "ratings": ratings,
      "categories": category_ids,
    ]

    let env = Env()
    let url = "\(env.apiBaseUrlString)/places.json"
    Alamofire.request(url, method: .get, parameters: params, encoding: URLEncoding.default, headers: nil).responseJSON { response in
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
      guard let places = [Place].from(jsonArray: placesJSON) else {
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
