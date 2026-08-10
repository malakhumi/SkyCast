//  CityStore.swift
//  SkyCast

import Foundation

struct CityStore {

    enum List: String {
        case saved = "savedCities"
        case recent = "recentCities"
    }

    private let defaults: UserDefaults
    private let recentLimit = 10

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func cities(in list: List) -> [GeocodingResult] {
        guard
            let data = defaults.data(forKey: list.rawValue),
            let cities = try? JSONDecoder().decode([GeocodingResult].self, from: data)
        else { return [] }
        return cities
    }

    func add(_ city: GeocodingResult, to list: List) {
        var cities = self.cities(in: list)
        cities.removeAll { $0 == city }

        switch list {
        case .recent:
            cities.insert(city, at: 0)
            cities = Array(cities.prefix(recentLimit))
        case .saved:
            cities.append(city)
        }

        persist(cities, to: list)
    }

    func remove(_ city: GeocodingResult, from list: List) {
        var cities = self.cities(in: list)
        cities.removeAll { $0 == city }
        persist(cities, to: list)
    }

    private func persist(_ cities: [GeocodingResult], to list: List) {
        guard let data = try? JSONEncoder().encode(cities) else { return }
        defaults.set(data, forKey: list.rawValue)
    }
}
