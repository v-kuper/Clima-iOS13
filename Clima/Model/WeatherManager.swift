//
//  WeatherManager.swift
//  Clima
//
//  Created by Vitali Kupratsevich on 12.06.25.
//  Copyright © 2025 App Brewery. All rights reserved.
//

import Foundation

// MARK: - WeatherManagerDelegate Protocol
@MainActor
protocol WeatherManagerDelegate: AnyObject {
    func didUpdateWeather(_ weatherManager: WeatherManager, weather: WeatherModel)
    func didFailWithError(error: Error)
}

// MARK: - WeatherManager
@MainActor
class WeatherManager {
    
    private let apiKey = "162d249730070d6764131d4a7b000c3a"
    private let baseURL = "https://api.openweathermap.org/data/2.5/weather?units=metric"
    
    weak var delegate: WeatherManagerDelegate?
    
    // MARK: - Fetch Weather by City Name
    func fetchWeather(for city: String) async {
        let query = city.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? city
        let urlString = "\(baseURL)&q=\(query)&appid=\(apiKey)"
        await performRequest(with: urlString)
    }
    
    // MARK: - Fetch Weather by Coordinates
    func fetchWeather(lat: Double, lon: Double) async {
        let urlString = "\(baseURL)&lat=\(lat)&lon=\(lon)&appid=\(apiKey)"
        await performRequest(with: urlString)
    }
    
    // MARK: - Request Execution
    private func performRequest(with urlString: String) async {
        do {
            guard let url = URL(string: urlString) else {
                throw URLError(.badURL)
            }
            
            let (data, _) = try await URLSession.shared.data(from: url)
            let weather = try parseJSON(data: data)
            
            delegate?.didUpdateWeather(self, weather: weather)
        } catch {
            delegate?.didFailWithError(error: error)
        }
    }
    
    // MARK: - JSON Parsing
    private func parseJSON(data: Data) throws -> WeatherModel {
        let decodedData = try JSONDecoder().decode(WeatherResponse.self, from: data)
        return WeatherModel(
            conditionID: decodedData.weather[0].id,
            cityName: decodedData.name,
            temperature: decodedData.main.temp
        )
    }
}
