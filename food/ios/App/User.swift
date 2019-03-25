import UIKit

extension Place {

  static func contains(identifier: String) -> Bool {
    let array = identifiers()
    return array.contains(identifier)
  }

  static func save(identifier: String) {
    var array = self.identifiers()
    array.append(identifier)
    array = Array(Set(array))

    save(identifiers: array)
  }

  static func remove(identifier: String) {
    var array = self.identifiers()
    if let index = array.index(of: identifier) {
      array.remove(at: index)
    }
    array = Array(Set(array))

    save(identifiers: array)
  }

  static func save(identifiers: Array<String>) {
    let defaults = UserDefaults.standard
    defaults.set(identifiers, forKey: key)
    defaults.synchronize()
  }

  static func identifiers() -> [String] {
    let defaults = UserDefaults.standard
    let array = defaults.stringArray(forKey: key) ?? [String]()
    return array
  }

}
