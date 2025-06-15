//
//  ViewController.swift
//  Clima
//
//  Created by Angela Yu on 01/09/2019.
//  Copyright © 2019 App Brewery. All rights reserved.
//

import UIKit

class WeatherViewController: UIViewController, UITextFieldDelegate, WeatherManagerDelegate {
    
    @IBOutlet weak var conditionImageView: UIImageView!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var searchTextField: UITextField!
    
    let weatherManager = WeatherManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchTextField.delegate = self
        weatherManager.delegate = self
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
            await weatherManager.fetchWeather(for: city)
        }
        
        searchTextField.text = ""
    }
    
    // MARK: - WeatherManagerDelegate Methods
    func didUpdateWeather(_ weatherManager: WeatherManager, weather: WeatherModel) {
        conditionImageView.image = UIImage(systemName: weather.conditionName)
        temperatureLabel.text = weather.temperatureString
        cityLabel.text = weather.cityName
    }
    
    func didFailWithError(error: Error) {
        print("❌ Ошибка загрузки погоды: \(error.localizedDescription)")
        showErrorAlert(message: "Не удалось загрузить погоду. Попробуйте ещё раз.")
    }
    
    // MARK: - UI Helpers
    
    private func showErrorAlert(message: String) {
        let alert = UIAlertController(title: "Ошибка", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ок", style: .default))
        present(alert, animated: true)
    }
}

