//
//  ViewController.swift
//  A1_A2_iOS_Abhilash_c0880745
//
//  Created by user223764 on 1/20/23.
//

import UIKit
import MapKit

class ViewController: UIViewController,
    CLLocationManagerDelegate, MKMapViewDelegate {
    var locationManager = CLLocationManager()
    var locationsArr = [CLLocationCoordinate2D]()
    @IBOutlet weak var mapv: MKMapView!
    @IBOutlet weak var navigationbtn: UIButton!

    var dropPinCount = 1

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapv.isZoomEnabled = true
        mapv.showsUserLocation = true
        mapv.delegate = self
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
      
        addSingleTap()
        
    
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let userLocation = locations[0]
        
        let latitude = userLocation.coordinate.latitude
        let longitude = userLocation.coordinate.longitude
        
        displayLocation(latitude: latitude, longitude: longitude, title: "Your Location", subtitle: "you are here")
        
    }
    
    
    func displayLocation(latitude: CLLocationDegrees, longitude: CLLocationDegrees, title: String, subtitle: String) {
        
       let latDelta: CLLocationDegrees = 51.2538
       let lngDelta: CLLocationDegrees = 85.3232
    
        let span = MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: lngDelta)
        let location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let region = MKCoordinateRegion(center: location, span: span)
        
        mapv.setRegion(region, animated: true)
        
    }

    
    @objc func dropPin(sender: UITapGestureRecognizer) {
        
    
        if(dropPinCount <= 3){
            // add annotation
            let touchPoint = sender.location(in: mapv)
            let coordinate = mapv.convert(touchPoint, toCoordinateFrom: mapv)
            let annotation = MKPointAnnotation()
            let loc: CLLocation = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
            var address = ""
            CLGeocoder().reverseGeocodeLocation(loc) { (placemarks, error) in
                if error != nil {
                    print(error!)
                } else {
                    if let placemark = placemarks?[0] {
                        
                        if placemark.locality != nil {
                            address += placemark.locality! + "\n"
                        }
                        
                        annotation.title = address
                        
                    }
                    
                }
            }
            annotation.coordinate = coordinate
            mapv.addAnnotation(annotation)
            
            
            
            locationsArr.append(coordinate)
            
        }
        
        if( dropPinCount == 3){
            addPolygon()
            calculateDistanceBetweenMapPoints()
            
        }
        
        dropPinCount += 1
        
    }
    
    //MARK: - single tap func
    func addSingleTap() {
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(dropPin))
        singleTap.numberOfTapsRequired = 1
        mapv.addGestureRecognizer(singleTap)
    }
    

     func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
         if overlay is MKCircle {
             let rendrer = MKCircleRenderer(overlay: overlay)
             rendrer.fillColor = UIColor.black.withAlphaComponent(0.5)
             rendrer.strokeColor = UIColor.green
             rendrer.lineWidth = 2
             return rendrer
         } else if overlay is MKPolyline {
             let rendrer = MKPolylineRenderer(overlay: overlay)
             rendrer.strokeColor = UIColor.blue
             rendrer.lineWidth = 3
             return rendrer
         } else if overlay is MKPolygon {
             let rendrer = MKPolygonRenderer(overlay: overlay)
             rendrer.fillColor = UIColor.red.withAlphaComponent(0.6)
             rendrer.strokeColor = UIColor.green
             rendrer.lineWidth = 2
             return rendrer
         }
         return MKOverlayRenderer()
     }
    
    
    func addPolygon() {
        let polygon = MKPolygon(coordinates: locationsArr, count: locationsArr.count)
        mapv.addOverlay(polygon)
    }
    
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if annotation is MKUserLocation {
            
            return nil
            
        }else{
            let numberRegEx  = ".*[0-9]+.*"
            let testCase = NSPredicate(format:"SELF MATCHES %@", numberRegEx)
            let containsNumber = testCase.evaluate(with: annotation.title)
            
            if(containsNumber){
                return nil
            }
            else{
                let annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "droppablePin")
                annotationView.animatesDrop = true
                annotationView.pinTintColor = #colorLiteral(red: 0.1764705926, green: 0.01176470611, blue: 0.5607843399, alpha: 1)
                annotationView.canShowCallout = true
                return annotationView
            }
        }
    }
    
    func calculateDistanceBetweenMapPoints(){
        
        
        let coordinate1 = CLLocation(latitude: locationsArr[0].latitude, longitude: locationsArr[0].longitude)
        let coordinate2 = CLLocation(latitude: locationsArr[1].latitude, longitude: locationsArr[1].longitude)
        let coordinate3 = CLLocation(latitude: locationsArr[2].latitude, longitude: locationsArr[2].longitude)

        let distanceInMetersFirst = Int(coordinate1.distance(from: coordinate2))
        let distanceInMetersSecond = Int(coordinate2.distance(from: coordinate3))
        let distanceInMetersThird = Int(coordinate3.distance(from: coordinate1))
        
        // display distance between first two points
        
        let latitudeMidOne = ((locationsArr[0].latitude + locationsArr[1].latitude) / 2)
        let longitudeMidOne = ((locationsArr[0].longitude + locationsArr[1].longitude) / 2)
        
        let location1 = CLLocationCoordinate2D(latitude: latitudeMidOne, longitude: longitudeMidOne)
        let annotation1 = MKPointAnnotation()
        annotation1.title = String(distanceInMetersFirst)
        annotation1.subtitle = "(In Meters)"
        annotation1.coordinate = location1
        mapv.addAnnotation(annotation1)
        // display distance between second third points
        
        let latitudeMidTwo = ((locationsArr[1].latitude + locationsArr[2].latitude) / 2)
        let longitudeMidTwo = ((locationsArr[1].longitude + locationsArr[2].longitude) / 2)
        
        let location2 = CLLocationCoordinate2D(latitude: latitudeMidTwo, longitude: longitudeMidTwo)
        let annotation2 = MKPointAnnotation()
        annotation2.title = String(distanceInMetersSecond)
        annotation2.subtitle = "(In Meters)"
        annotation2.coordinate = location2
        mapv.addAnnotation(annotation2)
        
        // display distance between second third points
        
        let latitudeMidThree = ((locationsArr[2].latitude + locationsArr[0].latitude) / 2)
        let longitudeMidThree = ((locationsArr[2].longitude + locationsArr[0].longitude) / 2)
        
        let location3 = CLLocationCoordinate2D(latitude: latitudeMidThree, longitude: longitudeMidThree)
        let annotation3 = MKPointAnnotation()
        annotation3.title = String(distanceInMetersThird)
        annotation3.subtitle = "(In Meters)"
        annotation3.coordinate = location3
        mapv.addAnnotation(annotation3)
        
        
        navigationbtn.isHidden = false
        
    }
    
    //MARK: - draw route between two places
    @IBAction func drawRoute(_ sender: UIButton) {
        mapv.removeOverlays(mapv.overlays)
        
        
        self.mapv.annotations.forEach {
            print($0.subtitle)
          if !($0 is MKUserLocation) && ($0.subtitle == "(In Meters)" ) {
            self.mapv.removeAnnotation($0)
          }
        }
        
        // draw 1st route
        fetchRoutes(_startCoordinate: locationsArr[0], _endCoordinate: locationsArr[1])
        
        // draw 2nd route
        fetchRoutes(_startCoordinate: locationsArr[1], _endCoordinate: locationsArr[2])
        
        // draw 3rd route
        fetchRoutes(_startCoordinate: locationsArr[2], _endCoordinate: locationsArr[0])
        

    }
    
    
    func fetchRoutes(_startCoordinate : CLLocationCoordinate2D, _endCoordinate : CLLocationCoordinate2D){
        
        let sourcePlaceMark1 = MKPlacemark(coordinate: _startCoordinate)
        let destinationPlaceMark2 = MKPlacemark(coordinate: _endCoordinate)
        
        // request a direction
        let directionRequest = MKDirections.Request()
        
        // assign the source and destination properties of the request
        directionRequest.source = MKMapItem(placemark: sourcePlaceMark1)
        directionRequest.destination = MKMapItem(placemark: destinationPlaceMark2)
        
        // transportation type
        directionRequest.transportType = .automobile
        
        // calculate the direction
        let directions = MKDirections(request: directionRequest)
        directions.calculate { (response, error) in
            guard let directionResponse = response else {return}
            // create the route
            let route = directionResponse.routes[0]
            // drawing a polyline
            self.mapv.addOverlay(route.polyline, level: .aboveRoads)
            
            // define the bounding map rect
            let rect = route.polyline.boundingMapRect
            self.mapv.setVisibleMapRect(rect, edgePadding: UIEdgeInsets(top: 100, left: 100, bottom: 100, right: 100), animated: true)
            
//            self.map.setRegion(MKCoordinateRegion(rect), animated: true)
        }
        
    }


}
   
