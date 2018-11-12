import UIKit
import CoreMotion
import SwiftDate
import CoreLocation
import SwiftDate

extension CMMotionActivityConfidence: CustomStringConvertible {
  public var description: String {
    switch self {
    case .low: return "low"
    case .medium: return "medium"
    case .high: return "high"
    }
  }
  var debugDescription: String {
    return description
  }
}

extension CMMotionActivity {

  enum Mode: String, CaseIterable {
    case stationary, walking, running, automotive, cycling, unknown
  }

  var modes: Set<Mode> {
    var modes: Set<Mode> = []
    if stationary { modes.insert(.stationary) }
    if walking { modes.insert(.walking) }
    if running { modes.insert(.running) }
    if cycling { modes.insert(.cycling) }
    if automotive { modes.insert(.automotive) }
    if unknown { modes.insert(.unknown) }
    // NOTE: somehow, occassionally *all* are false, including "unknown"!
    if modes.isEmpty { modes.insert(.unknown) }
    return modes
  }

  var modeList: String {
    return self.modes.map({ $0.rawValue }).joined(separator: ",")
  }

  // Default is:
  // CMMotionActivity @ 106477.106250,<startDate,2018-10-31 19:50:23 +0000,confidence,2,unknown,0,stationary,1,walking,0,running,0,automotive,0,cycling,0>
  var formattedDescription: String {
    let startedAt = self.startDate.toFormat("HH:mm:ss")
    return "\(startedAt) [\(modeList)] (confidence: \(confidence))"
  }
}

protocol MotionManagerAuthorizationDelegate: class {
  func authorized(_ motionManager: MotionManager, status: CMAuthorizationStatus)
  func notAuthorized(_ motionManager: MotionManager, status: CMAuthorizationStatus)
}

class MotionManager: NSObject {
  static let shared = MotionManager()

  weak var authorizationDelegate: MotionManagerAuthorizationDelegate?
  let manager = CMMotionActivityManager()
  var currentActivity:CMMotionActivity?

  class func isActivityAvailable() -> Bool {
    let result = CMMotionActivityManager.isActivityAvailable()
//    print("\t MotionManager.isActivityAvailable \(result)")
    return result
  }

  func hasStatus(_ status: CMAuthorizationStatus) -> Bool {
    return CMMotionActivityManager.authorizationStatus() == status
  }

  var isAuthorized: Bool {
    return hasStatus(.authorized)
  }

  var analytics: AnalyticsManager?
  static func sharedWith(analytics: AnalyticsManager) -> MotionManager {
    let manager = self.shared
    manager.analytics = analytics
    guard
      MotionManager.isActivityAvailable(),
      manager.hasStatus(.authorized) else {
        print("WARN: motion not available or authorized; skip motion analytics")
        return manager
    }
    manager.startActivityUpdates { _activity in
      print("motion authorized, configuring analytics")
    }
    return manager
  }

  func enableMotionDetection(_ analytics: AnalyticsManager?) {
    let status = CMMotionActivityManager.authorizationStatus()
    if status == CMAuthorizationStatus.denied {
      self.authorizationDelegate?.notAuthorized(self, status: status)
      return
    }

    self.startActivityUpdates { [unowned self] activity in
      self.manager.stopActivityUpdates()
      guard let authorizationDelegate = self.authorizationDelegate else {
        print("ERROR: MIA: authorizationDelegate")
        return
      }
      if self.hasStatus(.authorized) {
        authorizationDelegate.authorized(self, status: status)
      } else {
        authorizationDelegate.notAuthorized(self, status: status)
      }
    }
  }

  func startActivityUpdates(handler: @escaping (CMMotionActivity) -> Void) {
    manager.startActivityUpdates(to: .main) { (activity) in
      guard let activity = activity else { return }
//      print("activity: \(activity)")

      if let lastActivity = self.currentActivity, // if prior activity
        lastActivity.automotive { // ...and prior activity was driving
        // ...record current timestamp for computing time since driven later
        let now = Date()
        self.stoppedDrivingAt = now
      }

      // configure motion custom dimensions
      if let analytics = self.analytics {
        analytics.mergeCustomDimensions(cds: [
          "cd3": activity.modeList, // Stationary State
          "cd4": activity.confidence.description, // Confidence level
          "cd5": self.skipNotifications.description, // skipNotifications
          ])
      }

      self.currentActivity = activity
      handler(activity)
    }
  }

  var isDriving: Bool {
    guard let activity = currentActivity else {
      return false
    }
    return activity.automotive
  }

  private let stoppedDrivingAtKey = "feature-motion-automotive-stopped"
  private var stoppedDrivingAt: Date? {
    set(date) {
      if let date = date {
        UserDefaults.standard.set(date, forKey: stoppedDrivingAtKey)
      }
    }
    get {
      return UserDefaults.standard.object(forKey: stoppedDrivingAtKey) as? Date
    }
  }
  var stoppedDrivingAtFormatted: String {
    guard let date = stoppedDrivingAt else { return "n/a" }
    return date.toFormat( "HH:mm:ss")
  }

  var drivingThreshold: Int {
    return 2
  }

  var hasBeenDriving: Bool {
    if isDriving { return true }
    guard let lastDroveAt = self.stoppedDrivingAt else {
      return false
    }
    return lastDroveAt > self.drivingThreshold.minutes.ago
  }

  var isUnknown: Bool {
    guard let activity = currentActivity else {
      print("\t WARN: MIA: activity")
      return true
    }
    return activity.modes.contains(.unknown)
  }

  var skipNotifications: Bool {
    // ensure notification when motion unavailable (sim, denied access, etc.)
    guard MotionManager.isActivityAvailable() else {
      return false
    }
    let hasBeenDriving = self.hasBeenDriving
//    print("\t hasBeenDriving: \(hasBeenDriving)")
    let isUnknown = self.isUnknown
//    print("\t isUnknown: \(isUnknown)")
    let result = (hasBeenDriving || self.isUnknown)
//    print("\t\t skipNotifications \(result)")
    return result
  }

}
