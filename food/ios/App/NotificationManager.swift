import UIKit
import UserNotifications
import CoreLocation
import Alamofire
import RxSwift
import RxSwiftExt
import SwiftDate
import Shared

protocol NotificationManagerDelegate: class {
  func present(_ vc: UIViewController, animated: Bool)
  func push(_ vc: UIViewController, animated: Bool)
  func openInlineBrowser(url: URL)
}

class NotificationManager: NSObject, UNUserNotificationCenterDelegate, Contextual {

  var context: Context

  weak var delegate: NotificationManagerDelegate?
  var notificationCenter: UNUserNotificationCenter?
  var authorizationStatus: UNAuthorizationStatus = .notDetermined

  func refreshAuthorizationStatus(completionHandler: @escaping (UNAuthorizationStatus) -> Void) {
    notificationCenter?.getNotificationSettings { (settings) in
      self.authorizationStatus = settings.authorizationStatus
      completionHandler(settings.authorizationStatus)
    }
  }

  init(context: Context) {
    self.context = context
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


  let notificationResponse$ =
    BehaviorSubject<UNNotificationResponse?>(value: nil)

  func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    didReceive response: UNNotificationResponse,
    withCompletionHandler completionHandler: @escaping () -> Void) {
    print("\n response"); print(response)
    self.notificationResponse$.onNext(response)
    let categoryId = response.notification.request.content.categoryIdentifier
    let actionId = response.actionIdentifier
    let userInfo = response.notification.request.content.userInfo
    let url = userInfo["url"] as? String
    let postURL = userInfo["post_url"] as? String
    let placeIdentifier = userInfo["place_id"] as? String

    guard let category = Category(rawValue: categoryId) else {
      print("MIA: category unspecified/unsupported")
      // if manual push from FIR w/ "url" property, open in safari
      return self.attemptOpenURL(url, completionHandler)
    }

    switch Action(rawValue: actionId) {
    case .none: // tapped notification body, not action button
      attemptShowPlace(category, placeIdentifier, completionHandler)
    case .some(let action):
      switch action {
      case .read:
        attemptReadPlace(category, placeIdentifier, postURL, completionHandler)
      case .save:
        attemptUpdatePlace(category, placeIdentifier, save: true, completionHandler)
      case .unsave:
        attemptUpdatePlace(category, placeIdentifier, save: false, completionHandler)
      case .share:
        attemptSharePlace(category, placeIdentifier, completionHandler)
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
    UIApplication.shared.open(url, options: [:], completionHandler: { _ in
      completionHandler()
    })
  }

  private func attemptShowPlace(
    _ category: Category,
    _ identifier: String?,
    _ completionHandler: @escaping ()->()) {
    guard let identifier = identifier else { return completionHandler() }
    api.getPlace$(identifier)
      .observeOn(Scheduler.main)
      .subscribe(onNext: { [weak self] (result: Result<Place>) in
        guard let `self` = self else { return completionHandler() }
        switch result {
        case .success(let place):
          self.analytics.log(
            .tapsNotificationDefaultTapToClickThrough(
              category,
              place: place,
              location: self.locationManager.latestCoordinate))
          let vc =
            DetailViewController(
              context: self.context,
              place: place)
          self.delegate?.push(vc, animated: true)
          completionHandler()
        case .failure(let error):
          print("NOOP error \(error)")
          completionHandler()
        }
      }).disposed(by: rx.disposeBag)
  }

  private func attemptReadPlace(
    _ category: Category,
    _ identifier: String?,
    _ urlString: String?,
    _ completionHandler: @escaping ()->()) {
    guard let identifier = identifier else { return completionHandler() }
    api.getPlace$(identifier)
      .observeOn(Scheduler.main)
      .subscribe(onNext: { [weak self] (result: Result<Place>) in
        guard let `self` = self else { return completionHandler() }
        switch result {
        case .success(let place):
          print("success \(place)")
          self.analytics.log(
            .tapsReadInNotificationCTA(
              category,
              place: place,
              location: self.locationManager.latestCoordinate))
          self.attemptOpenURL(urlString, completionHandler)
        case .failure(let error):
          print("NOOP error \(error)")
          completionHandler()
        }
      })
      .disposed(by: rx.disposeBag)
  }

  private func attemptSharePlace(
    _ category: Category,
    _ identifier: String?,
    _ completionHandler: @escaping () -> ()) {
    guard let identifier = identifier else { return completionHandler() }
    api.getPlace$(identifier)
      .observeOn(Scheduler.main)
      .subscribe(onNext: { [weak self] (result: Result<Place>) in
        switch result {
        case .success(let place):
          print("success \(place)")
          guard let `self` = self else { return completionHandler() }
          self.analytics.log(
            .tapsShareInNotificationCTA(
              category,
              place: place,
              location: self.locationManager.latestCoordinate))
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
          self.delegate?.present(vc, animated: true)
        case .failure(let error):
          print("NOOP error \(error)")
        }
        }, onCompleted: {
          completionHandler()
      }).disposed(by: rx.disposeBag)
  }

  private func attemptUpdatePlace(
    _ category: Category,
    _ placeId: String?,
    save: Bool,
    _ completionHandler: @escaping ()->()) {
    guard let placeId = placeId else { return completionHandler() }
    api.updateBookmark$(placeId, toSaved: save)
      .subscribe(onNext: { [weak self] bookmark in
        guard
          let `self` = self,
          let place = bookmark.place
          else { return }
        self.analytics.log(
          .tapsSaveInNotificationCTA(
            category,
            toSaved: save,
            place: place,
            location: self.locationManager.latestCoordinate))
      }, onCompleted: {
        completionHandler()
      })
      .disposed(by: rx.disposeBag)
  }

  enum Exception: Error {
    case missingSelf
    case missingPlaceName
    case missingPlaceImage
    case missingNotificationCenter
  }

  private func observeLocationManager() {
    locationManager.regionEntry$
      // record entry for "visit" calculations
      .flatMap({ [unowned self] region -> Observable<Bookmark> in
        let placeId = region.identifier
        return self.api.recordRegionChange$(placeId, isEntering: true)
      })
      // throttle nearby notifications for each place
      .filter({ bookmark in
        if self.env.isPreProduction { return true } // ...only in prod
        guard let lastNotifiedAt = bookmark.lastNotifiedAt else { return true }
        return lastNotifiedAt.isBeforeDate(7.days.ago, granularity: .second)
      })
      .flatMap({ [weak self] bookmark -> Observable<Bookmark> in
        guard let `self` = self else { throw Exception.missingSelf }
        guard
          let place = bookmark.place,
          let placeName = place.name
          else { throw Exception.missingPlaceName }
        let category = Category.nearby
        let content = UNMutableNotificationContent()
        content.categoryIdentifier = category.rawValue
        content.sound = UNNotificationSound.default
        content.title = "You're nearby \(placeName)!"
        content.body = "You saved \(placeName) to your list of restaurants."
        content.userInfo["place_id"] = place.identifier
        if let url = place.post?.url?.absoluteString {
          content.userInfo["post_url"] = url
        }
        guard
          let imageURLString = place.imageURL?.absoluteString,
          let imageURL = URL(string: imageURLString),
          let imageData = NSData(contentsOf: imageURL),
          let image = UNNotificationAttachment.create("image.jpg", data: imageData, options: nil)
          else { throw Exception.missingPlaceImage }
        content.attachments = [image]
        let request =
          UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil)
        guard
          let center = self.notificationCenter
          else { throw Exception.missingNotificationCenter }
        center.add(request, withCompletionHandler: { (error) in
          if let error = error { print(error) }
        })
        self.analytics.log(.notificationShown(
          category,
          place: place,
          location: self.locationManager.latestCoordinate))
        return self.api.recordNotification$(place.identifier)
      })
      .subscribe()
      .disposed(by: rx.disposeBag)

    locationManager.regionExit$
      .flatMap({ [unowned self] region -> Observable<Bookmark> in
        let placeId = region.identifier
        return self.api.recordRegionChange$(placeId, isEntering: false)
      })
      .subscribe()
      .disposed(by: rx.disposeBag)
  }

}

