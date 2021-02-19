//
//  LocationSelectionVC.swift
//  Way2SmsSystemTask
//
//  Created by Pradeep's Macbook on 18/02/21.
//  Copyright © 2021 Motiv Ate Fitness. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class LocationSelectionVC: UIViewController {
    
    //MARK: - Properties
    
    let coreLocationManager = CLLocationManager()
    let regionInMeters: Double = 10000
    var previousLocation: CLLocation?
    var selectedCity: String?
    var completionCallback: ((String) -> ())?
    
    //MARK: - Views
    
    private lazy var mapView: MKMapView = {
        let v = MKMapView(frame: .zero)
        v.delegate = self
        return v
    }()
    
    private lazy var panGesture: UIPanGestureRecognizer = {
        let gesture = UIPanGestureRecognizer()
        return gesture
    }()
    
    private lazy var pinImageView: UIImageView = {
        let v = UIImageView()
        v.image = UIImage(named: "Pin")
        v.contentMode = .scaleAspectFit
        v.constrainWidth(constant: 40)
        v.constrainHeight(constant: 40)
        return v
    }()
    
    private lazy var userLocationBtn: UIButton = {
        let btn = UIButton(type: .system)
        btn.backgroundColor = .white
        btn.setImage(#imageLiteral(resourceName: "ic_user_location").withRenderingMode(.alwaysOriginal), for: .normal)
        btn.constrainWidth(constant: 40)
        btn.constrainHeight(constant: 40)
        btn.layer.cornerRadius = 20
        btn.layer.shadowColor = UIColor.darkGray.cgColor
        btn.layer.shadowOffset = .init(width: 2, height: 2)
        btn.layer.shadowRadius = 10.0
        btn.layer.shadowOpacity = 0.5
        btn.layer.masksToBounds = false
        btn.addTarget(self, action: #selector(handleResetUserLocation), for: .touchUpInside)
        return btn
    }()
    
    //MARK: - LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(self.didDragMap(_:)))
        panGesture.delegate = self
        mapView.addGestureRecognizer(panGesture)
        self.configureViewComponents()
    }
    
    //MARK: - ConfigureViewComponents
    
    fileprivate func configureViewComponents(){
        self.configureNavBar()
        self.view.backgroundColor = .white
        self.setupConstraints()
        self.checkLocationServices()
    }
    
    fileprivate func setupConstraints() {
        self.view.addSubviewsToParent(mapView,
                                      pinImageView)
        mapView.fillSuperview()
        pinImageView.centerXInSuperview()
        pinImageView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor, constant: -20).isActive = true
        /*userLocationBtn.anchor(top: nil, leading: nil, bottom: self.view.safeAreaLayoutGuide.bottomAnchor, trailing: self.view.trailingAnchor, padding: .init(top: 0, left: 0, bottom: 48, right: 16), size: .init())*/
    }
    
    fileprivate func configureNavBar() {
        self.navigationController?.navigationBar.barStyle = .default
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "ic_back"), style: .plain, target: self, action: #selector(handleBackAction))
    }
    
    //MARK: - CoreLocation Fileprivate Helpers
    
    fileprivate func checkLocationServices() {
        if CLLocationManager.locationServicesEnabled() {
            self.setupLocationManager()
            self.checkLocationAuthorization()
        } else {
            print("DEBUG: *** Show Alert ***")
        }
    }
    
    fileprivate func checkLocationAuthorization() {
        
        switch CLLocationManager.authorizationStatus() {
            
        case .notDetermined:
            coreLocationManager.requestWhenInUseAuthorization()
        case .restricted:
            break
        case .denied:
            break
        case .authorizedAlways:
            break
        case .authorizedWhenInUse:
            self.startTrackingUserLocation()
        @unknown default:
            break
        }
    }
    
    fileprivate func startTrackingUserLocation() {
        self.centerViewOnUserLocation()
        self.coreLocationManager.startUpdatingLocation()
        self.previousLocation = self.getCenterLocation(mapView)
    }
    
    fileprivate func setupLocationManager() {
        /*self.mapView.showsUserLocation = true*/
        self.coreLocationManager.delegate = self
        self.coreLocationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    fileprivate func centerViewOnUserLocation() {
        guard let coordinate = self.coreLocationManager.location?.coordinate else { return }
        let region = MKCoordinateRegion.init(center: coordinate, latitudinalMeters: regionInMeters, longitudinalMeters: regionInMeters)
        self.mapView.setRegion(region, animated: true)
    }
    
    fileprivate func getCenterLocation(_ mapView: MKMapView) -> CLLocation {
        let latitude  = mapView.centerCoordinate.latitude
        let longitude = mapView.centerCoordinate.longitude
        return CLLocation(latitude: latitude, longitude: longitude)
    }
    
    //MARK:  - Selectors
    
    @objc fileprivate func handleBackAction() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc fileprivate func handleResetUserLocation() {
      
    }
}

extension LocationSelectionVC: UIGestureRecognizerDelegate {

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }

    @objc func didDragMap(_ sender: UIGestureRecognizer) {
        if sender.state == .ended {
            self.completionCallback?(self.selectedCity ?? "")
        }
    }
}

//MARK: - CLLocationManager Delegate

extension LocationSelectionVC: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        self.checkLocationAuthorization()
    }
    
}


//MARK: - MapView Delegate

extension LocationSelectionVC: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        let center = self.getCenterLocation(mapView)
        
        guard let prevLocation = previousLocation else { return }
        
        guard center.distance(from: prevLocation) > 50 else { return }
        
        previousLocation = center
        
        let geoCoder = CLGeocoder()
        geoCoder.reverseGeocodeLocation(center) { (placemarks, error) in
            
            if let _ = error {
               //handle error
                return
            }
            
            guard let placemark = placemarks?.first else { return }

            if let locality = placemark.locality {
                self.selectedCity = locality
            }

        }
    }
    
    
}
