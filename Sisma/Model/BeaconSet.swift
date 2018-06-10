//
//  BeaconSet.swift
//  Sisma
//
//  Created by Rodrigo Santos on 09/06/2018.
//  Copyright © 2018 Rodrigo. All rights reserved.
//

import Foundation
import CoreBluetooth
import CoreLocation

class BeaconSet{
    let name: String
    let icon: Int
    let uuid: UUID
    let majorValue: CLBeaconMajorValue
    let minorValue: CLBeaconMinorValue
    let locationManager = CLLocationManager()
    
    init(name: String, icon: Int, uuid: UUID, majorValue: Int, minorValue: Int) {
        self.name = name
        self.icon = icon
        self.uuid = uuid
        self.majorValue = CLBeaconMajorValue(majorValue)
        self.minorValue = CLBeaconMinorValue(minorValue)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.requestAlwaysAuthorization()
        
        loadItems()
    }
}
