//  CitiesViewController.swift
//  SkyCast

import UIKit

/// UIKit screen showing saved cities, and searching for new ones.
final class CitiesViewController: UIViewController {

    /// Called when the user taps a city.
    var onCitySelected: ((GeocodingResult) -> Void)?
    var theme: SkyTheme = .night

    private static let cellID = "CityCell"

    private let service: WeatherService
    private let store: CityStore
    private let tableView = UITableView()
    private let searchController = UISearchController(searchResultsController: nil)
    private let messageLabel = UILabel()
    private let gradientLayer = CAGradientLayer()

    private var savedCities: [GeocodingResult] = []
    private var recentCities: [GeocodingResult] = []
    private var results: [GeocodingResult] = []
    private var searchTask: Task<Void, Never>?
    
    private struct TableSection {
        enum Kind { case results, saved, recent }
        let title: String
        let kind: Kind
        let cities: [GeocodingResult]
    }

    private var sections: [TableSection] {
        if isSearching {
            return results.isEmpty
                ? []
                : [TableSection(title: "Search results", kind: .results, cities: results)]
        }

        var built: [TableSection] = []
        if !savedCities.isEmpty {
            built.append(TableSection(title: "Saved", kind: .saved, cities: savedCities))
        }
        // A saved city shouldn't also appear under Recent.
        let unsaved = recentCities.filter { !savedCities.contains($0) }
        if !unsaved.isEmpty {
            built.append(TableSection(title: "Recent", kind: .recent, cities: unsaved))
        }
        return built
    }

    private func refreshLists() {
        savedCities = store.cities(in: .saved)
        recentCities = store.cities(in: .recent)
    }

    private var isSearching: Bool {
        !(searchController.searchBar.text ?? "").trimmingCharacters(in: .whitespaces).isEmpty
    }

    private var rows: [GeocodingResult] { isSearching ? results : savedCities }

    init(service: WeatherService = OpenWeatherService(), store: CityStore = CityStore()) {
        self.service = service
        self.store = store
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Cities"

        overrideUserInterfaceStyle = theme.isNight ? .dark : .light
        view.backgroundColor = UIColor(theme.gradientBase)

        gradientLayer.colors = [
            UIColor(theme.gradientTop).cgColor,
            UIColor(theme.gradientBase).cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1)
        view.layer.insertSublayer(gradientLayer, at: 0)

        let barAppearance = UINavigationBarAppearance()
        barAppearance.configureWithTransparentBackground()
        barAppearance.titleTextAttributes = [.foregroundColor: UIColor(theme.primaryText)]
        navigationItem.standardAppearance = barAppearance
        navigationItem.scrollEdgeAppearance = barAppearance

        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.searchTextField.attributedPlaceholder = NSAttributedString(
            string: "Add a city",
            attributes: [.foregroundColor: UIColor(theme.mutedText)]
        )
        searchController.searchBar.searchTextField.backgroundColor = UIColor(theme.card)
        searchController.searchBar.searchTextField.textColor = UIColor(theme.primaryText)
        searchController.searchBar.searchTextField.leftView?.tintColor = UIColor(theme.mutedText)
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = true

        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: Self.cellID)
        tableView.backgroundColor = .clear
        tableView.separatorColor = UIColor(theme.mutedText).withAlphaComponent(0.25)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)

        messageLabel.textAlignment = .center
        messageLabel.numberOfLines = 0
        messageLabel.textColor = UIColor(theme.mutedText)
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(messageLabel)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            messageLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            messageLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            messageLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            messageLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32)
        ])

        refreshLists()
        tableView.reloadData()
        updateMessage()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
        navigationController?.navigationBar.tintColor = UIColor(theme.accent)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradientLayer.frame = view.bounds
    }

    private func updateMessage(_ override: String? = nil) {
        if let override {
            messageLabel.text = override
        } else if isSearching {
            messageLabel.text = results.isEmpty ? "No cities found." : nil
        } else {
            messageLabel.text = sections.isEmpty
                ? "Cities you view will appear here.\nSwipe a search result to save it."
                : nil
        }
        messageLabel.isHidden = messageLabel.text == nil
    }

    private func search(_ query: String) async {
        do {
            let found = try await service.searchCities(matching: query)
            guard !Task.isCancelled else { return }
            results = found
            tableView.reloadData()
            updateMessage()
        } catch {
            results = []
            tableView.reloadData()
            updateMessage(error.localizedDescription)
        }
    }
}

extension CitiesViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        let query = (searchController.searchBar.text ?? "")
            .trimmingCharacters(in: .whitespaces)

        searchTask?.cancel()

        guard query.count >= 2 else {
            results = []
            tableView.reloadData()
            updateMessage()
            return
        }

        searchTask = Task {
            try? await Task.sleep(for: .milliseconds(300))
            guard !Task.isCancelled else { return }
            await search(query)
        }
    }
}

extension CitiesViewController: UITableViewDataSource, UITableViewDelegate {

    func numberOfSections(in tableView: UITableView) -> Int {
        sections.count
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        sections[section].title
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        sections[section].cities.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Self.cellID, for: indexPath)
        let city = sections[indexPath.section].cities[indexPath.row]

        var content = cell.defaultContentConfiguration()
        content.text = city.name
        content.secondaryText = [city.state, city.countryName]
            .compactMap { $0 }
            .joined(separator: ", ")
        content.textProperties.color = UIColor(theme.primaryText)
        content.secondaryTextProperties.color = UIColor(theme.mutedText)
        cell.contentConfiguration = content
        cell.backgroundColor = .clear
        cell.accessoryType = .disclosureIndicator

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let city = sections[indexPath.section].cities[indexPath.row]
        store.add(city, to: .recent)
        refreshLists()
        onCitySelected?(city)
    }

    func tableView(
        _ tableView: UITableView,
        trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath
    ) -> UISwipeActionsConfiguration? {
        let section = sections[indexPath.section]
        let city = section.cities[indexPath.row]

        let save = UIContextualAction(style: .normal, title: "Save") { [weak self] _, _, done in
            guard let self else { return done(false) }
            self.store.add(city, to: .saved)
            self.refreshLists()
            self.tableView.reloadData()
            self.updateMessage()
            done(true)
        }
        save.backgroundColor = UIColor(theme.accent)

        let remove = UIContextualAction(style: .destructive, title: "Remove") { [weak self] _, _, done in
            guard let self else { return done(false) }
            self.store.remove(city, from: section.kind == .saved ? .saved : .recent)
            self.refreshLists()
            self.tableView.reloadData()
            self.updateMessage()
            done(true)
        }

        switch section.kind {
        case .results:
            return UISwipeActionsConfiguration(actions: [save])
        case .saved:
            return UISwipeActionsConfiguration(actions: [remove])
        case .recent:
            return UISwipeActionsConfiguration(actions: [remove, save])
        }
    }
}
