//
//  WeatherManager.swift
//  Clima
//
//  Created by Vitali Kupratsevich on 12.06.25.
//  Copyright © 2025 App Brewery. All rights reserved.
//

import Foundation

// MARK: - WeatherManagerDelegate Protocol
protocol WeatherManagerDelegate: AnyObject {
    func didUpdateWeather(weather: WeatherModel)
}

// MARK: - WeatherManager
@MainActor
class WeatherManager {
    
    private let apiKey = "162d249730070d6764131d4a7b000c3a"
    private let baseURL = "https://api.openweathermap.org/data/2.5/weather?units=metric"
    
    weak var delegate: WeatherManagerDelegate?
    
    // MARK: - Fetch Weather by City Name
    func fetchWeather(for city: String) async throws {
        let query = city.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? city
        let urlString = "\(baseURL)&q=\(query)&appid=\(apiKey)"
        try await performRequest(with: urlString)
    }
    
    // MARK: - Fetch Weather by Coordinates
    func fetchWeather(lat: Double, lon: Double) async throws {
        let urlString = "\(baseURL)&lat=\(lat)&lon=\(lon)&appid=\(apiKey)"
        try await performRequest(with: urlString)
    }
    
    // MARK: - Request Execution
    private func performRequest(with urlString: String) async throws {
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        let weather = try await parseJSON(data: data)
        
        DispatchQueue.main.async { [weak self] in
            self?.delegate?.didUpdateWeather(weather: weather)
        }
    }
    
    // MARK: - JSON Parsing
    private func parseJSON(data: Data) async throws -> WeatherModel {
        let decodedData = try JSONDecoder().decode(WeatherResponse.self, from: data)
        return WeatherModel(conditionID: decodedData.weather[0].id,
                            cityName: decodedData.name,
                            temperature: decodedData.main.temp)
    }
}
