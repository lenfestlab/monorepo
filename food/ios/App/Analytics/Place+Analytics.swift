extension Place {

  var analyticsCuisine : String {
    let categories = self.categories ?? []
    let cuisine = categories.map { $0.name ?? "" }.joined(separator: ",")
    return cuisine
  }

  var analyticsNeighborhood : String {
    let nabes = self.nabes ?? []
    let neighborhood = nabes.map { $0.name }.joined(separator: ",")
    return neighborhood
  }

  var analyticsPrice : String {
    var price = ""
    if let post = self.post {
      let prices = post.prices ?? []
      price = prices.map { "\($0)" }.joined(separator: ",")
    }

    return price
  }

  var analyticsReviewer : String {
    var reviewer = ""
    if let post = self.post {
      reviewer = post.author?.name ?? ""
    }

    return reviewer
  }

  var analyticsBells : String {
    var bells = ""
    if let post = self.post {
      if let rating = post.rating {
        bells = "\(rating)"
      }
    }

    return bells
  }

}
