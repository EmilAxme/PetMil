//
//  DayDetailViewController.swift
//  PetMil
//
//  Created by Emil on 07.04.2026.
//

import UIKit

protocol DayDetailsViewProtocol: AnyObject {
    func displayDayDetails(viewModel: DayDetailsModels.ViewModel)
    func displaySelectedChartPoint(_ point: DayDetailsModels.ChartPoint)
}

final class DayDetailsViewController: UIViewController {
    
    var presenter: DayDetailsPresenterProtocol?
    
    private var chartPoints: [DayDetailsModels.ChartPoint] = []
    
    private lazy var dayLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 30, weight: .bold)
        label.textColor = .label
        label.textAlignment = .center
        return label
    }()
    
    private lazy var temperatureLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 72, weight: .bold)
        label.textColor = .label
        label.textAlignment = .center
        label.numberOfLines = 1
        label.setContentCompressionResistancePriority(.required, for: .vertical)
        label.setContentHuggingPriority(.required, for: .vertical)
        return label
    }()
    
    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 22, weight: .medium)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.numberOfLines = 1
        label.setContentCompressionResistancePriority(.required, for: .vertical)
        label.setContentHuggingPriority(.required, for: .vertical)
        return label
    }()
    
    private lazy var chartContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .secondarySystemBackground
        view.layer.cornerRadius = 24
        view.layer.cornerCurve = .continuous
        return view
    }()
    
    private lazy var chartView: TemperatureChartView = {
        let view = TemperatureChartView()
        view.onPointSelected = { [weak self] index in
            self?.presenter?.didSelectChartPoint(at: index)
        }
        return view
    }()
    
    private lazy var timeAxisView: TimeAxisView = {
        let view = TimeAxisView()
        return view
    }()
    
    private lazy var selectedTimeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .semibold)
        label.textColor = .label
        label.textAlignment = .center
        return label
    }()
    
    private lazy var detailsContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .secondarySystemBackground
        view.layer.cornerRadius = 24
        view.layer.cornerCurve = .continuous
        return view
    }()
    
    private lazy var temperatureRow = makeDetailRow(title: "Temperature")
    private lazy var feelsLikeRow = makeDetailRow(title: "Feels like")
    private lazy var humidityRow = makeDetailRow(title: "Humidity")
    private lazy var windRow = makeDetailRow(title: "Wind")
    private lazy var pressureRow = makeDetailRow(title: "Pressure")
    
    private lazy var detailsStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [
            temperatureRow,
            makeSeparatorView(),
            feelsLikeRow,
            makeSeparatorView(),
            humidityRow,
            makeSeparatorView(),
            windRow,
            makeSeparatorView(),
            pressureRow
        ])
        stack.axis = .vertical
        stack.spacing = 0
        return stack
    }()
    
    private lazy var temperatureContainerView: UIView = {
        let view = UIView()
        return view
    }()

    private lazy var contentStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [
            dayLabel,
            temperatureContainerView,
            descriptionLabel,
            chartContainerView,
            selectedTimeLabel,
            detailsContainerView
        ])
        stack.axis = .vertical
        stack.spacing = 16
        return stack
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupAppearance()
        setupLayout()
        presenter?.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
}

private extension DayDetailsViewController {
    func setupAppearance() {
        view.backgroundColor = .systemBackground
        title = "Details"
    }
    
    func setupLayout() {
        view.addToView(contentStackView)
        chartContainerView.addToView(chartView)
        chartContainerView.addToView(timeAxisView)
        detailsContainerView.addToView(detailsStackView)
        temperatureContainerView.addToView(temperatureLabel)
        
        NSLayoutConstraint.activate([
            temperatureLabel.topAnchor.constraint(equalTo: temperatureContainerView.topAnchor),
            temperatureLabel.leadingAnchor.constraint(equalTo: temperatureContainerView.leadingAnchor),
            temperatureLabel.trailingAnchor.constraint(equalTo: temperatureContainerView.trailingAnchor),
            temperatureLabel.bottomAnchor.constraint(equalTo: temperatureContainerView.bottomAnchor),

            temperatureContainerView.heightAnchor.constraint(greaterThanOrEqualToConstant: 90),
            
            contentStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            contentStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            contentStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            contentStackView.bottomAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            
            chartView.topAnchor.constraint(equalTo: chartContainerView.topAnchor, constant: 16),
            chartView.leadingAnchor.constraint(equalTo: chartContainerView.leadingAnchor, constant: 12),
            chartView.trailingAnchor.constraint(equalTo: chartContainerView.trailingAnchor, constant: -12),
            chartView.heightAnchor.constraint(equalToConstant: 180),

            timeAxisView.topAnchor.constraint(equalTo: chartView.bottomAnchor, constant: 12),
            timeAxisView.leadingAnchor.constraint(equalTo: chartContainerView.leadingAnchor),
            timeAxisView.trailingAnchor.constraint(equalTo: chartContainerView.trailingAnchor),
            timeAxisView.bottomAnchor.constraint(equalTo: chartContainerView.bottomAnchor, constant: -16),
            timeAxisView.heightAnchor.constraint(equalToConstant: 20),

            detailsStackView.topAnchor.constraint(equalTo: detailsContainerView.topAnchor, constant: 8),
            detailsStackView.leadingAnchor.constraint(equalTo: detailsContainerView.leadingAnchor, constant: 16),
            detailsStackView.trailingAnchor.constraint(equalTo: detailsContainerView.trailingAnchor, constant: -16),
            detailsStackView.bottomAnchor.constraint(equalTo: detailsContainerView.bottomAnchor, constant: -8)
        ])
    }
    
    func makeDetailRow(title: String) -> DetailRowView {
        DetailRowView(title: title)
    }
    
    func makeSeparatorView() -> UIView {
        let view = UIView()
        view.backgroundColor = .separator
        view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            view.heightAnchor.constraint(equalToConstant: 1)
        ])
        return view
    }
}

extension DayDetailsViewController: DayDetailsViewProtocol {
    func displaySelectedChartPoint(_ point: DayDetailsModels.ChartPoint) {
        selectedTimeLabel.text = "Time: \(point.timeText)"
        temperatureRow.configure(value: point.temperatureText)
        feelsLikeRow.configure(value: point.feelsLikeText)
        humidityRow.configure(value: point.humidityText)
        windRow.configure(value: point.windText)
        pressureRow.configure(value: point.pressureText)
        
        if let selectedIndex = chartPoints.firstIndex(where: { $0.timeText == point.timeText }) {
            chartView.updateSelectedIndex(selectedIndex)
            timeAxisView.configure(
                timeTexts: chartPoints.map(\.timeText),
                selectedIndex: selectedIndex
            )
        }
    }
    
    func displayDayDetails(viewModel: DayDetailsModels.ViewModel) {
        dayLabel.text = viewModel.dayText
        temperatureLabel.text = viewModel.temperatureText
        descriptionLabel.text = viewModel.descriptionText
        
        chartPoints = viewModel.chartPoints
        
        let temperatures = chartPoints.map(\.rawTemperature)
        let timeTexts = chartPoints.map(\.timeText)
        
        chartView.configure(temperatures: temperatures, selectedIndex: 0)
        timeAxisView.configure(timeTexts: timeTexts, selectedIndex: 0)
        
        displaySelectedChartPoint(viewModel.selectedPoint)
    }
}
