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
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(titleLabel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureLabel(text: String?, fontSize: CGFloat = 28.0) {
        titleLabel.text = text
        titleLabel.font = UIFont.boldSystemFont(ofSize: fontSize)
    }
    
    func changeTitleColor(_ color: UIColor) {
        titleLabel.textColor = color
    }

    func configureLabelUI(leading: CGFloat = 0, trailing: CGFloat = 0) {
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: leading),
            titleLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: trailing),
            titleLabel.topAnchor.constraint(equalTo: self.topAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
    }
}
