import Alamofire
import Gloss
import CloudKit

/// async gets iCloud ID object of logged-in iCloud user
func iCloudUserIDAsync(complete: @escaping (String?, Error?) -> ()) {
  let container = CKContainer.default()
  container.fetchUserRecordID() {
    recordID, error in
    if error != nil {
      print(error!.localizedDescription)
      complete(nil, error)
    } else {
      print("fetched ID \(String(describing: recordID?.recordName))")
      complete(recordID?.recordName, nil)
    }
  }
}

class Installation: NSObject {

  class func register(cloudId: String, completion: @escaping (Bool, JSON?) -> Void) {
    patch(cloudId: cloudId, completion: completion)
  }

  class func update(cloudId: String, emailAddress: String, completion: @escaping (Bool, JSON?) -> Void) {
    let params = ["email" : emailAddress]
    patch(cloudId: cloudId, params: params, completion: completion)
  }

  class func patch(cloudId: String, params: [String: Any]? = nil, completion: @escaping (Bool, JSON?) -> Void) {
    let env = Env()
    let url = "\(env.apiBaseUrlString)/installations/\(cloudId)"
    Alamofire.request(url, method:.patch, parameters:params).responseJSON { response in
      let json = response.result.value as? JSON
      if (json == nil) {
        DispatchQueue.main.async { completion(false, nil) }
        return
      }

      DispatchQueue.main.async {
        completion(true, json)
      }
    }
  }

}

