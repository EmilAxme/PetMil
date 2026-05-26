//
//  WeatherViewController.swift
//  PetMil
//
//  Created by Emil on 04.03.2026.
//

import UIKit

protocol WeatherViewProtocol: AnyObject {
    func displayState(_ state: WeatherModels.ViewState)
}

final class WeatherViewController: UIViewController {
    
    var presenter: WeatherPresenterProtocol?
    
    var weatherIconService: WeatherIconServiceProtocol?
    
    private var forecastRows: [WeatherModels.ForecastRow] = []
    
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
    
    private lazy var loadingView = WeatherLoadingView()
    
    private lazy var refreshControl: UIRefreshControl = {
        let control = UIRefreshControl()
        control.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        return control
    }()

    private lazy var weatherTableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 88
        tableView.showsVerticalScrollIndicator = false
        tableView.backgroundColor = .clear
        tableView.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 16, right: 0)
        tableView.register(ForecastDayCell.self, forCellReuseIdentifier: ForecastDayCell.reuseIdentifier)
        return tableView
    }()
    
    private lazy var errorView: WeatherErrorView = {
        let view = WeatherErrorView()
        view.isHidden = true
        view.onRetryTapped = { [weak self] in
            self?.presenter?.retryButtonTapped()
        }
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupAppearance()
        setupLayout()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        presenter?.viewWillAppear()
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
        contentContainerView.addToView(weatherTableView)
        view.addToView(errorView)
        view.addToView(loadingView)
        
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
            weatherTableView.bottomAnchor.constraint(equalTo: contentContainerView.bottomAnchor),
            
            errorView.topAnchor.constraint(equalTo: view.topAnchor),
            errorView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            errorView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            errorView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            loadingView.topAnchor.constraint(equalTo: view.topAnchor),
            loadingView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            loadingView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            loadingView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    func setLoadingState() {
        headerView.isHidden = true
        contentContainerView.isHidden = true
        errorView.isHidden = true
        
        loadingView.show()
    }

    func setContentState(viewModel: WeatherModels.ViewModel) {
        forecastRows = viewModel.rows
        
        headerView.configure(
            city: viewModel.city,
            temperature: viewModel.currentTemperature,
            summary: viewModel.currentDescription
        )
        
        weatherIconService?.loadIcon(
            into: headerView.iconImageView,
            iconCode: viewModel.currentIconCode
        )
        
        weatherTableView.reloadData()
        
        headerView.isHidden = false
        contentContainerView.isHidden = false
        errorView.isHidden = true
        
        loadingView.hideAnimated()
    }

    func setErrorState(message: String) {
        loadingView.isHidden = true
        
        headerView.isHidden = true
        contentContainerView.isHidden = true
        
        errorView.isHidden = false
        errorView.configure(message: message)
    }
}

extension WeatherViewController: WeatherViewProtocol {
    func displayState(_ state: WeatherModels.ViewState) {
        switch state {
        case .loading:
            setLoadingState()
        case .content(let viewModel):
            setContentState(viewModel: viewModel)
        case .error(let message):
            setErrorState(message: message)
        }
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
        
        weatherIconService?.loadIcon(
            into: cell.iconImageView,
            iconCode: forecastRows[indexPath.row].iconCode
        )
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let selectedDay = forecastRows[indexPath.row].dailyForecast
        let detailsViewController = DayDetailsAssembly.build(dayForecast: selectedDay)
        detailsViewController.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(detailsViewController, animated: true)
    }
}
