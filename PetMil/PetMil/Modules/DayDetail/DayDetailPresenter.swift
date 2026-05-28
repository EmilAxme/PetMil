//
//  DayDetailPresenter.swift
//  PetMil
//
//  Created by Emil on 07.04.2026.
//

import Foundation

protocol DayDetailsPresenterProtocol: AnyObject {
    func viewDidLoad()
    func didSelectChartPoint(at index: Int)
}

final class DayDetailsPresenter {

    weak var view: DayDetailsViewProtocol?

    private let dayForecast: DailyForecast
    private let formatter: UnitFormatterProtocol
    private let l10n: L10n
    private var chartPoints: [DayDetailsModels.ChartPoint] = []

    init(
        dayForecast: DailyForecast,
        formatter: UnitFormatterProtocol,
        l10n: L10n = .shared
    ) {
        self.dayForecast = dayForecast
        self.formatter = formatter
        self.l10n = l10n
    }
}

extension DayDetailsPresenter: DayDetailsPresenterProtocol {
    func viewDidLoad() {
        chartPoints = dayForecast.hourlyItems.map { item in
            let pressureFormatted = formatter.pressure(item.pressure)
            return DayDetailsModels.ChartPoint(
                timeText: formatter.clockTime(item.date),
                temperatureText: formatter.temperature(item.temperature),
                feelsLikeText: formatter.temperature(item.feelsLike),
                humidityText: formatter.humidity(item.humidity),
                windText: formatter.windSpeed(item.windSpeed),
                pressureText: "\(pressureFormatted.value) \(pressureFormatted.unit)",
                rawTemperature: item.temperature
            )
        }

        guard let firstPoint = chartPoints.first else { return }

        let viewModel = DayDetailsModels.ViewModel(
            dayText: formattedDay(from: dayForecast.date),
            temperatureText: formatter.temperature(dayForecast.currentTemperature),
            descriptionText: dayForecast.summary,
            chartPoints: chartPoints,
            selectedPoint: firstPoint
        )

        view?.displayDayDetails(viewModel: viewModel)
    }
    
    func didSelectChartPoint(at index: Int) {
        guard chartPoints.indices.contains(index) else { return }
        view?.displaySelectedChartPoint(chartPoints[index])
    }
}

private extension DayDetailsPresenter {
    func formattedDay(from date: Date) -> String {
        if Calendar.current.isDateInToday(date) { return l10n.today }
        if Calendar.current.isDateInTomorrow(date) { return l10n.tomorrow }
        return formatter.weekday(from: date)
    }
}
