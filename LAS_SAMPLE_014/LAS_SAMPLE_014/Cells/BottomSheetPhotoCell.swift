//
//  BottomSheetPhotoCell.swift
//  LAS_SAMPLE_014
//
//  Created by Long Bảo on 19/06/2023.
//

import UIKit
import Photos

protocol BottomSheetPhotoCellDelegate: AnyObject {
    func didSelectDeleteButton(asset: PHAsset?)
}

class BottomSheetPhotoCell: UICollectionViewCell {
    //MARK: - Properties
    weak var delegate: BottomSheetPhotoCellDelegate?
    
    var photo: PHAsset? {
        didSet {
            selectedImageView.image = photo?.getImageThumb
        }
    }
    
    private lazy var deleteView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 30 / 2
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleDeleteButtonTapped)))
        view.isUserInteractionEnabled = true
        
        return view
    }()
    
    private lazy var deleteButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "ic_delete"), for: .normal)
        button.contentMode = .scaleToFill
        button.tintColor = .black
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .white
        button.layer.cornerRadius = 16 / 2
        button.addTarget(self, action: #selector(handleDeleteButtonTapped), for: .touchUpInside)
        return button
    }()
    
    lazy var selectedImageView: UIImageView = {
        let iv = UIImageView()
        iv.clipsToBounds = true
        iv.contentMode = .scaleAspectFill
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.layer.cornerRadius = 10
        return iv
    }()
    
    static let identifier = "ProfileCollectionViewCell"
    
    //MARK: - View Lifecycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    //MARK: - Helpers
    func configureUI() {
        addSubview(selectedImageView)
        addSubview(deleteView)
        addSubview(deleteButton)
        NSLayoutConstraint.activate([
            selectedImageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            selectedImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            deleteButton.topAnchor.constraint(equalTo: selectedImageView.topAnchor, constant: -6),
            deleteButton.leftAnchor.constraint(equalTo: selectedImageView.rightAnchor, constant: -8),
            deleteView.topAnchor.constraint(equalTo: selectedImageView.topAnchor, constant: -15),
            deleteView.leftAnchor.constraint(equalTo: selectedImageView.rightAnchor, constant: -15),
        ])
        selectedImageView.setDimensions(width: 46, height: 46)
        deleteButton.setDimensions(width: 16, height: 16)
        deleteView.setDimensions(width: 30, height: 30)
    }
    
    //MARK: - Selectors
    @objc func handleDeleteButtonTapped() {
        self.delegate?.didSelectDeleteButton(asset: photo)
    }
    
}
//MARK: - delegate

