//
//  AsyncImageDownloader.swift
//  Way2SmsSystemTask
//
//  Created by Pradeep's Macbook on 19/02/21.
//  Copyright © 2021 Motiv Ate Fitness. All rights reserved.
//

import UIKit
import Combine

enum ImageError: Error {
    case error(_ errorString: String)
}

class AsyncImageDownloader: ObservableObject {
    
    static func downloadImage(with url: URL, completion:@escaping (Result<UIImage?, ImageError>) -> ()) {
        URLSession.shared.dataTask(with: url) { (data
            , response, error) in
            
            if let error = error {
                print("error: \(error.localizedDescription)")
                completion(.failure(.error(error.localizedDescription)))
                return
            }
            
            guard let unWrappedData = data else {
                completion(.failure(.error("Corrupt data")))
                return
            }
            
            DispatchQueue.main.async {
                completion(.success(UIImage(data: unWrappedData)))
            }
            
        }.resume()
    }
    
}

