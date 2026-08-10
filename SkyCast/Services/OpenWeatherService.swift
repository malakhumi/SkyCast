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
        try await fetch("data/2.5/weather", [URLQueryItem(name: "q", value: city)])
    }

    func currentWeather(latitude: Double, longitude: Double) async throws -> CurrentWeatherResponse {
        try await fetch("data/2.5/weather", coordinates(latitude, longitude))
    }

    func forecast(forCity city: String) async throws -> ForecastResponse {
        try await fetch("data/2.5/forecast", [URLQueryItem(name: "q", value: city)])
    }

    func forecast(latitude: Double, longitude: Double) async throws -> ForecastResponse {
        try await fetch("data/2.5/forecast", coordinates(latitude, longitude))
    }

    private func coordinates(_ latitude: Double, _ longitude: Double) -> [URLQueryItem] {
        [
            URLQueryItem(name: "lat", value: String(latitude)),
            URLQueryItem(name: "lon", value: String(longitude))
        ]
    }
    
    func searchCities(matching query: String) async throws -> [GeocodingResult] {
        try await fetch("geo/1.0/direct", [
            URLQueryItem(name: "q", value: query),
            URLQueryItem(name: "limit", value: "8")
        ])
    }

    private func fetch<T: Decodable>(_ path: String, _ locationItems: [URLQueryItem]) async throws -> T {
        var components = URLComponents(string: "https://api.openweathermap.org/\(path)")
        
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
            return try decoder.decode(T.self, from: data)
        } catch {
            throw WeatherError.decodingFailed
        }
    }
}
