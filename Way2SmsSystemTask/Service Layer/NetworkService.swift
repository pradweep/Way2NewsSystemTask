//
//  NetworkService.swift
//  SystemTasker
//
//  Created by Pradeep's Macbook on 18/02/20.
//  Copyright © 2020 Pradeep Kumar. All rights reserved.
//

import UIKit
import CoreLocation

enum APIError: Error {
    case error(_ errorString: String)
}

struct NetworkService {
    
    static let sharedInstance = NetworkService()
    
    func fetchData<T: Decodable>(cityName: String, dateDecodingStrategy: JSONDecoder.DateDecodingStrategy = .deferredToDate, keyDecodingStrategy: JSONDecoder.KeyDecodingStrategy = .useDefaultKeys,completionHandler: ((Result<T, APIError>) -> Swift.Void)?) {
        
        CLGeocoder().geocodeAddressString(cityName) { (placemarks, error) in
            
            if let error = error {
                print("Geocode address error: \(error.localizedDescription)")
                completionHandler?(.failure(.error(error.localizedDescription)))
                return
            }
            
            guard let placemark = placemarks?.first, let latitude = placemark.location?.coordinate.latitude, let longitude = placemark.location?.coordinate.longitude else { return }
            
            guard let url = URL(string: "https://api.openweathermap.org/data/2.5/onecall?lat=\(latitude)&lon=\(longitude)&exclude=current,minutely,hourly,alerts&appid=fae7190d7e6433ec3a45285ffcf55c86") else {
                completionHandler?(.failure(.error(NSLocalizedString("Invalid URL", comment: ""))))
                return
            }
            
            URLSession.shared.dataTask(with: url) { (data, response, error) in
                DispatchQueue.main.async {
                    if let  error = error {
                        completionHandler?(.failure(.error("Error: \(error.localizedDescription)")))
                        return
                    }
                    
                    guard let unWrappedData = data else {
                        completionHandler?(.failure(.error(NSLocalizedString("Data Corrupt", comment: ""))))
                        return
                    }
                    
                    let decoder = JSONDecoder()
                    decoder.dateDecodingStrategy = dateDecodingStrategy
                    decoder.keyDecodingStrategy = keyDecodingStrategy
                    do {
                        let decodedObject = try decoder.decode(T.self, from: unWrappedData)
                        completionHandler?(.success(decodedObject))
                    } catch let decodingError {
                        completionHandler?(.failure(.error("Error: \(decodingError.localizedDescription)")))
                    }
                }
            }.resume()
        }
    }
}
/** Basic Network Service Layer */
