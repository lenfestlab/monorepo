import Foundation
import RealmSwift

@objc protocol PartialUpdatable where Self: RealmSwift.Object {
  @objc func asPartialDictionary() -> NSMutableDictionary
  @objc func localProperties() -> [String]
  @objc func includePropertyNamed(_ name: String) -> Bool
}

extension RealmSwift.Object {

  @objc func asDictionary() -> NSMutableDictionary {
    return objectSchema.properties.reduce([:]) { (result, property) in
      let propName = property.name
      let propValue = self.value(forKey: propName)
      result[propName] = propValue
      return result
    }
  }

  @objc func asPartialDictionary() -> NSMutableDictionary {
    let props = objectSchema.properties
    let partialProps = props.filter { includePropertyNamed($0.name) }
    return partialProps.reduce([:]) { (result, property) in
      let propName = property.name
      let propValue = self.value(forKey: propName)
      if let partialableValue = propValue as? PartialUpdatable {
        result[propName] = partialableValue.asPartialDictionary()
      } else {
        result[propName] = propValue
      }
      return result
    }
  }

  @objc func localProperties() -> [String] {
    return []
  }

  @objc func includePropertyNamed(_ name: String) -> Bool {
    return !localProperties().contains(name)
  }
}

extension Bookmark: PartialUpdatable {}

extension Place: PartialUpdatable {
  override func localProperties() -> [String] {
    return ["distanceOpt"]
  }
}
