import UIKit
import Firebase
import FirebaseMessaging
import Schedule
import SafariServices

typealias LaunchOptions = [UIApplication.LaunchOptionsKey: Any]?
let gcmMessageIDKey = "gcm.message_id"

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var lastViewedURL: URL?
  var window: UIWindow?
  var analytics: AnalyticsManager!
  var locationManager: LocationManager!
  var notificationManager: NotificationManager!
  var mainController: MainController!
  var tabController: TabBarViewController!

  class func shared() -> AppDelegate {
    return UIApplication.shared.delegate as! AppDelegate
  }

  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: LaunchOptions) -> Bool {

    let env = Env()

    FirebaseApp.configure()
    Messaging.messaging().delegate = self
    application.registerForRemoteNotifications()
    InstanceID.instanceID().instanceID { (result, error) in
      if let error = error {
        print("gcm: Error fetching remote instange ID: \(error)")
      } else if let result = result {
        print("gcm: Remote instance ID token: \(result.token)")
      }
    }

    self.analytics = AnalyticsManager(env)
    self.locationManager = LocationManager.sharedWith(analytics: analytics)
    self.notificationManager = NotificationManager.sharedWith(analytics: analytics)
    window = UIWindow(frame: UIScreen.main.bounds)
    let onboardingCompleted = UserDefaults.standard.bool(forKey: "onboarding-completed")

    let introController = IntroViewController(analytics: self.analytics)
    self.mainController = MainController(rootViewController: introController)
    self.notificationManager.delegate = self

    if !onboardingCompleted {
      window!.rootViewController = self.mainController
      window!.makeKeyAndVisible()
      return true
    }

    if Installation.authToken() != nil {
      self.showHomeScreen()
      window!.makeKeyAndVisible()
    } else {
      let cloudViewController = CloudViewController()
      window!.rootViewController = cloudViewController
      window!.makeKeyAndVisible()
      iCloudUserIDAsync() { cloudId, error in
        if let cloudId = cloudId {
          print("received iCloudID \(cloudId)")

          Installation.register(cloudId: cloudId, completion: { (success, accessToken) in
            DispatchQueue.main.async { [unowned self] in
              self.showHomeScreen()
            }
          })

        } else {
          print("Fetched iCloudID was nil")
          DispatchQueue.main.async { [unowned self] in
            self.showHomeScreen()
          }
        }
      }
    }

    return true
  }

  func showPermissions() {
    mainController.pushViewController(
      PermissionsViewController(analytics: self.analytics),
      animated: false)
  }

  func showNotifications() {
    mainController.pushViewController(
      NotificationViewController(analytics: self.analytics),
      animated: false)
  }

  func showHomeScreen() {
    self.tabController = TabBarViewController(analytics: self.analytics)
    window!.rootViewController = self.tabController
  }

  func showEmailRegistration(cloudId: String) {
    mainController.pushViewController(
      EmailViewController(analytics: self.analytics, cloudId: cloudId),
      animated: false)
  }


  func application(
    _ application: UIApplication,
    didReceiveRemoteNotification
    userInfo: [AnyHashable : Any],
    fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult
    ) -> Void) {
    print("didReceiveRemoteNotification userInfo: \(userInfo)")

    if let notificationType: String = userInfo["type"] as? String,
      notificationType == "location" {
      let locationManager = LocationManager.shared
      let plan = Plan.after(3.seconds) // wait for location update
      plan.do {
        if let latestLocation = locationManager.latestLocation {
          locationManager.logLocationChange(latestLocation)
          Plan.after(3.seconds).do { // wait for GA to fire
            completionHandler(.newData)
          }
        } else {
          print("ERROR: MIA latestLocation")
          completionHandler(.noData)
        }
      }
    } else {
      completionHandler(.noData)
    }
  }

}


extension AppDelegate: MessagingDelegate {

  func messaging(_ messaging: Messaging, didReceiveRegistrationToken gcmToken: String) {
    print("gcm: registration token: \(gcmToken)")
    // NOTE: shared topic for all notification types; fork behavior on payload
    let topic = "all"
    Messaging.messaging().subscribe(toTopic: topic) { error in
      if let errorDesc: String = error?.localizedDescription {
        print("ERROR: gcm: failed to subscribe to topic \(topic) - \(errorDesc)")
      } else {
        print("gcm: subscribed to topic: \(topic)")
      }
    }
  }

}

extension AppDelegate: NotificationManagerDelegate {
  func present(_ vc: UIViewController, animated: Bool) {
    self.mainController.present(vc, animated: true, completion: nil)
  }

  func openInSafari(url: URL) {
    self.lastViewedURL = url
    if let presented = self.mainController.presentedViewController {
      presented.dismiss(animated: false, completion: { [unowned self] in
        let svc = SFSafariViewController(url: url)
        self.mainController.present(svc, animated: true, completion: nil)
      })
    } else {
      let svc = SFSafariViewController(url: url)
      self.tabController.present(svc, animated: true, completion: nil)
    }
  }

}
