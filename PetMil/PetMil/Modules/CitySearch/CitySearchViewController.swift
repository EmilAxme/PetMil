//
//  CitySearchViewController.swift
//  PetMil
//
//  Created by Emil on 11.03.2026.
//

import UIKit

protocol CitySearchViewProtocol: AnyObject {
    func displayCities(_ viewModel: CitySearchModels.ViewModel)
    func displayLoading(_ isLoading: Bool)
    func displayLocationLoading(_ isLoading: Bool)
    func displayLocationError(_ message: String)
    func routeToWeatherScreen()
}

final class CitySearchViewController: UIViewController {
    
    var presenter: CitySearchPresenterProtocol?
    
    private var cities: [CitySearchModels.City] = []
    
    private lazy var searchController: UISearchController = {
        let controller = UISearchController(searchResultsController: nil)
        controller.obscuresBackgroundDuringPresentation = false
        controller.searchBar.placeholder = "Search city"
        controller.searchResultsUpdater = self
        return controller
    }()
    
    private lazy var cityTableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 76
        tableView.showsVerticalScrollIndicator = false
        tableView.register(CityResultCell.self, forCellReuseIdentifier: CityResultCell.reuseIdentifier)
        return tableView
    }()

    private lazy var currentLocationButton: CurrentLocationButton = {
        let button = CurrentLocationButton()
        button.onTap = { [weak self] in
            self?.presenter?.didTapCurrentLocation()
        }
        return button
    }()
    
    private lazy var searchLoadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.hidesWhenStopped = true
        return indicator
    }()

    private lazy var emptyStateLabel: UILabel = {
        let label = UILabel()
        label.text = "Ничего не найдено,\nвидимо город скрыт за туманом..."
        label.font = .systemFont(ofSize: 20, weight: .medium)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.numberOfLines = 0
        label.isHidden = true
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupAppearance()
        setupLayout()
        setupCurrentLocationHeader()
        presenter?.viewDidLoad()
    }
}

private extension CitySearchViewController {
    func setupAppearance() {
        title = "Search City"
        view.backgroundColor = .systemBackground
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = true
    }
    
    func setupLayout() {
        view.addToView(cityTableView)
        view.addToView(emptyStateLabel)

        NSLayoutConstraint.activate([
            cityTableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            cityTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            cityTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            cityTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            emptyStateLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyStateLabel.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 24),
            emptyStateLabel.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -24)
        ])
    }

    func setupCurrentLocationHeader() {
        let header = UIView()
        header.addSubview(currentLocationButton)
        currentLocationButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            currentLocationButton.topAnchor.constraint(equalTo: header.topAnchor, constant: 4),
            currentLocationButton.leadingAnchor.constraint(equalTo: header.leadingAnchor),
            currentLocationButton.trailingAnchor.constraint(equalTo: header.trailingAnchor),
            currentLocationButton.bottomAnchor.constraint(equalTo: header.bottomAnchor, constant: -4)
        ])

        let targetWidth = view.bounds.width > 0 ? view.bounds.width : UIScreen.main.bounds.width
        let fittingSize = header.systemLayoutSizeFitting(
            CGSize(width: targetWidth, height: UIView.layoutFittingCompressedSize.height)
        )
        header.frame = CGRect(x: 0, y: 0, width: targetWidth, height: fittingSize.height)
        cityTableView.tableHeaderView = header
    }
}

extension CitySearchViewController: CitySearchViewProtocol {
    func displayCities(_ viewModel: CitySearchModels.ViewModel) {
        cities = viewModel.cities

        let hasResults = !cities.isEmpty
        cityTableView.isHidden = false
        emptyStateLabel.isHidden = hasResults || (searchController.searchBar.text ?? "").isEmpty

        cityTableView.reloadData()
    }

    func displayLoading(_ isLoading: Bool) {
        if isLoading {
            searchController.searchBar.showLoadingIndicator(searchLoadingIndicator)
        } else {
            searchController.searchBar.hideLoadingIndicator(searchLoadingIndicator)
        }
    }

    func displayLocationLoading(_ isLoading: Bool) {
        currentLocationButton.setLoading(isLoading)
    }

    func displayLocationError(_ message: String) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    func routeToWeatherScreen() {
        tabBarController?.selectedIndex = 1
    }
}

extension CitySearchViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cities.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: CityResultCell.reuseIdentifier,
            for: indexPath
        ) as? CityResultCell else {
            return UITableViewCell()
        }
        
        cell.configure(with: cities[indexPath.row])
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        presenter?.didSelectCity(at: indexPath.row)
    }
}

extension CitySearchViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        presenter?.didUpdateSearch(text: searchController.searchBar.text ?? "")
    }
}
