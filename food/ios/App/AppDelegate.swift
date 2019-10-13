import UIKit
import Firebase
import FirebaseMessaging
import SafariServices
import AlamofireNetworkActivityLogger
import RxSwift
import RxSwiftExt
import SwiftDate
import CoreLocation
import NSObject_Rx
import Sentry
import CoreLocation

typealias Result<T> = Swift.Result<T, Error>
typealias LaunchOptions = [UIApplication.LaunchOptionsKey: Any]?

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var context: Context!

  var lastViewedURL: URL?
  var window: UIWindow?
  var analytics: AnalyticsManager!
  var env: Env!
  var api: Api!
  var cache: Cache!
  var locationManager: LocationManager!
  var notificationManager: NotificationManager!
  var mainController: MainController!
  var tabController: TabBarViewController!

  class func shared() -> AppDelegate {
    return UIApplication.shared.delegate as! AppDelegate
  }

  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: LaunchOptions) -> Bool {
    self.env = Env()

    if env.networkLogLevel != .off {
      NetworkActivityLogger.shared.level = env.networkLogLevel
      NetworkActivityLogger.shared.startLogging()
    }

    self.addCrashReporting(env: env)

    FirebaseApp.configure()
    Messaging.messaging().delegate = self
    application.registerForRemoteNotifications()

    self.cache = Cache(env: env)
    self.locationManager = LocationManager(env: env)
    self.analytics = AnalyticsManager(env: env, locationManager: locationManager)
    self.api =
      Api(
        env: env,
        cache: cache,
        locationManager: locationManager)
    self.context =
      Context(
        api: api,
        analytics: analytics,
        cache: cache,
        env: env,
        locationManager: locationManager)
    self.notificationManager = NotificationManager(context: context)

    window = UIWindow(frame: UIScreen.main.bounds)

    let introController = IntroViewController(analytics: self.analytics)
    self.mainController = MainController(rootViewController: introController)
    self.notificationManager.delegate = self

    self.syncData()
    self.observeFirstTouch()
    self.observeTrackablePlaces()
    self.observeLocation()

    if onboardingIncomplete {
      window!.rootViewController = self.mainController
    } else {
      self.showHomeScreen()
    }
    window!.makeKeyAndVisible()
    return true
  }

  private var onboardingComplete: Bool {
    return UserDefaults.standard.bool(forKey: "onboarding-completed")
  }
  private var onboardingIncomplete: Bool {
    return !onboardingComplete
  }

  private func observeTrackablePlaces() -> Void {
    // Track viewed & saved places for nearby alerts and visit analytics.
    // > Core Location prevents any single app from monitoring more than 20 regions simultaneously.
    // - https://apple.co/2YIGoDH
    Observable.combineLatest(
      locationManager.significantLocation$,
      cache.bookmarkedPlaces$,
      cache.viewedPlaces$)
      .map({ (location, bookmarkedPlaces, viewedPlaces) -> [CLCircularRegion] in
        let bookmarked = bookmarkedPlaces.compactMap({$0.region})
        let viewed = viewedPlaces.compactMap({$0.region})
        let union = Array(Set(bookmarked).union(Set(viewed)))
        let sorted = union.sorted(by: { (r1, r2) -> Bool in
          let d1 = location.coordinate.distance(from: r1.center)
          let d2 = location.coordinate.distance(from: r2.center)
          return d1 < d2
        })
        let nearest: [CLCircularRegion] = Array(sorted.prefix(20))
        return nearest
      })
      .observeOn(Scheduler.background)
      .distinctUntilChanged()
      .subscribe(onNext: { [weak self] regions in
        self?.locationManager.resetRegionMonitoring(latestRegions: regions)
      })
      .disposed(by: rx.disposeBag)
  }

  func showPermissions() {
    mainController.pushViewController(
      PermissionsViewController(context: context),
      animated: false)
  }

  func showNotifications() {
    mainController.pushViewController(
      NotificationViewController(
        analytics: analytics,
        notificationManager: notificationManager),
      animated: false)
  }

  func showHomeScreen() {
    self.tabController =
      TabBarViewController(
        context: context,
        notificationManager: notificationManager)
    window!.rootViewController = self.tabController
  }

  func showEmailRegistration() {
    mainController.pushViewController(
      EmailViewController(context: self.context),
      animated: false)
  }


  enum RemoteNotificationType: String {
    case location
    case visitCheck = "visit_check"
  }

  func application(
    _ application: UIApplication,
    didReceiveRemoteNotification
    userInfo: [AnyHashable : Any],
    fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult
    ) -> Void) {
    guard
      let typeString  = userInfo["type"] as? String,
      let type = RemoteNotificationType(rawValue: typeString)
      else {
        print("MIA: 'type' or its value")
        return completionHandler(.noData) }
    switch type {
    case .location:
      // NOTE: wait long enough for location update ...
      let queue = DispatchQueue.main
      queue.asyncAfter(deadline: 3.seconds.fromNow, execute: { [weak self] in
        guard
          let `self` = self,
          let latestLocation = self.locationManager.latestLocation
          else { return completionHandler(.noData) }
        self.analytics.logLocationChange(latestLocation)
        // NOTE: wait long enough for GA request too complete
        queue.asyncAfter(deadline: 3.seconds.fromNow, execute: {
          completionHandler(.newData)
        })
      })
    case .visitCheck: // NOTE: DEPRECATED
      completionHandler(.noData)
    }
  }

  enum VisitError: Error {
    case selfMIA
    case tooShort
    var localizedDescription: String {
      return "visit"
    }
  }

  private func observeLocation() -> Void {
    let entry$ =
      locationManager.regionEntry$
        .flatMapLatest({ [unowned self] region -> Observable<PlaceEvent> in
          if let place: Place = self.cache.get(region.identifier) {
            self.analytics.log(.placeEvent(kind: .entered, place: place))
          }
          return self.api.recordPlaceEvent$(region.identifier, .entered)
        })
    let exit$ =
      locationManager.regionExit$
        .flatMapLatest({ [unowned self] region -> Observable<PlaceEvent> in
          if let place: Place = self.cache.get(region.identifier) {
            self.analytics.log(.placeEvent(kind: .exited, place: place))
          }
          return self.api.recordPlaceEvent$(region.identifier, .exited)
        })

    let visit$ =
      exit$.flatMap { [unowned self] placeEvent -> Observable<PlaceEvent> in
        guard
          let enteredAt = placeEvent.lastEnteredAt,
          let exitedAt = placeEvent.lastExitedAt,
          enteredAt < exitedAt,
          enteredAt.isBeforeDate(10.minutes.ago, granularity: .second)
          else { throw VisitError.tooShort }

        let latestCoordinate = self.locationManager.latestCoordinate

        let placeId = placeEvent.placeId
        return
          self.api.getPlace$(placeId)
            .filterMap({ result -> FilterMap<Place> in
              guard case let .success(place) = result else { return .ignore }
              return .map(place)
            })
            .flatMap({ [weak self] place -> Observable<PlaceEvent> in
              guard let `self` = self else { throw VisitError.selfMIA }
              // Determine upstream events that included place in geofence list
              // Currently, must have viewed place to setup its geofence
              var triggers: [String] = ["viewed"]
              if let _: Bookmark = self.cache.get(placeEvent.placeId) {
                triggers.append("saved")
              }
              self.analytics.log(.visited(
                place: place,
                coordinate: latestCoordinate,
                triggers: triggers))
              return self.api.recordPlaceEvent$(placeId, .visited)
            })
        }

    let locationStatus$ =
      locationManager.status$
        .do(onNext: { [weak self] status in
          self?.analytics.log(.latestLocationPermission(status: status))
        })

    Observable.zip(entry$, visit$, locationStatus$)
      .ignoreErrors({ [weak self] error -> Bool in
        self?.analytics.log(.error(error))
        return true
      })
      .subscribe()
      .disposed(by: rx.disposeBag)
  }

  private func addCrashReporting(env: Env) -> Void {
    do {
      Client.shared = try Client(dsn: env.get(.sentryDSN))
      Client.shared?.environment =  env.name.full
      Client.shared?.enableAutomaticBreadcrumbTracking()
      Client.shared?.trackMemoryPressureAsEvent()
      try Client.shared?.startCrashHandler()
    } catch let error {
      print(error.localizedDescription)
    }
  }

  private func syncData() -> Void {

    let updateDefaultPlaces$ =
      cache.asyncOpen$
        .do(onNext: { [unowned self] realm in
          if self.onboardingComplete && realm.isEmpty {
            HUD.change(.show)
          }
        })
        .flatMap({ [unowned self] _ -> Observable<CLLocation> in
          return self.locationManager.latestOrDefaultLocation$
        })
        .flatMapLatest({ [unowned self] location -> Observable<[Place]> in
          let coordinate = location.coordinate
          let lat = coordinate.latitude
          let lng = coordinate.longitude
          return self.api.updateDefaultPlaces$(lat: lat, lng: lng)
        })
        .do(onNext: { _ in
          HUD.change(.hide)
        })
        .mapTo(true)

    let updateBookmarks$ =
      api.updateBookmarks$()
        .mapTo(true)

    let updatePlaceEvents$ =
      api.getPlaceEvents$()
        .mapTo(true)

    cache.asyncOpen$
      .flatMapFirst({ _ -> Observable<[Bool]> in
        return Observable.zip([
          updateDefaultPlaces$,
          updateBookmarks$,
          updatePlaceEvents$,
        ])
      })
      .subscribe()
      .disposed(by: rx.disposeBag)
  }

  private func observeFirstTouch() -> Void {
    guard let window = self.window else { return }
    let notificationResponse$ = notificationManager.notificationResponse$
    let anyTouch$ = window.rx.methodInvoked(#selector(UIView.hitTest(_:with:)))
    anyTouch$.withLatestFrom(notificationResponse$)
      .take(1)
      .subscribe(onNext: { [unowned self] response in
        self.analytics.log(.appLaunched((response != nil)
          ? .notification
          : .direct))
      }).disposed(by: rx.disposeBag)
  }

}

