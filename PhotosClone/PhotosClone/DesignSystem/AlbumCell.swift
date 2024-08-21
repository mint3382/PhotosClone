//
//  AlbumCell.swift
//  PhotosClone
//
//  Created by minsong kim on 8/10/24.
//

import UIKit

class AlbumCell: UICollectionViewCell, Identifiable {
    static let identifier = "AlbumCell"
    
    let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        return imageView
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .subheadline)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    let countLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .subheadline)
        label.textColor = .gray
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    func configureImage(image: UIImage?) {
        imageView.image = image
        configureImageUI()
    }
    
    func configureTitle(_ text: String?) {
        titleLabel.text = text
        configureTitleLabel()
    }
    
    func configureCount(_ text: String?) {
        countLabel.text = text
        configureCountLabel()
    }
    
    private func configureImageUI() {
        contentView.addSubview(imageView)
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.topAnchor),
            imageView.widthAnchor.constraint(equalTo: contentView.widthAnchor),
            imageView.heightAnchor.constraint(equalTo: contentView.widthAnchor),
            imageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor)
        ])
    }
    
    private func configureTitleLabel() {
        contentView.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 4),
            titleLabel.leadingAnchor.constraint(equalTo: imageView.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: imageView.trailingAnchor)
        ])
    }
    
    private func configureCountLabel() {
        contentView.addSubview(countLabel)
        
        NSLayoutConstraint.activate([
            countLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            countLabel.leadingAnchor.constraint(equalTo: imageView.leadingAnchor),
            countLabel.trailingAnchor.constraint(equalTo: imageView.trailingAnchor)
        ])
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
    }
}
