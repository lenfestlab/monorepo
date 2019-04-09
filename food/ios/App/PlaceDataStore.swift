import UIKit
import Alamofire
import Gloss
import CoreLocation

class PlaceDataStore: NSObject {

  class func retrieve(path: String,
                      coordinate: CLLocationCoordinate2D,
                      prices: [Int] = [],
                      ratings: [Int] = [],
                      categories: [Category] = [],
                      neigborhoods: [Neighborhood] = [],
                      authors: [Author] = [],
                      sort: SortMode = .distance,
                      limit: Int,
                      completion: @escaping (Bool, [Place], Int) -> Void) {

    let (latitude, longitude) = (coordinate.latitude, coordinate.longitude)
    print("fetchData: \(path) \(latitude) \(longitude)")

    let category_ids = categories.map { $0.identifier }
    let nabe_ids = neigborhoods.map { $0.identifier }
    let author_ids = authors.map { $0.identifier }

    var params: [String: Any] = [
      "lat": latitude,
      "lng": longitude,
      "limit": limit,
      "prices": prices,
      "ratings": ratings,
      "categories": category_ids,
      "nabes": nabe_ids,
      "authors": author_ids,
      "sort": sort.rawValue.lowercased(),
    ]

    if let authToken = Installation.authToken() {
      params["auth_token"] = authToken
    }

    let env = Env()
    let url = "\(env.apiBaseUrlString)/\(path)"
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
