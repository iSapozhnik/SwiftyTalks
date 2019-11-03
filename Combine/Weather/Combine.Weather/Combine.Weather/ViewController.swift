//
//  ViewController.swift
//  Combine.Weather
//
//  Created by Ivan Sapozhnik on 11/3/19.
//  Copyright © 2019 Swifty Talks. All rights reserved.
//

import UIKit
import Combine

enum WeatherError: Error {
    case invalidServerResponse
}

class ViewController: UIViewController {
    private let celsiusCharacters = "ºC"
    private let openWeatherBaseURL = "http://api.openweathermap.org/data/2.5/weather"
    private let openWeatherAPIKey = ""
    
    private var temp: Double = 0.0 {
        didSet {
            temperatureLabel.text = "\(temp) " + celsiusCharacters
        }
    }
    
    @IBOutlet weak var cityTextField: UITextField!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    @IBOutlet weak var temperatureLabel: UILabel!
    
    private var cancellable: AnyCancellable?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    @IBAction func searchTap(_ sender: Any) {
        view.endEditing(true)
        
        guard let cityName = cityTextField.text else { return }
        getTemperature(for: cityName)
    }
    
    private func getTemperature(for cityName: String) {
        guard let weatherURL = URL(string: "\(openWeatherBaseURL)?APPID=\(openWeatherAPIKey)&q=\(cityName)&units=metric") else { return }
        
        let remoteDataPublisher = URLSession.shared.dataTaskPublisher(for: weatherURL)
        .handleEvents(receiveSubscription: { _ in
            DispatchQueue.main.async {
                self.searchButton.isEnabled = false
                self.activityIndicatorView.startAnimating()
            }
        }, receiveCompletion: { _ in
            DispatchQueue.main.async {
                self.searchButton.isEnabled = true
                self.activityIndicatorView.stopAnimating()
            }
        }, receiveCancel: {
            DispatchQueue.main.async {
                self.searchButton.isEnabled = true
                self.activityIndicatorView.stopAnimating()
            }
        })
        .tryMap { data, response -> Data in
            guard let httpResponse = response as? HTTPURLResponse,
                httpResponse.statusCode == 200 else {
                    throw WeatherError.invalidServerResponse
            }
            return data
        }
        .decode(type: Temperature.self, decoder: JSONDecoder())
        .catch { error in
            return Just(Temperature.placeholder)
        }
        .map { $0.main?.temp ?? 0.0 }
        .replaceError(with: 0.0)
        .eraseToAnyPublisher()
        .subscribe(on: DispatchQueue.global(qos: .background))
        .receive(on: RunLoop.main)
        
        cancellable = remoteDataPublisher.assign(to: \.temp, on: self)
    }
}

