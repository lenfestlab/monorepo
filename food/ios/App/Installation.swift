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

let authTokenKey = "auth-token"

class Installation: NSObject {

  var email : String?

  static let shared = Installation()

  class func save(authToken: String) {
    let defaults = UserDefaults.standard
    defaults.set(authToken, forKey: authTokenKey)
    defaults.synchronize()
  }

  class func authToken() -> String? {
    let defaults = UserDefaults.standard
    return defaults.string(forKey: authTokenKey)
  }

  class func register(cloudId: String, completion: @escaping (Bool, String?) -> Void) {
    patch(cloudId: cloudId, completion: completion)
  }

  class func update(cloudId: String, emailAddress: String, completion: @escaping (Bool, String?) -> Void) {
    let params = ["email" : emailAddress]
    patch(cloudId: cloudId, params: params, completion: completion)
  }

  class func updateToken(cloudId: String, gcmToken: String, completion: @escaping (Bool, String?) -> Void) {
    patch(cloudId: cloudId, params: ["gcm_token" : gcmToken], completion: completion)
  }

  class func patch(cloudId: String, params: [String: Any]? = nil, completion: @escaping (Bool, String?) -> Void) {
    let env = Env()
    let url = "\(env.apiBaseUrlString)/users/\(cloudId)"
    Alamofire.request(url, method:.patch, parameters:params).responseJSON { response in
      guard let json = response.result.value as? JSON else {
        DispatchQueue.main.async { completion(false, nil) }
        return
      }

      guard let authToken = json["auth_token"] as? String else {
        DispatchQueue.main.async { completion(false, nil) }
        return
      }

      if let email = json["email"] as? String {
        self.shared.email = email
      }

      save(authToken: authToken)

      DispatchQueue.main.async {
        completion(true, authToken)
      }
    }
  }

}

