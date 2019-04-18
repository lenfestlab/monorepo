import Alamofire
import RxAlamofire
import RxSwift
import RxCocoa
import Gloss

class Api {

  enum ApiError: Error {
    case parse
    case auth
  }

  let env: Env

  init(env: Env) {
    self.env = env
  }

  func getPlace$(_ identifier: String) -> Driver<Result<Place>> {
    return
      RxAlamofire
        .requestJSON(.get, "\(env.apiBaseUrlString)/places/\(identifier)")
        .map({ _response, json -> Result<Place> in
          guard
            let json = json as? JSON,
            let placeJSON = json["place"] as? JSON,
            let place = Place(json: placeJSON)
            else { return Result.failure(ApiError.parse) }
          return Result.success(place)
        })
        .asDriver(onErrorRecover: { error in
          return Driver.just(Result.failure(error))
        })
  }

}
