//
//  WeatherManager.swift
//  Clima
//
//  Created by Vitali Kupratsevich on 12.06.25.
//  Copyright © 2025 App Brewery. All rights reserved.
//

import Foundation

class WeatherManager {
    private let apiKey = "162d249730070d6764131d4a7b000c3a"
    private let baseURL = "https://api.openweathermap.org/data/2.5/weather?units=metric"

    // MARK: - City Search (async)
    func fetchWeather(for city: String) async throws -> WeatherResponse {
        let query = city.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? city
        let urlString = "\(baseURL)&q=\(query)&appid=\(apiKey)"
        return try await self.performRequest(with: urlString)
    }

    // MARK: - Coordinate Search (async)
    func fetchWeather(lat: Double, lon: Double) async throws -> WeatherResponse {
        let urlString = "\(baseURL)&lat=\(lat)&lon=\(lon)&appid=\(apiKey)"
        return try await self.performRequest(with: urlString)
    }

    // MARK: - Universal Request Method (async)
    private func performRequest(with urlString: String) async throws -> WeatherResponse {
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }
        let (data, _) = try await URLSession.shared.data(from: url)
        return try await self.parseJSON(data: data)
    }
    
    // MARK: - Parse JSON (async)
    private func parseJSON(data: Data) async throws -> WeatherResponse {
        try JSONDecoder().decode(WeatherResponse.self, from: data)
    }
}
