//
//  WeatherViewController.swift
//  PetMil
//
//  Created by Emil on 04.03.2026.
//

import UIKit

protocol WeatherViewProtocol: AnyObject {
    func displayWeather(viewModel: WeatherModels.ViewModel)
}

class WeatherViewController: UIViewController {
    
    var presenter: WeatherPresenterProtocol?
    
    private lazy var headerView = WeatherHeaderView()

    private lazy var weatherTableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.backgroundColor = .clear
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .singleLine
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 72
        tableView.register(ForecastDayCell.self, forCellReuseIdentifier: ForecastDayCell.reuseIdentifier)
        return tableView
    }()
    
    private var forecastRows: [WeatherModels.ForecastRow] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupAppearance()
        setupLayout()
        presenter?.viewDidLoad()
    }

}

private extension WeatherViewController {
    func setupAppearance() {
        view.backgroundColor = .systemBackground
    }
    
    func setupLayout() {
        view.addToView(headerView)
        view.addToView(weatherTableView)
        
        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            weatherTableView.topAnchor.constraint(equalTo: headerView.bottomAnchor),
            weatherTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            weatherTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            weatherTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}

extension WeatherViewController: WeatherViewProtocol {
    func displayWeather(viewModel: WeatherModels.ViewModel) {
        title = viewModel.screenTitle
        forecastRows = viewModel.rows
        
        headerView.configure(
            city: viewModel.city,
            temperature: viewModel.currentTemperature,
            summary: viewModel.currentDescription
        )
        
        weatherTableView.reloadData()
    }
}

extension WeatherViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        forecastRows.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: ForecastDayCell.reuseIdentifier,
            for: indexPath
        ) as? ForecastDayCell else {
            return UITableViewCell()
        }
        
        cell.configure(with: forecastRows[indexPath.row])
        return cell
    }
}
