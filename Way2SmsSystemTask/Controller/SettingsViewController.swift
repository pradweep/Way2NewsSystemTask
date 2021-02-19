//
//  SettingsViewController.swift
//  Way2SmsSystemTask
//
//  Created by Pradeep's Macbook on 18/02/21.
//  Copyright © 2021 Motiv Ate Fitness. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {
    
    //MARK: - Properties
    
    //MARK: - Views
    
    private lazy var toggleMetricsLabel: UILabel = {
        let v = UILabel()
        v.text = "Select Weather Forecast Metrics"
        v.font = .systemFont(ofSize: 15, weight: .semibold)
        return v
    }()
    
    private lazy var metricsSegmentedControl: UISegmentedControl = {
        let v = UISegmentedControl(items: [
            "°C",
            "°F"
        ])
        v.selectedSegmentIndex = 0
        v.addTarget(self, action: #selector(handleSegmentEvent), for: .valueChanged)
        v.constrainWidth(constant: 100)
        return v
    }()
    
    private lazy var metricsStackView: UIStackView = {
        let sv = UIStackView.init(arrangedSubviews: [
            toggleMetricsLabel,
            metricsSegmentedControl
        ])
        sv.distribution = .fill
        sv.axis = .horizontal
        sv.alignment = .center
        return sv
    }()
    
    private lazy var resetBookmarkedLocationsLabel: UILabel = {
        let v = UILabel()
        v.text = "Reset Bookmarked Locations"
        v.font = .systemFont(ofSize: 15, weight: .semibold)
        return v
    }()
    
    private lazy var resetboomarkedLocationsBtn: UIButton = {
        let v = UIButton(type: .system)
        v.setTitle("Reset", for: .normal)
        v.setTitleColor(.systemRed, for: .normal)
        v.addTarget(self, action: #selector(handleResetAction), for: .touchUpInside)
        v.titleLabel?.font = .boldSystemFont(ofSize: 17)
        v.constrainWidth(constant: 100)
        return v
    }()
    
    private lazy var resetComponentStackView: UIStackView = {
        let sv = UIStackView.init(arrangedSubviews: [
            resetBookmarkedLocationsLabel,
            resetboomarkedLocationsBtn
        ])
        sv.distribution = .fill
        sv.axis = .horizontal
        sv.alignment = .center
        return sv
    }()
    
    //MARK: - LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.computeMetrics()
        self.configureViewComponents()
        self.toggleButtonEnabledProperty()
    }
    
    //MARK: - ConfigureViewComponents
    
    fileprivate func computeMetrics() {
        let systemMetrics = UserDefaults.standard.getMetricsToggle()
        metricsSegmentedControl.selectedSegmentIndex = systemMetrics
    }
    
    fileprivate func configureViewComponents() {
        self.configureNavBar()
        self.view.backgroundColor = .white
        self.setupConstraints()
    }
    
    fileprivate func setupConstraints() {
        self.view.addSubviewsToParent(metricsStackView,
                                      resetComponentStackView)
        metricsStackView.anchor(top: self.view.safeAreaLayoutGuide.topAnchor, leading: self.view.leadingAnchor, bottom: nil, trailing: self.view.trailingAnchor, padding: .init(top: 8, left: 16, bottom: 0, right: 16), size: .init(width: 0, height: 50))
        resetComponentStackView.anchor(top: metricsStackView.bottomAnchor, leading: metricsStackView.leadingAnchor, bottom: nil, trailing: metricsStackView.trailingAnchor, padding: .init(top: 8, left: 0, bottom: 0, right: 0), size: .init(width: 0, height: 50))
    }
    
    fileprivate func configureNavBar() {
        self.title = "Settings"
        self.navigationController?.navigationBar.barStyle = .default
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "ic_back"), style: .plain, target: self, action: #selector(handleBackAction))
    }
    
    fileprivate func toggleButtonEnabledProperty() {
        if let locations = UserDefaults.standard.getBookmarkedLocations(), locations.count > 0  {
            resetboomarkedLocationsBtn.isEnabled = true
            resetboomarkedLocationsBtn.alpha = 1.0
        } else {
            resetboomarkedLocationsBtn.isEnabled = false
            resetboomarkedLocationsBtn.alpha = 0.5
        }
    }
    
    //MARK:  - Selectors
    
    @objc fileprivate func handleBackAction() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc fileprivate func handleSegmentEvent() {
        print("Selected segmented index: \(metricsSegmentedControl.selectedSegmentIndex)")
        UserDefaults.standard.setMetricsToggle(metricsSegmentedControl.selectedSegmentIndex)
    }
    
    @objc fileprivate func handleResetAction() {
        let okAction = UIAlertAction.init(title: "Ok", style: .default) { (action) in
            UserDefaults.clear()
            self.toggleButtonEnabledProperty()
        }
        let cancelAction = UIAlertAction.init(title: "Cancel", style: .default) { (action) in
            UserDefaults.clear()
        }
        AlertController.show(.alert, title: "Alert", message: "Would you like to reset?", actions: [cancelAction,okAction], completion: nil)
    }
    
}
