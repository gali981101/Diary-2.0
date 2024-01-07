//
//  DiaryDetailMapCell.swift
//  Diary
//
//  Created by Terry Jason on 2023/12/23.
//

import UIKit
import MapKit

class DiaryDetailMapCell: UITableViewCell {

    @IBOutlet var mapView: MKMapView! {
        didSet {
            mapView.layer.cornerRadius = 20.0
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}

// MARK: - CLGeocoder

extension DiaryDetailMapCell {
    
    func configure(in location: String) {
        
        let geoCoder = CLGeocoder()
        
        geoCoder.geocodeAddressString(location) { placemarks, error in
            guard error == nil else { return }
            
            guard let location = placemarks?.first?.location else { return }
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = location.coordinate
            
            let region = MKCoordinateRegion(center: annotation.coordinate, latitudinalMeters: 250, longitudinalMeters: 250)
            
            self.mapView.addAnnotation(annotation)
            self.mapView.setRegion(region, animated: false)
        }
        
    }
    
}
