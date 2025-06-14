//
//  ViewController.swift
//  Clima
//
//  Created by Angela Yu on 01/09/2019.
//  Copyright © 2019 App Brewery. All rights reserved.
//

import UIKit

class WeatherViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var conditionImageView: UIImageView!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var searchTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        searchTextField.delegate = self
    }
    
    @IBAction func searchPressed(_ sender: UIButton) {
        searchTextField.endEditing(true)
        print(searchTextField.text!)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        searchTextField.endEditing(true)
        print(searchTextField.text!)
        return true
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if textField.text != "" {
            textField.placeholder = "Search"
            return true
        } else {
            textField.placeholder = "Enter city name"
            return false
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        guard let city = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines), !city.isEmpty else { return }
        Task {
            do {
                let weatherData = try await WeatherManager().fetchWeather(for: city)
                let name = weatherData.name
                let id = weatherData.weather[0].id
                let temp = weatherData.main.temp
                
                let weather = WeatherModel(conditionID: id, cityName: name, temperature: temp)
                
                DispatchQueue.main.async {
                    self.conditionImageView.image = UIImage(systemName: weather.conditionName)
                    self.temperatureLabel.text = weather.temperatureString
                    self.cityLabel.text = weather.cityName
                }
            } catch {
                print("Ошибка загрузки погоды: \(error)")
            }
        }
        
        searchTextField.text = ""
    }
    
}

