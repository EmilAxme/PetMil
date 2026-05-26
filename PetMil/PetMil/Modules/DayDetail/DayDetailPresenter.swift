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
    private var chartPoints: [DayDetailsModels.ChartPoint] = []
    
    init(dayForecast: DailyForecast) {
        self.dayForecast = dayForecast
    }
}

extension DayDetailsPresenter: DayDetailsPresenterProtocol {
    func viewDidLoad() {
        chartPoints = dayForecast.hourlyItems.map { item in
            DayDetailsModels.ChartPoint(
                timeText: formattedTime(from: item.date),
                temperatureText: "\(Int(item.temperature.rounded()))°",
                feelsLikeText: "\(Int(item.feelsLike.rounded()))°",
                humidityText: "\(item.humidity)%",
                windText: "\(Int(item.windSpeed.rounded())) m/s",
                pressureText: "\(item.pressure) hPa",
                rawTemperature: item.temperature
            )
        }
        
        guard let firstPoint = chartPoints.first else { return }
        
        let viewModel = DayDetailsModels.ViewModel(
            dayText: formattedDay(from: dayForecast.date),
            temperatureText: "\(Int(dayForecast.currentTemperature.rounded()))°",
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
    func formattedTime(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
    
    func formattedDay(from date: Date) -> String {
        if Calendar.current.isDateInToday(date) {
            return "Today"
        }
        
        if Calendar.current.isDateInTomorrow(date) {
            return "Tomorrow"
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        return formatter.string(from: date)
    }
}
