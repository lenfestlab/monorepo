import MapKit

class ABPointAnnotation : MKPointAnnotation {
  var index: Int = 0
  let identifier: String

  init(place: Place) {
    identifier = place.identifier
    super.init()
    self.coordinate = place.coordinate
    self.title = place.name
  }

}

class ABAnnotationView : MKAnnotationView {

  var indexLabel: UILabel! = {
    let label = UILabel(frame: .zero)
    label.backgroundColor = .clear
    label.textColor = .white
    label.textAlignment = .center
    label.font = UIFont.mediumExtraSmall
    label.adjustsFontSizeToFitWidth = true
    label.text = "1"
    return label
  }()

  override var isSelected: Bool {
    didSet {
      updatePin()
    }
  }

  var showsIndex: Bool = false {
    didSet {
      updatePin()
      self.indexLabel.isHidden = !showsIndex
    }
  }

  func updatePin() {
    if isSelected {
      if showsIndex {
        self.image = UIImage(named: "selected-pin-index")
      }  else {
        self.image = UIImage(named: "selected-pin")
      }
    } else {
      if showsIndex {
        self.image = UIImage(named: "pin-index")
      }  else {
        self.image = UIImage(named: "pin")
      }
    }
  }

  override func layoutSubviews() {
    self.indexLabel.frame = CGRect(x: 1, y: 0, width: self.frame.width - 2, height: self.frame.width + 2)
  }

  override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
    super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
    self.image = UIImage(named: "pin")
    self.addSubview(self.indexLabel)
    self.indexLabel.isHidden = true
  }

  func setIndex(_ index: Int) {
    self.indexLabel.text = "\(index + 1)"
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

}
