import MapKit

class ABPointAnnotation : MKPointAnnotation {
  var index: Int = 0

  init(place: Place) {
    super.init()
    self.coordinate = place.coordinate()
    self.title = place.title
  }
}
