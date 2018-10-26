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

  // Default is:
  // CMMotionActivity @ 106477.106250,<startDate,2018-10-31 19:50:23 +0000,confidence,2,unknown,0,stationary,1,walking,0,running,0,automotive,0,cycling,0>
  var formattedDescription: String {
    let startedAt = self.startDate.toFormat("HH:mm:ss")
    let modeList = self.modes.map({ $0.rawValue }).joined(separator: ",")
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

  func enableMotionDetection() {
    let status = CMMotionActivityManager.authorizationStatus()
    if status == CMAuthorizationStatus.denied {
      self.authorizationDelegate?.notAuthorized(self, status: status)
      return
    }

    manager.startActivityUpdates(to: .main) { (activity) in
      self.manager.stopActivityUpdates()
      let status = CMMotionActivityManager.authorizationStatus()
      if status == CMAuthorizationStatus.authorized {
        self.authorizationDelegate?.authorized(self, status: status)
      } else {
        self.authorizationDelegate?.notAuthorized(self, status: status)
      }
    }
  }

  class func isActivityAvailable() -> Bool {
    return CMMotionActivityManager.isActivityAvailable()
  }

  func startActivityUpdates(handler: @escaping (CMMotionActivity) -> Void) {
    manager.startActivityUpdates(to: .main) { (activity) in
      guard let activity = activity else { return }

      if let lastActivity = self.currentActivity, // if prior activity
        lastActivity.automotive { // ...and prior activity was driving
        // ...record current timestamp for computing time since driven later
        let now = Date()
        self.stoppedDrivingAt = now
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
      return true
    }
    return activity.modes.contains(.unknown)
  }

  var skipNotifications: Bool {
    return self.hasBeenDriving
  }

}
