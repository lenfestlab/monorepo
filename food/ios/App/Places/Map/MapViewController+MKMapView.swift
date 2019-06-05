import UIKit
import MapKit

extension MKMapView {
  func center(_ center: CLLocationCoordinate2D,
              span: MKCoordinateSpan = MKCoordinateSpan(latitudeDelta: 0.04, longitudeDelta: 0.04)) {
    let region:MKCoordinateRegion = MKCoordinateRegion(center: center, span: span)
    self.setRegion(region, animated: true)
  }
  func center(_ region: MKCoordinateRegion) {
    self.setRegion(region, animated: true)
  }
}


private let mapPinIdentifier = "pin"

extension MapViewController : MKMapViewDelegate {

  func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
    let renderer = MKPolygonRenderer(polygon: overlay as! MKPolygon)
    renderer.fillColor = UIColor.black.withAlphaComponent(0.5)
    renderer.strokeColor = UIColor.red
    renderer.lineWidth = 10
    return renderer
  }

  func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
    let coordinate = userLocation.coordinate
    self.locationManager.latestLocation = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
  }

  func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
    if annotation is MKUserLocation {
      //return nil so map view draws "blue dot" for standard user location
      return nil
    }

    let index = (annotation as! ABPointAnnotation).index

    let  pinView = ABAnnotationView(annotation: annotation, reuseIdentifier: mapPinIdentifier)
    pinView.tag = index
    pinView.isSelected = (annotation.title == currentPlace?.place.name)
    pinView.showsIndex = self.showIndex
    pinView.setIndex(index)
    let btn = UIButton(type: .detailDisclosure)
    pinView.rightCalloutAccessoryView = btn

    return pinView
  }

  func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
    let indexPath = IndexPath(row: view.tag, section: 0)
    let mapPlace = mapPlaces[indexPath.row]
    let place = mapPlace.place
    analytics.log(.tapsOnPin(place: place))
    scrollToItem(at: indexPath)
    self.currentPlace = mapPlace
  }

}

