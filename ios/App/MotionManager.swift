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
  var currentActivity:CMMotionActivity?

  class func isActivityAvailable() -> Bool {
    return CMMotionActivityManager.isActivityAvailable()
  }

  func track(handler: @escaping (CMMotionActivity) -> Void) {
    manager.startActivityUpdates(to: .main) { (activity) in
      guard let activity = activity else {
        return
      }

      self.currentActivity = activity
      handler(activity)
    }
  }

}
