//
//  RootViewController.swift
//  SystemTasker
//
//  Created by Pradeep's Macbook on 18/02/20.
//  Copyright © 2020 Pradeep Kumar. All rights reserved.
//

import UIKit
import Combine

class HomeViewController: UIViewController {
    
    //MARK: - Properties
    
    private lazy var searchController = UISearchController(searchResultsController: nil)
    private var sink: AnyCancellable?
    private var bookmarkedModel = [BookMarkModel]()
    
    //MARK: - Views
    
    private lazy var bookmarkedLocationsTV: GenericTableView<BookMarkModel,BookMarkTableViewCell> = {
        let tv = GenericTableView<BookMarkModel,BookMarkTableViewCell>.init(data:  self.bookmarkedModel, canEditRow: true, config: { (cell, model) in
            cell.bookMarkModel = model
        }, selectionHandler: { (model) in
            self.routeToWeatherInfoVC(selectedCityName: model.name)
        }) { (tableview,indexPath, completion) in
            self.bookmarkedModel.remove(at: indexPath.row)
            let strLocations = self.bookmarkedModel.map { $0.name }
            UserDefaults.standard.setBookmarkedLocations(strLocations)
            self.prefetchLocationsData()
            completion(true)
        }
        return tv
    }()
    
    private lazy var emptyStateView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.addSubviewsToParent(searchLocationsButton)
        searchLocationsButton.centerXInSuperview()
        searchLocationsButton.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 32).isActive = true
        return view
    }()
    
    private lazy var hinTitleLabel: UILabel = {
        let v = UILabel()
        v.font = UIFont.systemFont(ofSize: 17)
        v.textColor = .black
        v.textAlignment = .center
        return v
    }()
    
    private lazy var searchLocationsButton: UIButton = {
        let v  = UIButton(type: .system)
        v.setTitle("Start Bookmarking Locations", for: .normal)
        v.titleLabel?.font = .systemFont(ofSize: 17, weight: .bold)
        v.backgroundColor = .systemRed
        v.layer.cornerRadius = 24
        v.layer.masksToBounds = true
        v.setTitleColor(.white, for: .normal)
        v.addTarget(self, action: #selector(handleStartBookmarking), for: .touchUpInside)
        v.constrainHeight(constant: 48)
        v.constrainWidth(constant: UIScreen.main.bounds.width - 80)
        return v
    }()
    
    //MARK: - LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureViewComponents()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        self.prefetchLocationsData()
    }
    
    //MARK: - ConfigureViewComponents
    
    fileprivate func configureViewComponents() {
        self.configureSearchController()
        self.setupSearchBarListeners()
        self.configureNavBar()
        self.view.backgroundColor = .white
        self.setupConstraints()
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
            if let persistedLocations = UserDefaults.standard.getBookmarkedLocations() {
                let filteredLocations = persistedLocations.filter { $0.contains(cityname) || self.searchController.searchBar.text?.isEmpty ?? true}
                self.bookmarkedLocationsTV.reloadOnMainThread(filteredLocations.map { BookMarkModel.init(name: $0) })
            }
        }
    }
    
    fileprivate func configureSearchController() {
        self.navigationItem.searchController = searchController
        self.navigationController?.navigationBar.barTintColor = .white
        self.navigationController?.navigationItem.searchController?.searchBar.searchTextField.placeholder = "Search your location"
        searchController.definesPresentationContext = true
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.delegate = self
    }
    
    fileprivate func configureNavBar() {
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.title = "Locations"
        self.navigationController?.navigationBar.barStyle = .default
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "ic_settings"), style: .plain, target: self, action: #selector(handleSettingsAction))
    }
    
    fileprivate func setupConstraints() {
        self.view.addSubviewsToParent(bookmarkedLocationsTV,
                                      emptyStateView)
        bookmarkedLocationsTV.fillSuperview()
        emptyStateView.fillSuperview()
    }
    
    fileprivate func routeToWeatherInfoVC(selectedCityName: String) {
        searchController.searchBar.endEditing(true)
        searchController.searchBar.text = ""
        let weatherInfoVC = WeatherInfoViewController()
        weatherInfoVC.bookmarkedCityName = selectedCityName
        weatherInfoVC.validLocationCompletionCallBack = self.getBookmarkedLocations
        self.navigationController?.pushViewController(weatherInfoVC, animated: true)
        searchController.isActive = false
    }
    
    fileprivate func routeToSettingsVC() {
        let locationSelectionVC = SettingsViewController()
        self.navigationController?.pushViewController(locationSelectionVC, animated: true)
    }
    
    fileprivate func getBookmarkedLocations() {
        self.prefetchLocationsData()
    }
    
    fileprivate func prefetchLocationsData() {
        if let persistedLocations = UserDefaults.standard.getBookmarkedLocations(), persistedLocations.count > 0 {
            self.emptyStateView.isHidden = true
            self.bookmarkedModel = persistedLocations.map { BookMarkModel.init(name: $0) }
            self.bookmarkedLocationsTV.reloadOnMainThread(self.bookmarkedModel)
        } else {
            self.emptyStateView.isHidden = false
        }
    }
    
    //MARK:  - Selectors
    
    @objc fileprivate func handleSettingsAction() {
        self.routeToSettingsVC()
    }
    
    @objc fileprivate func handleStartBookmarking() {
        self.emptyStateView.isHidden = true
        self.routeToWeatherInfoVC(selectedCityName: "No Location")
    }

}


//MARK: - UISearchBar Delegate

extension HomeViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.searchController.searchBar.endEditing(true)
        self.searchController.isActive = false
    }
    
}
