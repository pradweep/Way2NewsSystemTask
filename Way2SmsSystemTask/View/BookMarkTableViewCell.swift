//
//  BookMarkTableViewCell.swift
//  Way2SmsSystemTask
//
//  Created by Pradeep's Macbook on 18/02/21.
//  Copyright © 2021 Motiv Ate Fitness. All rights reserved.
//

import UIKit

class BookMarkTableViewCell: BaseTableViewCell {
    
    //MARK: - Property Observers
    
    var bookMarkModel: BookMarkModel! {
        didSet {
            self.updateUI(bookMarkModel)
        }
    }
    
    //MARK: - Views
    
    private lazy var historyIcon: UIImageView = {
        let v = UIImageView()
        v.contentMode = .scaleAspectFill
        v.image = #imageLiteral(resourceName: "ic_history").withRenderingMode(.alwaysTemplate)
        v.tintColor = .lightGray
        v.constrainWidth(constant: 24)
        v.constrainHeight(constant: 24)
        return v
    }()
    
    private lazy var bookmarkTitleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .semibold)
        label.textColor = UIColor.black.withAlphaComponent(0.7)
        return label
    }()
    
    private lazy var mapIcon: UIImageView = {
        let v = UIImageView()
        v.contentMode = .scaleAspectFill
        v.image = #imageLiteral(resourceName: "ic_arrow").withRenderingMode(.alwaysTemplate)
        v.tintColor = .lightGray
        v.constrainWidth(constant: 24)
        v.constrainHeight(constant: 24)
        return v
    }()
    
    private lazy var containerStackView: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [
            historyIcon,
            bookmarkTitleLabel,
            mapIcon
        ])
        sv.axis = .horizontal
        sv.spacing = 16
        sv.isLayoutMarginsRelativeArrangement = true
        sv.layoutMargins = .init(top: 16, left: 12, bottom: 16, right: 12)
        sv.distribution = .fill
        sv.alignment = .center
        return sv
    }()
    
    //MARK: - Overrides
    
    override func configureViewComponents() {
        self.addSubviewsToParent(containerStackView)
        containerStackView.fillSuperview()
    }
    
    //MARK: - Set Data
    
    private func updateUI(_ item: BookMarkModel) {
        self.bookmarkTitleLabel.text = item.name
    }
}
