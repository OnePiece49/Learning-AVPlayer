//
//  BottomSheetPhotoView.swift
//  LAS_SAMPLE_014
//
//  Created by Long Bảo on 19/06/2023.
//

import UIKit
import Photos

protocol BottomSheetPhotoDelegate: AnyObject {
    func didSelectDeleteButton(photo: PHAsset)
    func didSelectMergeButton()
}


class BottomSheetPhotoView: UIView {
    //MARK: - Properties
    weak var delegate: BottomSheetPhotoDelegate?
    
    var selectedPhotos: [PHAsset] = [] 
    
    var numberSelectedPhotoString: String {
        if selectedPhotos.count <= 1 {
            return "Selected \(selectedPhotos.count) Video"
        }
        
        return "Selected \(selectedPhotos.count) Videos"
    }

    private lazy var blurEffectView: UIVisualEffectView = {
        let blurEffect = UIBlurEffect(style: .regular)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.translatesAutoresizingMaskIntoConstraints = false
        blurView.layer.maskedCorners = [CACornerMask.layerMinXMinYCorner,
                                        CACornerMask.layerMaxXMinYCorner]
        blurView.layer.cornerRadius = 18
        blurView.layer.masksToBounds = true
        return blurView
    }()
    
    private lazy var mergeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Merge", for: .normal)
        button.setTitleColor(UIColor(rgb: 0xFFFFFF), for: .normal)
        button.titleLabel?.font = UIFont(name: "ClashDisplay-Semibold", size: 16)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 10
        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(handleMergeButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var numberSelectedLabel: UILabel = {
        let label = UILabel()
        label.text = "Selected 0 video"
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.fontMedium(14)
        label.textColor = .white
        return label
    }()
    
    var selectedCLView: UICollectionView!
    
    func applyGradient() {
        mergeButton.applyGradient(colors: [UIColor(rgb: 0x5900FF), UIColor(rgb: 0x67CDFF)],
                                  locations: [0.5, 1.0],
                                  startPoint: CGPoint(x: 0.3, y: 0),
                                  endPoint: CGPoint(x: 1, y: 1))
    }
    
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
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        selectedCLView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        selectedCLView.showsHorizontalScrollIndicator = false
        addSubview(blurEffectView)
        addSubview(selectedCLView)
        addSubview(numberSelectedLabel)
        addSubview(mergeButton)
        layer.cornerRadius = 18
        
        selectedCLView.translatesAutoresizingMaskIntoConstraints = false
        selectedCLView.delegate = self
        selectedCLView.dataSource = self
        selectedCLView.backgroundColor = .clear
        selectedCLView.register(BottomSheetPhotoCell.self, forCellWithReuseIdentifier: BottomSheetPhotoCell.cellId)
        
        NSLayoutConstraint.activate([
            blurEffectView.topAnchor.constraint(equalTo: topAnchor),
            blurEffectView.leftAnchor.constraint(equalTo: leftAnchor),
            blurEffectView.rightAnchor.constraint(equalTo: rightAnchor),
            blurEffectView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            numberSelectedLabel.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            numberSelectedLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: 20),
            
            selectedCLView.leftAnchor.constraint(equalTo: leftAnchor, constant: 16),
            selectedCLView.centerYAnchor.constraint(equalTo: centerYAnchor),
            selectedCLView.heightAnchor.constraint(equalToConstant: 80),
            selectedCLView.rightAnchor.constraint(equalTo: mergeButton.leftAnchor, constant: -10),
            
            mergeButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            mergeButton.rightAnchor.constraint(equalTo: rightAnchor, constant: -15),
        ])
        mergeButton.setDimensions(width: 86, height: 36)
    }
    
    func reloadData() {
        self.numberSelectedLabel.text = numberSelectedPhotoString
        self.selectedCLView.reloadData()
    }
    
    func insertData() {
        let lastIndex = selectedCLView.numberOfItems(inSection: 0)
        let indexPath = IndexPath(row: lastIndex, section: 0)
        selectedCLView.insertItems(at: [indexPath])
        self.numberSelectedLabel.text = numberSelectedPhotoString
    }
    
    private func removeData(index: Int) {
        let indexPath = IndexPath(row: index, section: 0)
        selectedPhotos.remove(at: index)
        selectedCLView.deleteItems(at: [indexPath])
        self.numberSelectedLabel.text = numberSelectedPhotoString
    }
    
    //MARK: - Selectors
    @objc func handleMergeButtonTapped() {
        self.delegate?.didSelectMergeButton()
    }
    
}
//MARK: - delegate

extension BottomSheetPhotoView: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return selectedPhotos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = selectedCLView.dequeueReusableCell(withReuseIdentifier: BottomSheetPhotoCell.cellId, for: indexPath) as! BottomSheetPhotoCell
        cell.photo = selectedPhotos[indexPath.row]
        cell.delegate = self
        return cell
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 64, height: 68)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
}

extension BottomSheetPhotoView: BottomSheetPhotoCellDelegate {
    func didSelectDeleteButton(asset: PHAsset?) {
        guard let asset = asset else {
            return
        }
        
        let index = selectedPhotos.firstIndex { $0.localIdentifier == asset.localIdentifier }
        guard let index = index else {return}
        removeData(index: index)
        self.delegate?.didSelectDeleteButton(photo: asset)
    }
}
