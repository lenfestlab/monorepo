//
//  GuideViewController.swift
//  App
//
//  Created by Ajay Chainani on 4/14/19.
//

import UIKit

class GuideViewController: PlacesViewController {

  init(analytics: AnalyticsManager, category: Category) {
    super.init(path: "places.json?categories=\(category.identifier)", analytics: analytics)
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    self.listViewController.controllerIdentifierKey = "guide"
    self.mapViewController.controllerIdentifierKey = "guide"
  }


}
