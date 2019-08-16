import AlamofireNetworkActivityLogger
import UIKit

class Env {

  enum Name: String {
    case dev, test, stag, prod
    var full: String {
      switch self {
      case .dev: return "development"
      case .test: return "test"
      case .stag: return "staging"
      case .prod: return "production"
      }
    }

  }

  enum VariableKey: String {
    case name = "ENV_NAME"
    case apiHost = "API_HOST"
    case apiProt = "API_PROT"
    case googleAnalyticsTrackingId = "GOOGLE_ANALYTICS_TID"
    case appName = "APP_NAME"
    case appMarketingPath = "APP_MARKETING_PATH"
    case versionBuild = "CFBundleVersion"
    case versionMarketing = "CFBundleShortVersionString"
    case amplitudeApiKey = "AMPLITUDE_API_KEY"
    case sentryDSN = "SENTRY_DSN"
    case networkLogLevel = "NETWORK_LOG_LEVEL"
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
    let prot = self.get(.apiProt)
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

  var networkLogLevel: NetworkActivityLoggerLevel {
    guard isPreProduction else { return .off }
    switch get(.networkLogLevel) {
    case "debug": return .debug
    case "info": return .info
    case "warn": return .warn
    case "error": return .error
    case "fatal": return .fatal
    default: return .off
    }
  }


}
