import UIKit
import CoreLocation
import UserNotifications
import Alamofire
import RxSwift

protocol NotificationManagerDelegate: class {
  func present(_ vc: UIViewController, animated: Bool)
  func push(_ vc: UIViewController, animated: Bool)
  func openInSafari(url: URL)
}

class NotificationManager: NSObject, UNUserNotificationCenterDelegate {

  static let shared = NotificationManager()

  let bag: DisposeBag = DisposeBag()
  var analytics: AnalyticsManager?

  static func sharedWith(analytics: AnalyticsManager) -> NotificationManager {
    let manager = NotificationManager.shared
    manager.analytics = analytics
    return manager
  }

  var identifiers:[String: Date]

  weak var delegate: NotificationManagerDelegate?
  var notificationCenter:UNUserNotificationCenter?
  var authorizationStatus:UNAuthorizationStatus = .notDetermined

  func refreshAuthorizationStatus(completionHandler: @escaping (UNAuthorizationStatus) -> Void) {
    notificationCenter?.getNotificationSettings { (settings) in
      print("Checking notification status")
      self.authorizationStatus = settings.authorizationStatus
      completionHandler(settings.authorizationStatus)
    }
  }

  override init() {
    var identifiers = UserDefaults.standard.dictionary(forKey: "received-notification-identifiers") as? [String: Date]
    if identifiers == nil {
      identifiers = [:]
    }
    self.identifiers = identifiers!
    super.init()
    notificationCenter = UNUserNotificationCenter.current()
    notificationCenter?.delegate = self
    refreshAuthorizationStatus { (status) in }
    setCategories()
  }

  func requestAuthorization(completionHandler: @escaping (UNAuthorizationStatus, Error?) -> Void){
    let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
    UNUserNotificationCenter.current().requestAuthorization(options: authOptions) { (granted, error) in
      self.refreshAuthorizationStatus(completionHandler: { (status) in
        if granted {
          print("NotificationCenter Authorization Granted!")
        }
        completionHandler(status, error)
      })
    }
  }

