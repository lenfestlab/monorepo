import UIKit

class Env {

  enum VariableKey: String {
    case name = "ENV_NAME"
    case apiHost = "API_HOST"
    case googleAnalyticsTrackingId = "GOOGLE_ANALYTICS_TID"
  }

  private var bundle: Bundle

  init() {
    self.bundle = Bundle(for: type(of: self))
  }

  func get(_ key: VariableKey) -> String {
    return bundle.object(forInfoDictionaryKey: key.rawValue) as! String
  }

  var apiBaseUrlString: String {
    let host = self.get(.apiHost)
    let prot = (["prod", "stag"].contains(self.get(.name))) ? "https" : "http"
    return "\(prot)://\(host)"
  }

  // TODO: persist across installations on same device
  var installlationId: String {
    return UIDevice().identifierForVendor!.uuidString
  }

}
