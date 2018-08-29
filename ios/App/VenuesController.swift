import UIKit

class VenuesController: UITableViewController, LocationManagerDelegate {
  let dataStore = VenueDataStore()
  let locationManager = LocationManager()
  let notificationManager = NotificationManager()
  var venues:[Venue] = []
  
  func fetchData() {
    dataStore.retrieveVenues { (success, data, count) in
      self.venues = data
      if self.locationManager.authorized {
        self.notificationManager.trackVenues(venues: data)
      }
      self.tableView.reloadData()
    }
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    self.title = "Venues"
    self.tableView.rowHeight = 90
    locationManager.delegate = self
    locationManager.enableBasicLocationServices()
    notificationManager.requestAuthorization()
  }
  
  // MARK: - Location manager delegate

  func authorized(_ locationManager: LocationManager) {
    fetchData()
  }
  
  func notAuthorized(_ locationManager: LocationManager) {
    fetchData()
  }
  
  // MARK: - Table view data source
  
  override func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return venues.count
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier") ?? UITableViewCell(style: .subtitle, reuseIdentifier: "reuseIdentifier")
    let venue:Venue = self.venues[indexPath.row]
    cell.textLabel?.text = venue.title
    cell.detailTextLabel?.text = venue.blurb
    cell.detailTextLabel?.numberOfLines = 2
    cell.accessoryType = .disclosureIndicator
    return cell
  }

}

