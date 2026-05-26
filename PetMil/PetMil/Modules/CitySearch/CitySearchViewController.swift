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
}

extension CitySearchViewController: CitySearchViewProtocol {
    func displayCities(_ viewModel: CitySearchModels.ViewModel) {
        cities = viewModel.cities

        let isEmpty = cities.isEmpty
        cityTableView.isHidden = isEmpty
        emptyStateLabel.isHidden = !isEmpty

        cityTableView.reloadData()
    }

    func displayLoading(_ isLoading: Bool) {
        if isLoading {
            searchController.searchBar.showLoadingIndicator(searchLoadingIndicator)
        } else {
            searchController.searchBar.hideLoadingIndicator(searchLoadingIndicator)
        }
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
