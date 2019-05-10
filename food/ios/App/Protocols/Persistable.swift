import RealmSwift

public protocol Persistable {

  associatedtype RealmObject: RealmSwift.Object

  init(_ object: RealmObject)

}
