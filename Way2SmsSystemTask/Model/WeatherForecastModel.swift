//
//  WeatherForecastModel.swift
//  Way2SmsSystemTask
//
//  Created by Pradeep's Macbook on 19/02/21.
//  Copyright © 2021 Motiv Ate Fitness. All rights reserved.
//

import UIKit

struct WeatherForecastModel: Codable {
    let daily: [Daily]
    
}

struct Daily: Codable {
    
    let dt: Date
    let temp: Temp
    let humidity: Int
    let weather: [Weather]
    let clouds: Int
    let pop: Double
    
    private static var dateFormatter: DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "E, MMM, d"
        return dateFormatter
    }
    
    private static var numberFormatter: NumberFormatter {
        let numberFormatter = NumberFormatter()
        numberFormatter.maximumFractionDigits = 0
        return numberFormatter
    }
    
    private static var numberFormatter2: NumberFormatter {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .percent
        return numberFormatter
    }

    func convert(_ temp: Double) -> Double {
        let celsius = temp - 273.5
        let systemMetrics = UserDefaults.standard.getMetricsToggle()
        if systemMetrics == 0 {
            return celsius
        } else {
            return celsius * 9 / 5 + 32
        }
    }
    
    var day: String {
        return Self.dateFormatter.string(from: dt)
    }
    
    var overview: String {
        weather[0].description.capitalized
    }
    
    var high: String {
        return "H: \(Self.numberFormatter.string(for: convert(temp.max)) ?? "0")°"
    }
    
    var low: String {
        return "L: \(Self.numberFormatter.string(for: convert(temp.min)) ?? "0")°"
    }
    
    var popValue: String {
        return "💧 \(Self.numberFormatter2.string(for: pop) ?? "0%")"
    }
    
    var cloudsValue: String {
        return "☁️ \(clouds)%"
    }

    var humidityValue: String {
        return "Humidity: \(humidity)%"
    }
    
    var weatherIconURL: URL {
        let urlString = "https://openweathermap.org/img/wn/\(weather[0].icon)@2x.png"
        return URL(string: urlString)!
    }
    
}

struct Temp: Codable {
    let min: Double
    let max: Double
}

struct Weather: Codable {
    let id: Int
    let description: String
    let icon: String
}
