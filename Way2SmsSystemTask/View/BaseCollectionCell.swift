//
//  BaseCollectionCell.swift
//  SystemTasker
//
//  Created by Pradeep's Macbook on 18/02/20.
//  Copyright © 2020 Pradeep Kumar. All rights reserved.
//

import UIKit

class BaseCollectionCell: UICollectionViewCell {
    
    //MARK: - Properties
    
    
    //MARK: - Life Cycle Methods
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.configureViewComponents()
    }
    
    //MARK: - Helper Functions
    
    func configureViewComponents() {
        self.backgroundColor = .yellow
    }
    
    //MARK: - Selectors
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
