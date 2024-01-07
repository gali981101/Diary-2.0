//
//  MapViewController.swift
//  Diary
//
//  Created by Terry Jason on 2023/12/23.
//

import UIKit
import MapKit

class MapViewController: UIViewController {
    
    var diary: Diary!
    
    let locationManager = CLLocationManager()
    var currentPlacemark: CLPlacemark?
    
    var currentTransportType = MKDirectionsTransportType.automobile
    var currentRoute: MKRoute?
    
    // MARK: - @IBOulet
    
    @IBOutlet var mapView: MKMapView!
    @IBOutlet var segmentedControl: UISegmentedControl!
    
}

// MARK: - Life Cycle

extension MapViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.requestWhenInUseAuthorization()
        segmentedControl.isHidden = true
        
        let status = locationManager.authorizationStatus
        
        if status == CLAuthorizationStatus.authorizedWhenInUse {
            mapView.showsUserLocation = true
        }
        
        mapView.delegate = self
        
        mapView.showsCompass = true
        mapView.showsScale = true
        mapView.showsTraffic = true
        
        let geoCoder = CLGeocoder()
        
        geoCoder.geocodeAddressString(diary.location) { placemarks, error in
            guard error == nil else { return }
            
            guard let placemark = placemarks?.first else { return }
            guard let location = placemark.location else { return }
            
            self.currentPlacemark = placemark
            
            let annotation = MKPointAnnotation()
            
            annotation.title = self.diary.title
            annotation.subtitle = self.diary.date
            
            annotation.coordinate = location.coordinate
            
            self.mapView.showAnnotations([annotation], animated: true)
            self.mapView.selectAnnotation(annotation, animated: true)
        }
        
        let safari = UIBarButtonItem(image: UIImage(systemName: "safari"), style: .done, target: self, action: #selector(showDirection))
        let nearby = UIBarButtonItem(image: UIImage(systemName: "pencil.slash"), style: .done, target: self, action: #selector(showNearby))
        
        self.navigationItem.rightBarButtonItems = [safari, nearby]
        segmentedControl.addTarget(self, action: #selector(showDirection), for: .valueChanged)
    }
    
}

// MARK: - @Objc Func

extension MapViewController {
    
    @objc func showDirection() {
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            currentTransportType = .automobile
        case 1:
            currentTransportType = .walking
        default:
            break
        }
        
        segmentedControl.isHidden = false
        
        guard let currentPlacemark = currentPlacemark else { return }
       
        let directionRequest = MKDirections.Request()
        
        directionRequest.source = MKMapItem.forCurrentLocation()
        
        let destinationPlacemark = MKPlacemark(placemark: currentPlacemark)
        
        directionRequest.destination = MKMapItem(placemark: destinationPlacemark)
        directionRequest.transportType = currentTransportType
        
        directionCalculate(directionRequest)
    }
    
    @objc func showNearby() {
        let searchRequest = MKLocalSearch.Request()
        
        searchRequest.naturalLanguageQuery = diary.weather
        searchRequest.region = mapView.region
        
        let localSearch = MKLocalSearch(request: searchRequest)
        startSearch(localSearch)
    }
    
}

// MARK: - Prepare Segue

extension MapViewController {
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showSteps" {
            let routeTableViewController = segue.destination.children[0] as! RouteTableViewController
            guard let steps = currentRoute?.steps else { return }
            routeTableViewController.routeSteps = steps
        }
    }
    
}

// MARK: - MKMapViewDelegate

extension MapViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let identifier = "Diary_Marker"
        
        if annotation.isKind(of: MKUserLocation.self) { return nil }
        
        var annotationView: MKAnnotationView?
        
        if #available(iOS 11.0, *) {
            var markerAnnotationView: MKMarkerAnnotationView? = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView
            
            if markerAnnotationView == nil {
                markerAnnotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                markerAnnotationView?.canShowCallout = true
            }
            
            markerAnnotationView?.glyphText = "L"
            markerAnnotationView?.markerTintColor = .systemMint
            
            annotationView = markerAnnotationView
        } else {
            var pinAnnotationView: MKPinAnnotationView? = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKPinAnnotationView
            
            if pinAnnotationView == nil {
                pinAnnotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                pinAnnotationView?.canShowCallout = true
                pinAnnotationView?.pinTintColor = UIColor.systemMint
            }
            
            annotationView = pinAnnotationView
        }
        
        let leftIconView = UIImageView(frame: CGRect.init(x: 0, y: 0, width: 63, height: 70))
        
        leftIconView.contentMode = .scaleAspectFit
        leftIconView.image = UIImage(data: diary.image)
        
        annotationView?.leftCalloutAccessoryView = leftIconView
        annotationView?.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        performSegue(withIdentifier: "showSteps", sender: view)
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        
        let renderer = MKPolylineRenderer(overlay: overlay)
        
        renderer.strokeColor = (currentTransportType == .automobile) ? UIColor.systemPink: UIColor.systemOrange
        renderer.lineWidth = 3.0
        
        return renderer
    }
    
}

// MARK: - Helper Method

extension MapViewController {
    
    private func directionCalculate(_ directionRequest: MKDirections.Request) {
        let directions = MKDirections(request: directionRequest)
        
        directions.calculate { res, err in
            guard let res = res else {
                if let err = err { print("錯誤: \(err)") }
                return
            }
            
            let route = res.routes.first!
            self.currentRoute = route
            
            self.mapView.removeOverlays(self.mapView.overlays)
            self.mapView.addOverlay(route.polyline, level: MKOverlayLevel.aboveRoads)
            
            let rect = route.polyline.boundingMapRect
            self.mapView.setRegion(MKCoordinateRegion(rect), animated: true)
        }
    }
    
    private func startSearch(_ localSearch: MKLocalSearch) {
        
        localSearch.start { res, err in
            guard let res = res else {
                if let err = err { print("錯誤: \(err)") }
                return
            }
            
            let mapItems = res.mapItems
            var nearbyAnnotations: [MKAnnotation] = []
            
            guard mapItems.count > 0 else { return }
            
            for item in mapItems {
                let annotation = MKPointAnnotation()
                annotation.title = item.name
                annotation.subtitle = item.phoneNumber
                
                if let location = item.placemark.location {
                    annotation.coordinate = location.coordinate
                }
                
                nearbyAnnotations.append(annotation)
            }
            
            self.mapView.showAnnotations(nearbyAnnotations, animated: true)
        }
        
    }
    
}
