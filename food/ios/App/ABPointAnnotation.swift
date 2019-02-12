import MapKit

class ABPointAnnotation : MKPointAnnotation {
  var index: Int = 0

  init(place: Place) {
    super.init()
    self.coordinate = place.coordinate()
    self.title = place.name
  }

}

class ABAnnotationView : MKAnnotationView {

  override var isSelected: Bool {
    didSet {
      if isSelected {
        self.image = UIImage(named: "selected-pin")
      } else {
        self.image = UIImage(named: "pin")
      }
    }
  }

  override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
    super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
    self.image = UIImage(named: "pin")
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

}
