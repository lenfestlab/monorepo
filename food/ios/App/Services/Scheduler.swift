import RxSwift

struct Scheduler {
  static let main = MainScheduler.instance
  static let background = ConcurrentDispatchQueueScheduler(qos: .background)
}
