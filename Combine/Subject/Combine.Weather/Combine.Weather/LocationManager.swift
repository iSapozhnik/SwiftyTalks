//
//  LocationManager.swift
//  Combine.Weather
//
//  Created by Ivan Sapozhnik on 11/28/19.
//  Copyright © 2019 Swifty Talks. All rights reserved.
//

import MapKit
import Combine

enum LocationError: Error {
    case invalidLocation
}

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
    
    public func cityPublisher(for location: CLLocation) -> AnyPublisher<String, Error> {
        return Future { promise in
            let geocoder = CLGeocoder()
            geocoder.reverseGeocodeLocation(location) { placemarks, error in
                if let city = placemarks?.last?.locality {
                    promise(.success(city))
                } else if let error = error {
                    promise(.failure(error))
                } else {
                    promise(.failure(LocationError.invalidLocation))
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
