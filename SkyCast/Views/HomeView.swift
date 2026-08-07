//  HomeView.swift
//  SkyCast

import SwiftUI

struct HomeView: View {
    @State private var viewModel = HomeViewModel()

    var body: some View {
        Group {
            switch viewModel.state {
            case .idle, .loading:
                ProgressView("Loading weather…")
            case .loaded(let weather):
                weatherContent(weather)
            case .failed(let message):
                errorContent(message)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
        .task {
            await viewModel.load()
        }
    }

    private func weatherContent(_ weather: CurrentWeatherResponse) -> some View {
        VStack(spacing: 12) {
            Text(weather.name)
                .font(.largeTitle.weight(.semibold))

            if let condition = weather.condition {
                Image(systemName: condition.systemImageName)
                    .symbolRenderingMode(.multicolor)
                    .font(.system(size: 72))

                Text(condition.description.capitalized)
                    .font(.title3)
                    .foregroundStyle(.secondary)
            }

            Text("\(Int(weather.main.temp.rounded()))°")
                .font(.system(size: 80, weight: .thin))

            HStack(spacing: 28) {
                detail("Feels like", "\(Int(weather.main.feelsLike.rounded()))°")
                detail("Humidity", "\(weather.main.humidity)%")
                detail("Wind", String(format: "%.1f m/s", weather.wind.speed))
            }
            .padding(.top, 8)
        }
        .padding()
    }

    private func detail(_ title: String, _ value: String) -> some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.headline)
        }
    }

    private func errorContent(_ message: String) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 48))
                .foregroundStyle(.orange)

            Text(message)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)

            Button("Try again") {
                Task { await viewModel.load() }
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}

#Preview {
    HomeView()
}
