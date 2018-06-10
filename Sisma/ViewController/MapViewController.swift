//
//  MapViewController.swift
//  Sisma
//
//  Created by Rodrigo Santos on 09/06/2018.
//  Copyright © 2018 Rodrigo. All rights reserved.
//

import Foundation
import UIKit
import MapKit
import CoreLocation

class MapViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate{
    
    @IBOutlet weak var mapView: MKMapView!
    private var locationManager: CLLocationManager!
    private var currentLocation: CLLocation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        requestLocationAccess()
        
        // 1
        let location = CLLocationCoordinate2D(latitude: -15.809266,
                                              longitude: -48.089212)
        
        // 2
        let span = MKCoordinateSpanMake(0.05, 0.05)
        let region = MKCoordinateRegion(center: location, span: span)
        mapView.setRegion(region, animated: true)
        
        //3
        let annotation = MKPointAnnotation()
        annotation.coordinate = location
        annotation.title = "Fort Atacadista"
        annotation.subtitle = "Distrito Federal"
        mapView.addAnnotation(annotation)
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        // Check for Location Services
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.requestWhenInUseAuthorization()
            locationManager.startUpdatingLocation()
        }
        
        
        let sourceLocation = locationManager.location?.coordinate
        let destCoordinete = location
        
        let sourcePlacemark = MKPlacemark(coordinate: sourceLocation!)
        let destPlacemark = MKPlacemark(coordinate: destCoordinete)
        
        let sourceItem = MKMapItem(placemark: sourcePlacemark)
        let destItem = MKMapItem(placemark: destPlacemark)
        
        let directionRequest = MKDirectionsRequest()
        directionRequest.source = sourceItem
        directionRequest.destination = destItem
        directionRequest.transportType = .automobile
        
        let directions = MKDirections(request: directionRequest)
        directions.calculate(completionHandler: {
            response, error in
            
            guard let response = response else{
                if error != nil{
                    print("Error")
                }
                return
            }
            
            let route = response.routes[0]
            self.mapView.add(route.polyline, level: .aboveRoads)
            
            let rekt = route.polyline.boundingMapRect
            self.mapView.setRegion(MKCoordinateRegionForMapRect(rekt), animated: true)
        })
        
        
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = UIColor.blue
        renderer.lineWidth = 5.0
        
        return renderer
    }
    
    
    // MARK - CLLocationManagerDelegate
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        defer { currentLocation = locations.last }
        
        if currentLocation == nil {
            // Zoom to user location
            if let userLocation = locations.last {
                let viewRegion = MKCoordinateRegionMakeWithDistance(userLocation.coordinate, 2000, 2000)
                mapView.setRegion(viewRegion, animated: true)
            }
        }
    }
    
    func requestLocationAccess() {
        let status = CLLocationManager.authorizationStatus()
        
        switch status {
        case .authorizedAlways, .authorizedWhenInUse:
            return
            
        case .denied, .restricted:
            print("location access denied")
            
        default:
            locationManager.requestWhenInUseAuthorization()
        }
    }
}