extension AppDelegate: MessagingDelegate {

  func messaging(_ messaging: Messaging, didReceiveRegistrationToken gcmToken: String) {
    api.updateGcmToken$(gcmToken)
      .subscribe(onError: { error in
        print("FAIL: sync GCM token \(error.localizedDescription)")
      })
      .disposed(by: rx.disposeBag)

    // NOTE: shared topic for all notification types; fork behavior on payload
    let topic = "all"
    Messaging.messaging().subscribe(toTopic: topic) { error in
      if let errorDesc: String = error?.localizedDescription {
        print("ERROR: gcm: failed to subscribe to topic \(topic) - \(errorDesc)")
      }
    }
  }

}

extension AppDelegate: NotificationManagerDelegate {

  func present(_ vc: UIViewController, animated: Bool) {
    guard let presentingVC = self.window?.rootViewController else {
      return print("MIA: rootVC")
    }
    if let currentlyPresentedVC = presentingVC.presentedViewController  {
      currentlyPresentedVC.dismiss(animated: animated) {
        presentingVC.present(vc, animated: animated, completion: nil)
      }
    } else {
      presentingVC.present(vc, animated: animated, completion: nil)
    }
  }

  func openInlineBrowser(url: URL) {
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

  func push(_ vc: UIViewController, animated: Bool) {
    // TODO: refactor VC routing arch, else:
    // > Warning: Attempt to present <App.DetailViewController...> on <App.MainController...> whose view is not in the window hierarchy!
    guard
      let rootVC = self.window?.rootViewController
      else { return print("MIA: root VC") }
    if let targetVC = rootVC as? UINavigationController {
      targetVC.pushViewController(vc, animated: animated)
    } else if let targetVC = rootVC as? UITabBarController {
      guard let selVC = targetVC.selectedViewController else { return print("MIA: tab selected VC") }
      if let selVCisNavVC = selVC as? UINavigationController {
        selVCisNavVC.pushViewController(vc, animated: animated)
      } else {
        guard let selNavVC = selVC.navigationController else { return print("MIA: tab selected vc nav vc") }
        selNavVC.pushViewController(vc, animated: animated)
      }
    } else {
      print("error: unknown root VC class")
    }
  }

}

// https://gist.github.com/Thomvis/b378f926b6e1a48973f694419ed73aca
extension Int {
  var seconds: DispatchTimeInterval {
    return DispatchTimeInterval.seconds(self)
  }
  var second: DispatchTimeInterval {
    return seconds
  }
  var milliseconds: DispatchTimeInterval {
    return DispatchTimeInterval.milliseconds(self)
  }
  var millisecond: DispatchTimeInterval {
    return milliseconds
  }
}
extension DispatchTimeInterval {
  var fromNow: DispatchTime {
    return DispatchTime.now() + self
  }
}
