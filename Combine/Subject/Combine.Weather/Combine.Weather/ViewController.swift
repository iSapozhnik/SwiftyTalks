//
//  ViewController.swift
//  Combine.Weather
//
//  Created by Ivan Sapozhnik on 11/3/19.
//  Copyright © 2019 Swifty Talks. All rights reserved.
//

import UIKit
import Combine
import MapKit

enum WeatherError: Error {
    case invalidResponse
}

class ViewController: UIViewController {
    private let celsiusCharacters = "ºC"
    private let openWeatherBaseURL = "http://api.openweathermap.org/data/2.5/weather"
    private let openWeatherAPIKey = "13dd13f47c3bb8fe37d5c3326f2fb308"
    private let locationManager = LocatioManager()
    
    @IBOutlet weak var cityTextField: UITextField!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    @IBOutlet weak var temperatureLabel: UILabel!
    
    private var cancellable: AnyCancellable?
    private var cancellableSet: Set<AnyCancellable> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    @IBAction func searchTap(_ sender: Any) {
        view.endEditing(true)
        
        guard let cityName = cityTextField.text else { return }
        getTemperature(for: cityName)
    }
    
    @IBAction func locationTap(_ sender: Any) {
        locationManager.didChangeLocation
        .replaceNil(with: CLLocation(latitude: 0, longitude: 0))
        .map { [weak self] location -> AnyPublisher<String, Never> in
            guard let self = self else { return CurrentValueSubject<String, Never>("Unknown").eraseToAnyPublisher() }
            return self.locationManager.cityPublisher(for: location)
        }
        .flatMap { $0 }
        .sink { city in
            self.cityTextField.text = city
        }
        .store(in: &cancellableSet)
        locationManager.startUpdating()
    }
    
    private func getTemperature(for cityName: String) {
        guard let weatherURL = URL(string: "\(openWeatherBaseURL)?APPID=\(openWeatherAPIKey)&q=\(cityName)&units=metric") else { return }

        activityIndicatorView.startAnimating()
        searchButton.isEnabled = false

        cancellable = URLSession.shared.dataTaskPublisher(for: weatherURL)
            .tryMap { data, response -> Data in
                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                    throw WeatherError.invalidResponse
                }
                return data
        }
        .decode(type: Temperature.self, decoder: JSONDecoder())
        .catch { error in
            return Just(Temperature.placeholder)
        }
        .map { $0.main?.temp ?? 0.0 }
        .map { "\($0) \(self.celsiusCharacters)" }
        .subscribe(on: DispatchQueue(label: "Combine.Weather"))
        .receive(on: RunLoop.main)
        .sink(receiveCompletion: { completion in
            self.activityIndicatorView.stopAnimating()
            self.searchButton.isEnabled = true
        }, receiveValue: { temp in
            self.temperatureLabel.text = temp
        })
    }
}

