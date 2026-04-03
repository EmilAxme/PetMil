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

final class WeatherViewController: UIViewController {
    
    var presenter: WeatherPresenterProtocol?
    
    private lazy var backgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBlue.withAlphaComponent(0.15)
        return view
    }()
    
    private lazy var contentContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .secondarySystemBackground.withAlphaComponent(1)
        view.layer.cornerRadius = 24
        view.layer.cornerCurve = .continuous
        return view
    }()
    
    private lazy var headerView = WeatherHeaderView()

    private lazy var weatherTableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.backgroundColor = .clear
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .singleLine
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 72
        tableView.showsVerticalScrollIndicator = false
        tableView.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 16, right: 0)
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
        view.addToView(backgroundView)
        view.addToView(headerView)
        view.addToView(contentContainerView)
        view.addToView(weatherTableView)
        
        NSLayoutConstraint.activate([
            backgroundView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            headerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            contentContainerView.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 16),
            contentContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            contentContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            contentContainerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -12),
            
            weatherTableView.topAnchor.constraint(equalTo: contentContainerView.topAnchor),
            weatherTableView.leadingAnchor.constraint(equalTo: contentContainerView.leadingAnchor),
            weatherTableView.trailingAnchor.constraint(equalTo: contentContainerView.trailingAnchor),
            weatherTableView.bottomAnchor.constraint(equalTo: contentContainerView.bottomAnchor)
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
