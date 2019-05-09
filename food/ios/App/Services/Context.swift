struct Context {
  let api: Api
  let analytics: AnalyticsManager
  let cache: Cache
  let env: Env
  let locationManager: LocationManager
}

protocol Contextual {
  var context: Context { get set }
}

extension Contextual {
  var api: Api { return context.api }
  var analytics: AnalyticsManager { return context.analytics }
  var cache: Cache { return context.cache }
  var env: Env { return context.env }
  var locationManager: LocationManager { return context.locationManager }
}
