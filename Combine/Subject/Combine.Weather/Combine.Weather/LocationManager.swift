//
//  LocationManager.swift
//  Combine.Weather
//
//  Created by Ivan Sapozhnik on 11/28/19.
//  Copyright © 2019 Swifty Talks. All rights reserved.
//

import MapKit
import Combine

final public class LocatioManager: NSObject {
    public var didChangeLocation = PassthroughSubject<CLLocationCoordinate2D?, Never>()
    
    private let locationManager: CLLocationManager
    private var location: CLLocation? {
        didSet {
            didChangeLocation.send(location?.coordinate)
        }
    }
    
    public init(with locationManager: CLLocationManager = CLLocationManager()) {
        self.locationManager = locationManager
        super.init()
        self.locationManager.delegate = self
    }
    
    public func startUpdating() {
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        location = locationManager.location
    }
    
    public func stopUpdating() {
        locationManager.stopUpdatingLocation()
    }
}

extension LocatioManager: CLLocationManagerDelegate {
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print(locations)
        location = locations.last
    }

    public func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            startUpdating()
        case .denied, .restricted:
            stopUpdating()
        default:
            break
        }
    }
}
