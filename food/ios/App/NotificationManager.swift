import UIKit
import CoreLocation
import UserNotifications
import Alamofire
import RxSwift
import RxSwiftExt
import SwiftDate


protocol NotificationManagerDelegate: class {
  func present(_ vc: UIViewController, animated: Bool)
  func push(_ vc: UIViewController, animated: Bool)
  func openInSafari(url: URL)
}

class NotificationManager: NSObject, UNUserNotificationCenterDelegate {

  let bag: DisposeBag = DisposeBag()
  let api: Api
  let analytics: AnalyticsManager
  let locationManager: LocationManager

  weak var delegate: NotificationManagerDelegate?
  var notificationCenter: UNUserNotificationCenter?
  var authorizationStatus: UNAuthorizationStatus = .notDetermined

  func refreshAuthorizationStatus(completionHandler: @escaping (UNAuthorizationStatus) -> Void) {
    notificationCenter?.getNotificationSettings { (settings) in
      print("Checking notification status")
      self.authorizationStatus = settings.authorizationStatus
      completionHandler(settings.authorizationStatus)
    }
  }

  init(
    api: Api,
    analytics: AnalyticsManager,
    locationManager: LocationManager
    ) {
    self.api = api
    self.analytics = analytics
    self.locationManager = locationManager
    super.init()
    notificationCenter = UNUserNotificationCenter.current()
    notificationCenter?.delegate = self
    refreshAuthorizationStatus { (status) in }
    setCategories()
    observeLocationManager()
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

  enum Action: String, CaseIterable {
    case read, save, unsave, share
    var identifier: String { return rawValue }
    var title: String {
      switch self {
      case .read: return "Read Review"
      case .save: return "Save to My List"
      case .unsave: return "Remove from My List"
      case .share: return "Share"
      }
    }
    var options: UNNotificationActionOptions {
      switch self {
      case .read, .share:
        return [.foreground]
      default:
        return []
      }
    }
  }

  enum Category: String, CaseIterable {
    case announcement, nearby
    var identifier: String { return rawValue }
    var actions: Set<Action> {
      switch self {
      case .announcement: return [.read, .save, .share]
      case .nearby: return [.read, .unsave, .share]
      }
    }
  }

  func setCategories(){
    let categories: Set<UNNotificationCategory> =
      Set(Category.allCases.map { category -> UNNotificationCategory in
        return UNNotificationCategory(
          identifier: category.identifier,
          actions: category.actions.map({ action -> UNNotificationAction in
            return UNNotificationAction(
              identifier: action.identifier,
              title: action.title,
              options: action.options)
          }),
          intentIdentifiers: [],
          options: [])
    })
    notificationCenter?.setNotificationCategories(categories)
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
    self.api.getPlace$(identifier)
      // TODO: threading?
      .subscribe(onNext: { [weak self] (result: Result<Place>) in
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
    self.api.getPlace$(identifier)
      .subscribe(onNext: { (result: Result<Place>) in
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
    updateBookmark(placeId: identifier, toSaved: save, completion: { _ in
      completionHandler()
    })
  }

  private func observeLocationManager() {
    let region$ =
      locationManager.didReceiveRegion$
        .debug("didReceiveRegion$", trimOutput: false)

    let regionEntry$ =
      region$.filterMap({ regionEvent -> FilterMap<CLCircularRegion> in
        guard case let .enter(region) = regionEvent else { return .ignore }
        return .map(region) })
    regionEntry$
      /* WIP: note entry for "visit" calculation on exit
      .do(onNext: { region -> Void in
        let now = Date()
        let identifier = region.identifier
        saveEntered(identifier, at: now)
      })
       */
      // fetch place, then fire its nearby notification
      .flatMap({ [unowned self] region -> Observable<Result<Place>> in
        let placeId = region.identifier
        return self.api.getPlace$(placeId)
      })
      .subscribe(onNext: { [unowned self] (result: Result<Place>) in
        switch result {
        case let .failure(error):
          print("NOOP ERROR: \(error)")
        case let .success(place):
          guard
            let placeName = place.name
            else { return print("MIA: place name") }
          let content = UNMutableNotificationContent()
          content.categoryIdentifier = Category.nearby.rawValue
          content.sound = UNNotificationSound.default
          content.title = "You're nearby \(placeName)!"
          content.body = "You saved \(placeName) to your list of restaurants. For a reason to go, read the highlights again."
          content.userInfo["place_id"] = place.identifier
          if let url = place.post?.url?.absoluteString {
            content.userInfo["post_url"] = url
          }
          guard // TODO: share attachment logic w/ notification service extension
            let imageURLString = place.imageURL?.absoluteString,
            let imageURL = URL(string: imageURLString),
            let imageData = NSData(contentsOf: imageURL),
            let image = UNNotificationAttachment.create("image.jpg", data: imageData, options: nil)
            else { return print("MIA: place imageURL") }
          content.attachments = [image]
          let request =
            UNNotificationRequest(
              identifier: UUID().uuidString,
              content: content,
              trigger: nil)
          guard
            let center = self.notificationCenter
            else { return print("MIA: notificationCenter") }
          center.add(request, withCompletionHandler: { (error) in
            if let error = error { print(error) }
          })
        }
      }).disposed(by: bag)

    /* WIP: instrument "visit" analytics event
    let regionExit$ =
      region$.filterMap({ regionEvent -> FilterMap<CLCircularRegion> in
        guard case let .exit(region) = regionEvent else { return .ignore }
        return .map(region) })
    regionExit$
      .subscribe(onNext: { region in
        let identifier = region.identifier
        guard
          let enteredAt = self.placeManager.getEnteredAt(identifier)
          else { return print("MIA: enteredAt \(identifier)") }
        let now = Date()
        let visitBeginsAt = enteredAt.adding(15.minutes)
        guard now.isAfterDate(visitBeginsAt, granularity: .second)
          else { return print("exited region too quickly for a visit")}
        // TODO
        // fire "visited" analytics event
      }).disposed(by: bag)
     */
  }


}

extension UNNotificationAttachment {

  static func create(_ imageFileName: String, data: NSData, options: [NSObject : AnyObject]?) -> UNNotificationAttachment? {
    let fileManager = FileManager.default
    let tmpSubFolderName = ProcessInfo.processInfo.globallyUniqueString
    let tmpSubFolderURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(tmpSubFolderName, isDirectory: true)
    do {
      try fileManager.createDirectory(at: tmpSubFolderURL, withIntermediateDirectories: true, attributes: nil)
      let imageFileIdentifier = imageFileName+".jpg"
      let fileURL = tmpSubFolderURL.appendingPathComponent(imageFileIdentifier)
      try data.write(to: fileURL, options: [])
      let imageAttachment = try UNNotificationAttachment(identifier: imageFileIdentifier, url: fileURL, options: options)
      return imageAttachment
    } catch let error {
      print("error \(error)")
    }
    return nil
  }

}
