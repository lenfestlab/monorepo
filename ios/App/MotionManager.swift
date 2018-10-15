//
//  MotionManager.swift
//  App
//
//  Created by Ajay Chainani on 10/14/18.
//

import UIKit
import CoreMotion

class MotionManager: NSObject {
  static let shared = MotionManager()

  let manager = CMMotionActivityManager()

  class func isActivityAvailable() -> Bool {
    return CMMotionActivityManager.isActivityAvailable()
  }

  func track(handler: @escaping (String) -> Void) {
    manager.startActivityUpdates(to: .main) { (activity) in
      guard let activity = activity else {
        return
      }

      var modes: Set<String> = []
      if activity.walking {
        modes.insert("🚶‍")
      }

      if activity.running {
        modes.insert("🏃‍")
      }

      if activity.cycling {
        modes.insert("🚴‍")
      }

      if activity.automotive {
        modes.insert("🚗")
      }

      print(modes.joined(separator: ", "))
      handler(modes.joined(separator: ", "))
    }
  }

}
