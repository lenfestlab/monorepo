import UIKit

class Env {

  enum Name: String {
    case dev, test, stag, prod
  }

  enum VariableKey: String {
    case name = "ENV_NAME"
    case apiHost = "API_HOST"
    case googleAnalyticsTrackingId = "GOOGLE_ANALYTICS_TID"
    case appName = "APP_NAME"
    case appMarketingPath = "APP_MARKETING_PATH"
    case versionBuild = "CFBundleVersion"
    case versionMarketing = "CFBundleShortVersionString"
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
    let prot = self.isRemote ? "https" : "http"
    return "\(prot)://\(host)"
  }

  var installationId: String {
    return UIDevice().identifierForVendor!.uuidString
  }

  var name: Name {
    return Name(rawValue: get(.name))!
  }

  func isNamed(_ envName: Name) -> Bool {
    return [self.name].contains(envName)
  }

  var isRemote: Bool {
    return [.stag, .prod].contains(self.name)
  }

  var isPreProduction: Bool {
    return [.dev, .test, .stag].contains(self.name)
  }

  var appName: String {
    let baseName = self.get(.appName)
    return isPreProduction ? "\(baseName) \(name)" : baseName
  }

  var appMarketingPath: String {
    return self.get(.appMarketingPath)
  }

  var appMarketingUrlString: String {
    return apiBaseUrlString.appending("/\(appMarketingPath)")
  }

  var buildVersion: String {
    return get(.versionBuild)
  }

}
