import CoreLocation
import ObjectMapper
import ObjectMapperAdditions
import ObjectMapperAdditionsRealm
import RealmSwift

class Location: RealmSwift.Object, Mappable {
  required convenience init?(map: Map) {
    self.init()
  }

  var latitudeOpt = RealmOptional<Double>()
  var longitudeOpt = RealmOptional<Double>()

  var latitude: Double? {
    return latitudeOpt.value
  }
  var longitude: Double? {
    return longitudeOpt.value
  }

  func mapping(map: Map) {
    latitudeOpt <-
      (map["lat"], RealmOptionalTransform())
    longitudeOpt <-
      (map["lng"], RealmOptionalTransform())
  }

  var nativeLocation: CLLocation? {
    guard
      let lat = self.latitude,
      let lng = self.longitude
      else { return nil }
    return CLLocation(
      latitude: lat,
      longitude: lng)
  }

}
