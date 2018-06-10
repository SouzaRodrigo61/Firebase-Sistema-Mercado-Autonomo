//
//  ItemsViewController.swift
//  Sisma
//
//  Created by Rodrigo Santos on 09/06/2018.
//  Copyright © 2018 Rodrigo. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation

class ItemsViewController: UIViewController, CLLocationManagerDelegate{
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        locationManager.delegate = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
        print("Failed monitoring region: \(error.localizedDescription)")
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location manager failed: \(error.localizedDescription)")
    }
    
    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
        
        // Find the same beacons in the table.
        var indexPaths = [IndexPath]()
        for beacon in beacons {
            for row in 0..<items.count {
                // TODO: Determine if item is equal to ranged beacon
            }
        }
        
        // Update beacon locations of visible rows.
        if let visibleRows = tableView.indexPathsForVisibleRows {
            let rowsToUpdate = visibleRows.filter { indexPaths.contains($0) }
            for row in rowsToUpdate {
                let cell = tableView.cellForRow(at: row) as! ItemCell
                cell.refreshLocation()
            }
        }
    }
    
}
