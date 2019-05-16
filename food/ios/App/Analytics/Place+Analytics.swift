import RealmSwift

extension Place {

  private var separator: String {
    return AnalyticsManager.separator
  }

  var analyticsCuisine : String {
    return
      self.categories
        .filter({ $0.isCuisine })
        .compactMap({ $0.name })
        .joined(separator: separator)
  }

  var analyticsNeighborhood : String {
    return
      self.nabes
        .compactMap({ $0.name })
        .joined(separator: separator)
  }

  var analyticsPrice : String {
    guard let post = self.post else { return "" }
    return
      post.prices
        .compactMap({ "\($0)" })
        .joined(separator: separator)
  }

  var analyticsReviewer : String {
    return self.post?.author?.name ?? ""
  }

  var analyticsBells : String {
    guard let rating = post?.rating else { return "" }
    return "\(rating)"
  }

}
