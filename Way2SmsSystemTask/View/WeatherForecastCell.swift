//
//  WeatherForecastCell.swift
//  Way2SmsSystemTask
//
//  Created by Pradeep's Macbook on 19/02/21.
//  Copyright © 2021 Motiv Ate Fitness. All rights reserved.
//

import UIKit
import Combine

class WeatherForecastCell: BaseTableViewCell {
    
    //MARK: - Property Observers

    
    var daily: Daily? {
        didSet {
            guard let daily = daily else { return }
            self.updateUI(daily)
        }
    }
    
    //MARK: - Views
    
    private lazy var weatherIconImageView: UIImageView = {
        let v = UIImageView()
        v.backgroundColor = .clear
        v.contentMode = .scaleAspectFit
        v.constrainWidth(constant: 75)
        v.constrainHeight(constant: 75)
        return v
    }()
    
    private lazy var dateLabel: UILabel = {
        let label = UILabel()
        label.text = "Fri, Feb, 19"
        label.font = .systemFont(ofSize: 17, weight: .bold)
        return label
    }()
    
    private lazy var weatherDescription: UILabel = {
        let label = UILabel()
        label.text = "Cloudy"
        label.font = .systemFont(ofSize: 17, weight: .semibold)
        return label
    }()
    
    private lazy var minMaxLabel: UILabel = {
        let label = UILabel()
        label.text = "H: 1° L: 0°"
        return label
    }()
    
    private lazy var cloudsPop: UILabel = {
        let label = UILabel()
        label.text = "☁️ 98% 💧 100%"
        return label
    }()
    
    private lazy var humidity: UILabel = {
        let label = UILabel()
        label.text = "Humidity: 96%"
        return label
    }()
    
    private lazy var textComponentsStackView: UIStackView = {
        let sv = UIStackView.init(arrangedSubviews: [
        weatherDescription,
        minMaxLabel,
        cloudsPop,
        humidity
        ])
        sv.axis = .vertical
        sv.distribution = .fill
        sv.alignment = .leading
        sv.isLayoutMarginsRelativeArrangement = true
        sv.spacing = 4
        sv.layoutMargins = .init(top: 12, left: 24, bottom: 12, right: 16)
        return sv
    }()
    
    private lazy var hStackView: UIStackView = {
        let sv = UIStackView.init(arrangedSubviews: [
            weatherIconImageView,
            textComponentsStackView
        ])
        sv.axis = .horizontal
        sv.distribution = .fill
        sv.alignment = .center
        sv.isLayoutMarginsRelativeArrangement = true
        sv.layoutMargins = .init(top: 0, left: 32, bottom: 0, right: 16)
        return sv
    }()
    
    private lazy var rootVStackView: UIStackView = {
        let sv = UIStackView.init(arrangedSubviews: [
            dateLabel,
            hStackView
        ])
        sv.axis = .vertical
        sv.distribution = .fill
        sv.alignment = .leading
        sv.isLayoutMarginsRelativeArrangement = true
        sv.layoutMargins = .init(top: 8, left: 24, bottom: 8, right: 16)
        return sv
    }()
    
    //MARK: - Overrides
    
    override func configureViewComponents() {
        self.setupConstraints()
    }
    
    fileprivate func setupConstraints() {
        self.addSubviewsToParent(rootVStackView)
        rootVStackView.fillSuperview()
    }
    
    //MARK: - Helper Functions
    
    private func updateUI(_ item: Daily) {
        self.fetchWeatherImageIcon(iconURL: item.weatherIconURL)
        self.weatherDescription.text = item.overview
        self.minMaxLabel.text = "\(item.high) \(item.low)"
        self.cloudsPop.text   = "\(item.cloudsValue) \(item.popValue)"
        self.humidity.text    = "\(item.humidityValue)"
        self.dateLabel.text   = "\(item.day)"
    }
    
    private func fetchWeatherImageIcon(iconURL: URL) {
        AsyncImageDownloader.downloadImage(with: iconURL) { (result) in
            switch result {
            case .success(let image):
                self.weatherIconImageView.image = image
            case .failure(let error):
                OverlayView.sharedInstance.hideOverlay()
                print("error: \(error)")
            }
        }
    }
}
