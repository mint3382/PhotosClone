//
//  HeaderView.swift
//  PhotosClone
//
//  Created by minsong kim on 8/9/24.
//

import UIKit

class HeaderView: UICollectionReusableView {
    static let identifier = "HeaderView"
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 28)
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(titleLabel)
        configureLabelUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureLabel(text: String?, fontSize: CGFloat = 28.0, color: UIColor = .black) {
        titleLabel.text = text
        titleLabel.font = UIFont.boldSystemFont(ofSize: fontSize)
        titleLabel.textColor = color
    }

    func configureLabelUI() {
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            titleLabel.topAnchor.constraint(equalTo: self.topAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
    }
}
