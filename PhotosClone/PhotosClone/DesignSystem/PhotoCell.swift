//
//  PhotoCell.swift
//  PhotosClone
//
//  Created by minsong kim on 8/8/24.
//

import UIKit

class PhotoCell: UICollectionViewCell, Identifiable {
    static let identifier = "PhotoCell"
    var representedAssetIdentifier: String = ""
    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 24)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        return imageView
    }()
    
    func configureImage(image: UIImage?, contentMode: ContentMode = .scaleAspectFill) {
        imageView.image = image
        imageView.contentMode = contentMode
        configureImageUI()
    }
    
    func configureTitle(_ text: String) {
        titleLabel.text = text
        let attributedString = NSMutableAttributedString(string: text)

        //텍스트에 테두리 추가
        attributedString.addAttribute(.strokeColor, value: UIColor.gray, range: NSRange(location: 0, length: text.count))
        attributedString.addAttribute(.strokeWidth, value: -4.0, range: NSRange(location: 0, length: text.count))
        titleLabel.attributedText = attributedString
        
        configureTitleLabel()
    }
    
    func configureCellShadowAndCornerRadius() {
        contentView.layer.cornerRadius = 10
        contentView.layer.masksToBounds = true
        
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.2
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowRadius = 4
        layer.masksToBounds = false
    }
    
    private func configureImageUI() {
        contentView.addSubview(imageView)
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.bottomAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.trailingAnchor)
        ])
    }
    
    private func configureTitleLabel() {
        self.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.topAnchor, constant: 8),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.leadingAnchor, constant: 8),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.trailingAnchor)
        ])
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
    }
}
