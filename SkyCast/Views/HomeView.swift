//  HomeView.swift
//  SkyCast

import SwiftUI

struct HomeView: View {
    @State private var viewModel = HomeViewModel()

    private var isNight: Bool {
        if case .loaded(let weather) = viewModel.state { return weather.isNight }
        return true
    }

    private var theme: SkyTheme { isNight ? .night : .day }

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [theme.gradientTop, theme.gradientBase],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            switch viewModel.state {
            case .idle, .loading:
                ProgressView()
                    .tint(theme.primaryText)
            case .loaded(let weather):
                weatherContent(weather)
            case .failed(let message):
                errorContent(message)
            }
        }
        .animation(.easeInOut(duration: 0.5), value: isNight)
        .task {
            await viewModel.load()
        }
    }

    private func weatherContent(_ weather: CurrentWeatherResponse) -> some View {
        VStack(spacing: 20) {
            todayCard(weather)
            detailsCard(weather)
            Spacer()
        }
        .padding(20)
    }

    private func todayCard(_ weather: CurrentWeatherResponse) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Today")
                    .font(.title2.weight(.semibold))
                    .foregroundStyle(theme.primaryText)
                Spacer()
                Text(weather.measuredAt, format: .dateTime.weekday(.abbreviated).day().month(.abbreviated))
                    .font(.subheadline)
                    .foregroundStyle(theme.mutedText)
            }

            HStack(alignment: .top) {
                HStack(alignment: .top, spacing: 4) {
                    Text("\(Int(weather.main.temp.rounded()))")
                        .font(.system(size: 64, weight: .bold))
                        .foregroundStyle(theme.primaryText)
                    Text("°C")
                        .font(.title3.weight(.semibold))
                        .foregroundStyle(theme.accent)
                        .padding(.top, 10)
                }

                Spacer()

                if let condition = weather.condition {
                    VStack(spacing: 6) {
                        Image(systemName: condition.systemImageName)
                            .symbolRenderingMode(.multicolor)
                            .font(.system(size: 52))
                        Text(condition.description.capitalized)
                            .font(.caption)
                            .foregroundStyle(theme.mutedText)
                    }
                }
            }

            HStack(spacing: 6) {
                Image(systemName: "location.fill")
                    .font(.caption)
                Text(weather.name)
                    .font(.subheadline)
            }
            .foregroundStyle(theme.mutedText)
        }
        .padding(20)
        .background(theme.card, in: RoundedRectangle(cornerRadius: 24))
    }

    private func detailsCard(_ weather: CurrentWeatherResponse) -> some View {
        HStack {
            detail("Feels like", "\(Int(weather.main.feelsLike.rounded()))°")
            Spacer()
            detail("Humidity", "\(weather.main.humidity)%")
            Spacer()
            detail("Wind", String(format: "%.1f m/s", weather.wind.speed))
        }
        .padding(20)
        .background(theme.card, in: RoundedRectangle(cornerRadius: 24))
    }

    private func detail(_ title: String, _ value: String) -> some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundStyle(theme.mutedText)
            Text(value)
                .font(.headline)
                .foregroundStyle(theme.primaryText)
        }
    }

    private func errorContent(_ message: String) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 48))
                .foregroundStyle(theme.accent)

            Text(message)
                .multilineTextAlignment(.center)
                .foregroundStyle(theme.mutedText)

            Button("Try again") {
                Task { await viewModel.load() }
            }
            .buttonStyle(.borderedProminent)
            .tint(theme.accent)
        }
        .padding()
    }
}

#Preview {
    HomeView()
}
