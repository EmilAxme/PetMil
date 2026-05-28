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
    var imageLoaderService: ImageLoaderServiceProtocol?

    private var forecastRows: [WeatherModels.ForecastRow] = []
    private var backgroundPhotoTask: Task<Void, Never>?

    private lazy var backgroundPhotoView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()

    private lazy var backgroundDimView: UIView = {
        let view = UIView()
        view.backgroundColor = .black.withAlphaComponent(0.35)
        return view
    }()

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

    private lazy var hourlyForecastView = HourlyForecastView()

    private lazy var conditionGridView = ConditionGridView()

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
        tableView.refreshControl = refreshControl
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

    private lazy var emptyCityView: WeatherEmptyCityView = {
        let view = WeatherEmptyCityView()
        view.isHidden = true
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupAppearance()
        setupLayout()
        setupTableHeaderView()
        hourlyForecastView.weatherIconService = weatherIconService
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        layoutTableHeaderIfNeeded()
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
        view.addToView(backgroundPhotoView)
        view.addToView(backgroundDimView)
        view.addToView(backgroundView)
        view.addToView(headerView)
        view.addToView(hourlyForecastView)
        view.addToView(contentContainerView)
        contentContainerView.addToView(weatherTableView)
        view.addToView(errorView)
        view.addToView(emptyCityView)
        view.addToView(loadingView)

        NSLayoutConstraint.activate([
            backgroundPhotoView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundPhotoView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundPhotoView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundPhotoView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            backgroundDimView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundDimView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundDimView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundDimView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            backgroundView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            headerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            hourlyForecastView.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 12),
            hourlyForecastView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            hourlyForecastView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            contentContainerView.topAnchor.constraint(equalTo: hourlyForecastView.bottomAnchor, constant: 12),
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

            emptyCityView.topAnchor.constraint(equalTo: view.topAnchor),
            emptyCityView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            emptyCityView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            emptyCityView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            loadingView.topAnchor.constraint(equalTo: view.topAnchor),
            loadingView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            loadingView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            loadingView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    func setupTableHeaderView() {
        let container = UIView()
        container.addSubview(conditionGridView)
        conditionGridView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            conditionGridView.topAnchor.constraint(equalTo: container.topAnchor, constant: 8),
            conditionGridView.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            conditionGridView.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
            conditionGridView.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -12)
        ])

        weatherTableView.tableHeaderView = container
    }

    func layoutTableHeaderIfNeeded() {
        guard let header = weatherTableView.tableHeaderView else { return }
        let targetWidth = weatherTableView.bounds.width
        guard targetWidth > 0 else { return }

        let size = header.systemLayoutSizeFitting(
            CGSize(width: targetWidth, height: UIView.layoutFittingCompressedSize.height)
        )

        if abs(header.frame.height - size.height) > 0.5 || header.frame.width != targetWidth {
            header.frame = CGRect(x: 0, y: 0, width: targetWidth, height: size.height)
            weatherTableView.tableHeaderView = header
        }
    }

    func setLoadingState() {
        headerView.isHidden = true
        hourlyForecastView.isHidden = true
        contentContainerView.isHidden = true
        errorView.isHidden = true

        loadingView.show()
    }

    @objc func handleRefresh() {
        presenter?.refreshWeather()
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

        hourlyForecastView.configure(with: viewModel.hourlyRows)

        conditionGridView.configure(with: viewModel.conditionTiles)
        layoutTableHeaderIfNeeded()

        loadBackgroundPhoto(url: viewModel.backgroundPhotoURL)

        weatherTableView.reloadData()
        refreshControl.endRefreshing()

        let hasHourly = !viewModel.hourlyRows.isEmpty

        headerView.alpha = 0
        hourlyForecastView.alpha = 0
        contentContainerView.alpha = 0
        headerView.isHidden = false
        hourlyForecastView.isHidden = !hasHourly
        contentContainerView.isHidden = false
        errorView.isHidden = true
        emptyCityView.isHidden = true

        loadingView.hideAnimated {
            UIView.animate(withDuration: 0.4, delay: 0, options: .curveEaseOut) {
                self.headerView.alpha = 1
                self.hourlyForecastView.alpha = 1
                self.contentContainerView.alpha = 1
            }
        }
    }

    func loadBackgroundPhoto(url: URL?) {
        backgroundPhotoTask?.cancel()

        guard let url else {
            backgroundPhotoView.image = nil
            backgroundView.backgroundColor = .systemBlue.withAlphaComponent(0.15)
            backgroundDimView.isHidden = true
            return
        }

        backgroundDimView.isHidden = false

        backgroundPhotoTask = Task { [weak self] in
            guard let self else { return }
            let image = await imageLoaderService?.loadImage(from: url)
            await MainActor.run {
                UIView.transition(
                    with: self.backgroundPhotoView,
                    duration: 0.4,
                    options: .transitionCrossDissolve
                ) {
                    self.backgroundPhotoView.image = image
                    self.backgroundView.backgroundColor = image != nil ? .clear : .systemBlue.withAlphaComponent(0.15)
                }
            }
        }
    }

    func setErrorState(message: String) {
        loadingView.isHidden = true

        headerView.isHidden = true
        hourlyForecastView.isHidden = true
        contentContainerView.isHidden = true
        emptyCityView.isHidden = true

        errorView.isHidden = false
        errorView.configure(message: message)
    }

    func setNoCityState() {
        loadingView.isHidden = true
        headerView.isHidden = true
        hourlyForecastView.isHidden = true
        contentContainerView.isHidden = true
        errorView.isHidden = true

        emptyCityView.isHidden = false
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
        case .noCitySelected:
            setNoCityState()
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
