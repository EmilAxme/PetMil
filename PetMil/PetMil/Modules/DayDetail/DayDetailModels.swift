//
//  DayDetailModels.swift
//  PetMil
//
//  Created by Emil on 07.04.2026.
//

import Foundation

enum DayDetailsModels {
    struct ViewModel {
        let dayText: String
        let temperatureText: String
        let descriptionText: String
        let chartPoints: [ChartPoint]
        let selectedPoint: ChartPoint
    }
    
    struct ChartPoint {
        let timeText: String
        let temperatureText: String
        let feelsLikeText: String
        let humidityText: String
        let windText: String
        let pressureText: String
        let rawTemperature: Double
    }
}
