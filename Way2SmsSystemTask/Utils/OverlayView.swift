//
//  OverlayView.swift
//  Way2SmsSystemTask
//
//  Created by Pradeep's Macbook on 19/02/21.
//  Copyright © 2021 Motiv Ate Fitness. All rights reserved.
//

import UIKit

public class OverlayView {
    
    var overlayView: UIView!
    var activityIndicatorView: UIActivityIndicatorView!
    
    class var sharedInstance: OverlayView {
        struct Static {
            static let shared = OverlayView()
        }
        return Static.shared
    }
    
    private init() {
        overlayView = UIView()
        overlayView.backgroundColor = .black
        overlayView.clipsToBounds = true
        overlayView.layer.cornerRadius = 10
        overlayView.frame = .init(x: 0, y: 0, width: 80, height: 80)
        
        activityIndicatorView = UIActivityIndicatorView(style: .large)
        activityIndicatorView.frame  = .init(x: 0, y: 0, width: 40, height: 40)
        activityIndicatorView.color = .white
        activityIndicatorView.center = .init(x: overlayView.bounds.width / 2, y: overlayView.bounds.height / 2)
        overlayView.addSubview(activityIndicatorView)
    }
    
    public func showOverlay(_ view: UIView) {
        overlayView.center = view.center
        view.addSubview(overlayView)
        activityIndicatorView.startAnimating()
    }
    
    public func hideOverlay() {
        activityIndicatorView.stopAnimating()
        overlayView.removeFromSuperview()
    }
    
}
