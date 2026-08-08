//  OpenWeatherService.swift
//  SkyCast

import Foundation

/// Fetches weather from the OpenWeather API.
struct OpenWeatherService: WeatherService {
    private let apiKey: String
    private let session: URLSession

    init(apiKey: String = Secrets.openWeatherAPIKey, session: URLSession = .shared) {
        self.apiKey = apiKey
        self.session = session
    }

    func currentWeather(forCity city: String) async throws -> CurrentWeatherResponse {
        try await fetch([URLQueryItem(name: "q", value: city)])
    }

    func currentWeather(latitude: Double, longitude: Double) async throws -> CurrentWeatherResponse {
        try await fetch([
            URLQueryItem(name: "lat", value: String(latitude)),
            URLQueryItem(name: "lon", value: String(longitude))
        ])
    }

    private func fetch(_ locationItems: [URLQueryItem]) async throws -> CurrentWeatherResponse {
        var components = URLComponents(string: "https://api.openweathermap.org/data/2.5/weather")
        components?.queryItems = locationItems + [
            URLQueryItem(name: "units", value: "metric"),
            URLQueryItem(name: "appid", value: apiKey)
        ]

        guard let url = components?.url else {
            throw WeatherError.invalidURL
        }

        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await session.data(from: url)
        } catch {
            throw WeatherError.noInternet
        }

        guard let http = response as? HTTPURLResponse else {
            throw WeatherError.server(statusCode: -1)
        }

        switch http.statusCode {
        case 200:
            break
        case 401:
            throw WeatherError.invalidAPIKey
        case 404:
            throw WeatherError.cityNotFound
        default:
            throw WeatherError.server(statusCode: http.statusCode)
        }

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase

        do {
            return try decoder.decode(CurrentWeatherResponse.self, from: data)
        } catch {
            throw WeatherError.decodingFailed
        }
    }
}
