import Foundation

class MapPlace : NSObject {
  var place: Place
  var annotation : ABPointAnnotation?

  init(place: Place) {
    self.place = place
    self.annotation = ABPointAnnotation(place: place)
  }
}
