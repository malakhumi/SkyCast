//  HomeView.swift
//  SkyCast

import SwiftUI

struct HomeView: View {
    let viewModel: HomeViewModel
    let settings: AppSettings
    let onSearchTapped: () -> Void
    let onSettingsTapped: () -> Void

    private var theme: SkyTheme { viewModel.theme }

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
            case .loaded(let snapshot):
                weatherContent(snapshot)
            case .failed(let message):
                errorContent(message)
            }
        }
        .animation(.easeInOut(duration: 0.5), value: viewModel.isNight)
        .task {
            await viewModel.load()
        }
    }
    
    private func weatherContent(_ snapshot: WeatherSnapshot) -> some View {
        ScrollView {
            VStack(spacing: 20) {
                HStack(spacing: 12) {
                    Button(action: onSettingsTapped) {
                        Image(systemName: "gearshape.fill")
                            .font(.title3.weight(.semibold))
                            .foregroundStyle(theme.primaryText)
                            .padding(12)
                            .background(theme.card, in: Circle())
                    }
                    .accessibilityLabel("Settings")
                    Spacer()

                    Button {
                        Task { await viewModel.loadDeviceLocation() }
                    } label: {
                        Image(systemName: "location.fill")
                            .font(.title3.weight(.semibold))
                            .foregroundStyle(theme.primaryText)
                            .padding(12)
                            .background(theme.card, in: Circle())
                    }
                    .accessibilityLabel("Use my location")

                    Button(action: onSearchTapped) {
                        Image(systemName: "magnifyingglass")
                            .font(.title3.weight(.semibold))
                            .foregroundStyle(theme.primaryText)
                            .padding(12)
                            .background(theme.card, in: Circle())
                    }
                    .accessibilityLabel("Search for a city")
                    
                }
                todayCard(snapshot)
                hourlySection(snapshot.hourly, in: snapshot.timeZone)
                dailySection(snapshot.daily, in: snapshot.timeZone)
                locationSection(snapshot.current)
                detailsCard(snapshot.current)
            }
            .padding(20)
        }
    }
    
    private func locationSection(_ weather: CurrentWeatherResponse) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Location")
                .font(.headline)
                .foregroundStyle(theme.primaryText)
                .padding(.leading, 4)

            MapView(
                latitude: weather.coord.lat,
                longitude: weather.coord.lon,
                title: weather.name,
                isNight: viewModel.isNight
            )
            .frame(height: 180)
            .clipShape(RoundedRectangle(cornerRadius: 24))
        }
    }


    private func todayCard(_ snapshot: WeatherSnapshot) -> some View {
        let weather = snapshot.current

        return VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Today")
                    .font(.title2.weight(.semibold))
                    .foregroundStyle(theme.primaryText)
                Spacer()
                Text(dateText(weather.measuredAt, in: snapshot.timeZone))
                    .font(.subheadline)
                    .foregroundStyle(theme.mutedText)
            }

            HStack(alignment: .top) {
                HStack(alignment: .top, spacing: 4) {
                    Text(settings.temperatureValue(weather.main.temp))
                        .font(.system(size: 64, weight: .bold))
                        .foregroundStyle(theme.primaryText)
                    Text(settings.temperatureSymbol)
                        .font(.title3.weight(.semibold))
                        .foregroundStyle(theme.accent)
                        .padding(.top, 10)
                }

                Spacer()

                if let condition = weather.condition {
                    VStack(spacing: 6) {
                        weatherIcon(condition, size: 52)
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
    
    private func hourlySection(
        _ entries: [ForecastResponse.Entry],
        in timeZone: TimeZone
    ) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Next 24 hours")
                .font(.headline)
                .foregroundStyle(theme.primaryText)
                .padding(.leading, 4)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(entries) { entry in
                        VStack(spacing: 10) {
                            Text(hourText(entry.date, in: timeZone))
                                .font(.caption)
                                .foregroundStyle(theme.mutedText)

                            if let condition = entry.condition {
                                weatherIcon(condition, size: 22)
                            }

                            Text(settings.temperature(entry.main.temp))
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(theme.primaryText)
                        }
                        .frame(width: 62)
                        .padding(.vertical, 14)
                        .background(theme.card, in: RoundedRectangle(cornerRadius: 18))
                    }
                }
                .padding(.horizontal, 4)
            }
        }
    }
    
    private func dailySection(
        _ days: [DailyForecast],
        in timeZone: TimeZone
    ) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Next 5 days")
                .font(.headline)
                .foregroundStyle(theme.primaryText)
                .padding(.leading, 4)

            VStack(spacing: 0) {
                ForEach(Array(days.enumerated()), id: \.element.id) { index, day in
                    HStack(spacing: 8) {
                        Text(isToday(day.date, in: timeZone)
                             ? "Today"
                             : weekdayText(day.date, in: timeZone))
                            .font(.subheadline)
                            .foregroundStyle(theme.primaryText)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        if let condition = day.condition {
                            weatherIcon(condition, size: 18)
                                .frame(width: 32)
                        }

                        Text(settings.temperature(day.minTemp))
                            .font(.subheadline)
                            .foregroundStyle(theme.mutedText)
                            .frame(width: 42, alignment: .trailing)

                        Text(settings.temperature(day.maxTemp))
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(theme.primaryText)
                            .frame(width: 42, alignment: .trailing)
                    }
                    .padding(.vertical, 12)

                    if index < days.count - 1 {
                        Divider().overlay(theme.mutedText.opacity(0.25))
                    }
                }
            }
            .padding(.horizontal, 20)
            .background(theme.card, in: RoundedRectangle(cornerRadius: 24))
        }
    }

    private func detailsCard(_ weather: CurrentWeatherResponse) -> some View {
        HStack {
            detail("Feels like", settings.temperature(weather.main.feelsLike))
            Spacer()
            detail("Humidity", "\(weather.main.humidity)%")
            Spacer()
            detail("Wind", settings.wind(weather.wind.speed))
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
    
    // MARK: Dates, formatted in the displayed city's timezone

    private func hourText(_ date: Date, in timeZone: TimeZone) -> String {
        date.formatted(Date.FormatStyle(timeZone: timeZone).hour())
    }

    private func weekdayText(_ date: Date, in timeZone: TimeZone) -> String {
        date.formatted(Date.FormatStyle(timeZone: timeZone).weekday(.wide))
    }

    private func dateText(_ date: Date, in timeZone: TimeZone) -> String {
        date.formatted(
            Date.FormatStyle(timeZone: timeZone)
                .weekday(.abbreviated)
                .day()
                .month(.abbreviated)
        )
    }

    private func isToday(_ date: Date, in timeZone: TimeZone) -> Bool {
        var calendar = Calendar.current
        calendar.timeZone = timeZone
        return calendar.isDateInToday(date)
    }

    private func weatherIcon(_ condition: WeatherCondition, size: CGFloat) -> some View {
        let primary: Color = condition.isSunSymbol ? theme.accent
            : condition.isMoonSymbol ? theme.iconMoon
            : theme.iconCloud

        let secondary: Color = condition.containsMoon ? theme.iconMoon
            : (condition.containsSun || condition.containsBolt) ? theme.accent
            : theme.iconRain

        return Image(systemName: condition.systemImageName)
            .symbolRenderingMode(.palette)
            .foregroundStyle(primary, secondary, theme.iconRain)
            .font(.system(size: size))
    }
}

#Preview {
    HomeView(
        viewModel: HomeViewModel(),
        settings: AppSettings(),
        onSearchTapped: {},
        onSettingsTapped: {}
    )
}
