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
    public var didChangeLocation = PassthroughSubject<CLLocation?, Never>()
    
    private let locationManager: CLLocationManager
    
    public init(with locationManager: CLLocationManager = CLLocationManager()) {
        self.locationManager = locationManager
        super.init()
        self.locationManager.delegate = self
    }
    
    public func startUpdating() {
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        didChangeLocation.send(locationManager.location)
    }
    
    public func stopUpdating() {
        locationManager.stopUpdatingLocation()
    }
    
    public func cityPublisher(for location: CLLocation) -> AnyPublisher<String, Never> {
        return Future { promise in
            let geocoder = CLGeocoder()
            geocoder.reverseGeocodeLocation(location) { placemarks, error in
                switch (placemarks, error) {
                case (let placemarks, nil):
                    let city = placemarks?.last?.locality ?? "Unknown"
                    promise(.success(city))
                case (nil, _):
                    promise(.success("Unknown"))
                default: break
                }
            }
        }.eraseToAnyPublisher()
    }
}

extension LocatioManager: CLLocationManagerDelegate {
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print(locations)
        didChangeLocation.send(locations.last)
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
