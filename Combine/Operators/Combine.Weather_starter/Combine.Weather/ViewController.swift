//
//  ViewController.swift
//  Combine.Weather
//
//  Created by Ivan Sapozhnik on 11/3/19.
//  Copyright © 2019 Swifty Talks. All rights reserved.
//

import UIKit
import Combine

class ViewController: UIViewController {
    private let celsiusCharacters = "ºC"
    private let openWeatherBaseURL = "http://api.openweathermap.org/data/2.5/weather"
    private let openWeatherAPIKey = ""
    
    @IBOutlet weak var cityTextField: UITextField!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    @IBOutlet weak var temperatureLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    @IBAction func searchTap(_ sender: Any) {
        view.endEditing(true)
        
    }
}

