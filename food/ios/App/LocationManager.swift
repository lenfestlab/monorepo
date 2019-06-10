import UIKit
import CoreLocation
import UserNotifications
import SwiftDate
import RxSwift
import RxSwiftExt
import RxRelay
import RxCoreLocation

extension Notification.Name {
  static let locationAuthorizationUpdated = Notification.Name("locationAuthorizationUpdated")
}

extension CLAuthorizationStatus: CustomStringConvertible, CustomDebugStringConvertible {
  public var description: String {
    switch self {
    case .notDetermined: return "not-determined"
    case .restricted: return "restricted"
    case .denied: return "denied"
    case .authorizedAlways: return "authorized-always"
    case .authorizedWhenInUse: return "authorized-when-in-use"
    @unknown default: fatalError()
    }
  }
  public var debugDescription: String {
    return description
  }
}

@objc protocol LocationManagerAuthorizationDelegate: class {
  func authorized(_ locationManager: LocationManager, status: CLAuthorizationStatus)
  func notAuthorized(_ locationManager: LocationManager, status: CLAuthorizationStatus)
}

class LocationManager: NSObject, CLLocationManagerDelegate {

  var authorizationStatus: CLAuthorizationStatus = .notDetermined {
    didSet {
      NotificationCenter.default.post(name: .locationAuthorizationUpdated, object: nil)
    }
  }

  lazy var status$ = {() -> Observable<CLAuthorizationStatus> in
    return locationManager.rx.didChangeAuthorization.map({ (manager, status) -> CLAuthorizationStatus in
      return status
    })
  }()

  let defaultCoordinate =
    CLLocationCoordinate2D(
      latitude: 39.9526,
      longitude: -75.1652)

  lazy var defaultLocation = {() -> CLLocation in
    return
      CLLocation(
        latitude: defaultCoordinate.latitude,
        longitude:defaultCoordinate.longitude)
  }()

  weak var authorizationDelegate: LocationManagerAuthorizationDelegate?
  private var locationManager:CLLocationManager

  func startMonitoringSignificantLocationChanges() {
    locationManager.startMonitoringSignificantLocationChanges()
  }

  func startUpdatingLocation() {
    locationManager.startUpdatingLocation()
  }

  let env: Env
  init(env: Env) {
    self.env = env
    locationManager = CLLocationManager()
    locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
    locationManager.pausesLocationUpdatesAutomatically = false
    locationManager.allowsBackgroundLocationUpdates = true
    super.init()
    locationManager.delegate = self
  }

  func authorized() -> Bool {
    if self.authorizationStatus == .authorizedWhenInUse {
      return true
    }
    if self.authorizationStatus == .authorizedAlways {
      return true
    }
    return false
  }

  func enableBasicLocationServices() {
    let status = CLLocationManager.authorizationStatus()
    authorizationStatusUpdated(status: status)
  }

  func authorizationStatusUpdated(status: CLAuthorizationStatus) {
    self.authorizationStatus = status
    switch status {
    case .notDetermined:
      // Request when-in-use authorization initially
      locationManager.requestAlwaysAuthorization()
    case .restricted, .denied:
      guard let authDelegate = authorizationDelegate else { return }
      authDelegate.notAuthorized(self, status: status)
    case .authorizedWhenInUse, .authorizedAlways:
      self.startMonitoringSignificantLocationChanges()
      guard let authDelegate = authorizationDelegate else { return }
      authDelegate.authorized(self, status: status)
    @unknown default: fatalError()
    }
  }

  func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
    if status != .notDetermined {
      authorizationStatusUpdated(status: status)
    }
  }

  private let location$$ = BehaviorRelay<CLLocation?>(value: nil)

  public var latestLocation: CLLocation? {
    set {
      location$$.accept(newValue)
    }
    get {
      return location$$.value
    }
  }

  public var latestCoordinate: CLLocationCoordinate2D? {
    return latestLocation?.coordinate
  }

  lazy var significantLocation$ = { () -> Observable<CLLocation> in
    return locationManager.rx.location
      .unwrap()
      .distinctUntilChanged()
      .do(onNext: { [unowned self] location in
        self.location$$.accept(location)
      })
      .share(replay: 1, scope: .whileConnected)
  }()

  lazy var location$ = {() -> Observable<CLLocation> in
    return location$$
      .unwrap()
      .asObservable()
      .share(replay: 1, scope: .whileConnected)
  }()

  func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
    print("locationManager failed for region with identifier: \(region!.identifier) ")
    print(error)
  }

  func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    print("locationManager failed with the following error: \(error)")
  }

  enum RegionEvent {
    case enter(CLCircularRegion)
    case exit(CLCircularRegion)
  }
  var didReceiveRegion$: Observable<RegionEvent> {
    return
      locationManager.rx.didReceiveRegion
        .observeOn(Scheduler.background)
        .filterMap({ (manager: CLLocationManager, region: CLRegion, state: CLRegionEventState) -> FilterMap<RegionEvent> in
          guard let region = region as? CLCircularRegion else { return .ignore }
          switch state {
          case .enter: return .map(.enter(region))
          case .exit: return .map(.exit(region))
          case .monitoring: return .ignore
          }
        })
        .share()
  }

  var regionEntry$: Observable<CLCircularRegion> {
    return
      didReceiveRegion$
        .filterMap({ regionEvent -> FilterMap<CLCircularRegion> in
          guard case let .enter(region) = regionEvent else { return .ignore }
          return .map(region) })
        .share()
  }

  var regionExit$: Observable<CLCircularRegion> {
    return
      self.didReceiveRegion$
        .filterMap({ regionEvent -> FilterMap<CLCircularRegion> in
          guard case let .exit(region) = regionEvent else { return .ignore }
          return .map(region) })
        .share()
  }

  lazy var placemark$ = { () -> Observable<CLPlacemark> in
    return self.locationManager.rx.placemark.share()
  }()

  func resetRegionMonitoring(latestRegions regions: [CLCircularRegion]) {
    let manager = locationManager
    let new: Set<CLCircularRegion> = Set(regions)
    let monitoredRegions =
      manager.monitoredRegions.compactMap { region -> CLCircularRegion? in
        guard let circularRegion = region as? CLCircularRegion else { return nil }
        return circularRegion
    }
    let old: Set<CLCircularRegion> = Set(monitoredRegions)
    let additions = new.subtracting(old)
    let removals = old.subtracting(new)
    removals.forEach { manager.stopMonitoring(for: $0) }
    additions.forEach { manager.startMonitoring(for: $0) }
  }

  func makeLocation(lat: Double?, lng: Double?) -> CLLocation? {
    guard let lat = lat, let lng = lng else { return nil }
    return CLLocation(latitude: lat, longitude: lng)
  }

  lazy var latestOrDefaultLocation$ = {()-> Observable<CLLocation> in
    status$
      .flatMap({ [unowned self] status -> Observable<CLLocation> in
        switch status {
        case .authorizedAlways, .authorizedWhenInUse:
          return self.significantLocation$
        case .denied, .notDetermined, .restricted:
          return Observable.just(self.defaultLocation)
        @unknown default: fatalError()
        }
      })
  }()

}