  func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    willPresent notification: UNNotification,
    withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
    print("notificationmanager userNotificationCenter willPresent: \(notification) withCompletionHandler")
    completionHandler([.alert, .sound])
  }

  enum Category: String, CaseIterable {
    case announcement
  }
  enum Action: String, CaseIterable {
    case read, save, unsave, share
  }

  func setCategories(){
    notificationCenter?.setNotificationCategories([

      UNNotificationCategory(
        identifier: Category.announcement.rawValue,
        actions: [
          UNNotificationAction(
            identifier: Action.read.rawValue,
            title: "Read Review",
            options: [.foreground]),
          UNNotificationAction(
            identifier: Action.save.rawValue,
            title: "Save to My List",
            options: []),
          //UNNotificationAction(
            //identifier: Action.unsave.rawValue,
            //title: "Remove from My List",
            //options: []),
          UNNotificationAction(
            identifier: Action.share.rawValue,
            title: "Share",
            options: [.foreground])
        ],
        intentIdentifiers: [],
        options: []),

      ])
  }

  func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    didReceive response: UNNotificationResponse,
    withCompletionHandler completionHandler: @escaping () -> Void) {
    print("\n response"); print(response)
    let categoryId = response.notification.request.content.categoryIdentifier
    let actionId = response.actionIdentifier
    let userInfo = response.notification.request.content.userInfo
    let url = userInfo["url"] as? String
    let postURL = userInfo["post_url"] as? String
    let placeIdentifier = userInfo["place_id"] as? String

    guard let _ = Category(rawValue: categoryId) else {
      print("MIA: category unspecified/unsupported")
      // if manual push from FIR w/ "url" property, open in safari
      return self.attemptOpenURL(url, completionHandler)
    }

    switch Action(rawValue: actionId) {
    case .none: // tapped notification body, not action button
      attemptShowPlace(placeIdentifier, completionHandler)
    case .some(let action):
      switch action {
      case .read:
        attemptOpenURL(postURL, completionHandler)
      case .save:
        updatePlace(placeIdentifier, save: true, completionHandler)
      case .unsave:
        updatePlace(placeIdentifier, save: false, completionHandler)
      case .share:
        attemptSharePlace(placeIdentifier, completionHandler)
      }
    }
  }

  private func attemptOpenURL(
    _ urlString: String?,
    _ completionHandler: @escaping ()->()) {
    guard
      let urlString = urlString,
      let url = URL(string: urlString),
      UIApplication.shared.canOpenURL(url)
      else { return completionHandler() }
    //  self.delegate?.openInSafari(url: url)
    UIApplication.shared.open(url, options: [:], completionHandler: { _ in
      completionHandler()
    })
  }

  private func attemptShowPlace(
    _ identifier: String?,
    _ completionHandler: @escaping ()->()) {
    guard let identifier = identifier else { return completionHandler() }
    let api = Api(env: Env()) // TODO: inject
    api.getPlace$(identifier)
      .drive(onNext: { [weak self] (result: Result<Place>) in
        switch result {
        case .success(let place):
          guard
            let analytics = self?.analytics,
            let delegate = self?.delegate
            else { print("MIA: delegate"); return completionHandler() }
          print("success \(place)")
          let vc = DetailViewController(analytics: analytics, place: place)
          print("success \(vc)")
           delegate.push(vc, animated: true)
        case .failure(let error):
          print("NOOP error \(error)")
        }
        }, onCompleted: {
          completionHandler()
      }).disposed(by: self.bag)
  }

  private func attemptSharePlace(
    _ identifier: String?,
    _ completionHandler: @escaping () -> ()) {
    guard
      let identifier = identifier,
      let delegate = delegate
      else { return completionHandler() }
    let api = Api(env: Env()) // TODO: inject
    api.getPlace$(identifier)
      .drive(onNext: { (result: Result<Place>) in
        switch result {
        case .success(let place):
          print("success \(place)")
          let data: [String: [UIActivity.ActivityType: String]] = [
            "string":[
              UIActivity.ActivityType.message: ShareManager.messageCopyForPlace(place),
              UIActivity.ActivityType.mail: ShareManager.mailCopyForPlace(place),
              UIActivity.ActivityType.postToTwitter: ShareManager.twitterCopyForPlace(place),
              UIActivity.ActivityType.postToFacebook: ShareManager.facebookCopyForPlace(place),
            ],
            "subject":[
              UIActivity.ActivityType.mail: ShareManager.mailSubjectForPlace(place),
            ]
          ]
          let activityItems: [Any] = [
            ShareItemSource(data: data),
          ]
          let vc =
            UIActivityViewController(
              activityItems: activityItems,
              applicationActivities: nil)
          delegate.present(vc, animated: true)
        case .failure(let error):
          print("NOOP error \(error)")
        }
        }, onCompleted: {
          completionHandler()
      }).disposed(by: self.bag)
  }

  private func updatePlace(
    _ identifier: String?,
    save: Bool,
    _ completionHandler: @escaping ()->()) {
    guard let identifier = identifier else { return completionHandler() }
    if save {
      createBookmark(placeId: identifier, completion: { _ in
        completionHandler()
      })
    } else {
      deleteBookmark(placeId: identifier, completion: { _ in
        completionHandler()
      })
    }
  }

  func saveIdentifiers(_ identifiers: [String : Date]) {
    UserDefaults.standard.set(identifiers, forKey: "received-notification-identifiers")
    self.identifiers = identifiers
  }

  private func receivedNotification(response: UNNotificationResponse) {
    print("notificationManager receivedNotification: \(response)")
    let userInfo = response.notification.request.content.userInfo
    if response.notification.request.content.categoryIdentifier == "POST_ENTERED" {
      guard
        let urlString: String = userInfo["PLACE_URL"] as? String,
        let url: URL = URL(string: urlString) else {
          print("MIA: share URL")
          return
      }
      guard let delegate = self.delegate else {
        print("ERROR: MIA: NotificationManager.shared.delegate")
        return
      }
      let coordinate = LocationManager.shared.latestCoordinate
      if response.actionIdentifier == "share" {
        self.analytics!.log(.tapsShareInNotificationCTA(url: url, currentLocation: coordinate))
        guard let data = response.notification.request.content.userInfo["SHARE_DATA"] as? [String:[UIActivity.ActivityType:String]] else {
          print("MIA: share copy")
          return
        }
        let activityItems: [Any] = [
          ShareItemSource(data: data),
        ]
        let activityViewController =
          UIActivityViewController(
            activityItems: activityItems,
            applicationActivities: nil)
        delegate.present(activityViewController, animated: true)

      } else if let identifier = response.notification.request.content.userInfo["identifier"] as? String {

        if let place = PlaceManager.shared.placeForIdentifier(identifier) {
          self.analytics!.log(.tapsNotificationDefaultTapToClickThrough(place: place, location: coordinate))
        } else {
          print("WARN: MIA: place for identifier \(identifier); analytics event dropped")
        }
        delegate.openInSafari(url: url)
      }
    }
  }

}
