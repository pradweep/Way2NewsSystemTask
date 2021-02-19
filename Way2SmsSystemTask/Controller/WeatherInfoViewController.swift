//
//  WeatherInfoViewController.swift
//  Way2SmsSystemTask
//
//  Created by Pradeep's Macbook on 18/02/21.
//  Copyright © 2021 Motiv Ate Fitness. All rights reserved.
//

import UIKit
import Combine

class WeatherInfoViewController: UIViewController {
    
    //MARK: - Closure Sleeve Actions
    
    var validLocationCompletionCallBack: (() -> ())?
    
    //MARK: - Private Properties
    
    private lazy var searchController = UISearchController(searchResultsController: nil)
    private var sink: AnyCancellable?
    private var weeklyForecastModel: [Daily]?
    private var successfulResponse: Bool = false
    private var bookmarkedLocationsArray = [String]()
    private var searchedLocation = ""
    
    //MARK: - Properties
    
    var bookmarkedCityName: String? {
        didSet {
            guard let cityName = bookmarkedCityName, !cityName.isEmpty, cityName != "No Location" else {
                self.title = "No Location"
                return
            }
            self.title = cityName
            self.fetchWeatherInfo(for: cityName)
        }
    }
    
    //MARK: - Views
    
    private lazy var weatherForecasrTableView: GenericTableView<Daily, WeatherForecastCell> =  {
        let v = GenericTableView<Daily, WeatherForecastCell>.init(data: weeklyForecastModel ?? [Daily](), canEditRow: false,separatorStyle: .singleLine,config: { (cell, daily) in
            cell.daily = daily
        }, selectionHandler: { (daily) in
            print("todo block")
        }) { (_,_,_) in
            print("nil block")
        }
        return v
    }()
    
    //MARK: - LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureViewComponents()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        if let persistedLocations = UserDefaults.standard.getBookmarkedLocations() {
            self.bookmarkedLocationsArray = persistedLocations
        }
    }
    
    //MARK: - ConfigureViewComponents
    
    fileprivate func configureViewComponents() {
        self.configureSearchController()
        self.configureNavBar()
        self.view.backgroundColor = .white
        self.setupConstraints()
        self.setupSearchBarListeners()
    }
    
    fileprivate func setupConstraints() {
        self.view.addSubviewsToParent(weatherForecasrTableView)
        weatherForecasrTableView.fillSuperview()
    }
    
    fileprivate func configureNavBar() {
        self.navigationController?.navigationBar.barStyle = .default
        self.navigationController?.navigationBar.shadowImage = UIImage()
        let mapBarItem = UIBarButtonItem(image: #imageLiteral(resourceName: "ic_location"), style: .plain, target: self, action: #selector(handleMapAction))
        let bookmarkItem = UIBarButtonItem(image: #imageLiteral(resourceName: "ic_bookmark"), style: .plain, target: self, action: #selector(handleBookmarkAction))
        self.navigationItem.rightBarButtonItems = [mapBarItem,bookmarkItem]
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "ic_back"), style: .plain, target: self, action: #selector(handleBackAction))
    }
    
    fileprivate func configureSearchController() {
        self.navigationItem.searchController = searchController
        self.navigationController?.navigationBar.barTintColor = .white
        self.navigationController?.navigationItem.searchController?.searchBar.searchTextField.placeholder = "Search your location"
        searchController.definesPresentationContext = true
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.delegate = self
    }
    
    fileprivate func routeToLocationVC() {
        let locationSelectionVC = LocationSelectionVC()
        locationSelectionVC.completionCallback = self.getCityNameFromMapView
        self.navigationController?.pushViewController(locationSelectionVC, animated: true)
    }
    
    fileprivate func getCityNameFromMapView(cityName: String) {
        print("Fetched city name: \(cityName)")
        self.fetchWeatherInfo(for: cityName)
    }
    
    fileprivate func setupSearchBarListeners() {
        let publisher = NotificationCenter.default.publisher(for: UISearchTextField.textDidChangeNotification, object: searchController.searchBar.searchTextField)
        sink = publisher
            .map {
                ($0.object as! UISearchTextField).text
        }
        .debounce(for: .seconds(1.0), scheduler: RunLoop.main)
        .removeDuplicates()
        .sink { (str) in
            print("Query String:\(str ?? "")")
            guard let cityname = str else { return }
            self.view.endEditing(true)
            self.fetchWeatherInfo(for: cityname)
        }
    }
    
    //MARK: - API Invocation
    
    fileprivate func executeWeatherForecast(cityName: String, completion: @escaping (Result<WeatherForecastModel, APIError>) -> ()) {
        NetworkService.sharedInstance.fetchData(cityName: cityName, completionHandler: completion)
    }
    
    fileprivate func fetchWeatherInfo(for city: String) {
        OverlayView.sharedInstance.showOverlay(self.view)
        self.executeWeatherForecast(cityName: city) { [weak self] result in
            guard let strongSelf = self else { return }
            switch result {
            case .success(let weather):
                OverlayView.sharedInstance.hideOverlay()
                strongSelf.weeklyForecastModel = weather.daily
                if let unWrappedDailyForecast = strongSelf.weeklyForecastModel {
                    strongSelf.weatherForecasrTableView.reloadOnMainThread( unWrappedDailyForecast)
                }
                strongSelf.title = city
                strongSelf.searchedLocation = city
                strongSelf.successfulResponse = true
            case .failure(let error):
                OverlayView.sharedInstance.hideOverlay()
                strongSelf.successfulResponse = false
                strongSelf.weeklyForecastModel = nil
                strongSelf.weatherForecasrTableView.reloadOnMainThread(strongSelf.weeklyForecastModel ?? [Daily]())
                strongSelf.title = city
                print("error : \(error)")
                AlertController.showError(message: error.localizedDescription)
            }
        }
    }
    
    //MARK:  - Selectors
    
    @objc fileprivate func handleBackAction() {
        self.navigationController?.popViewController(animated: true)
        self.validLocationCompletionCallBack?()
    }
    
    @objc fileprivate func handleMapAction() {
        self.routeToLocationVC()
    }
    
    @objc fileprivate func handleBookmarkAction() {
        guard self.successfulResponse else {
            AlertController.showError(message: "Enter a valid location")
            return
        }
        self.bookmarkedLocationsArray.append(self.searchedLocation)
        UserDefaults.standard.setBookmarkedLocations( self.bookmarkedLocationsArray.removingDuplicates())
        AlertController.showSuccess(message: "Successfully bookmarked your location")
    }
    
}

//MARK: - UISearchBar Delegate

extension WeatherInfoViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.searchController.searchBar.endEditing(true)
        self.searchController.isActive = false
    }
    
}
