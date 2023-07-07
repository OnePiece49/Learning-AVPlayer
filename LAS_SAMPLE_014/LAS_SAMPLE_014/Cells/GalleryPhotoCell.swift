//
//  GaleryPhotoCell.swift
//  LAS_SAMPLE_100
//
//  Created by Minh Tuan on 12/06/2023.
//

import UIKit
import Photos

class GalleryPhotoCell: UITableViewCell {
    //MARK: - properties
    static let height: CGFloat = 300
    var source: [PHAsset] = [] {
        didSet {
            photoCLView.reloadData()
        }
    }
    
    var onAddPhoto:(()-> Void)?
    var onDeletePhoto:((_ photo: PHAsset)->Void)?
    
    //MARK: - outlets
    @IBOutlet weak var photoCLView: UICollectionView!
    @IBOutlet weak var addButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        photoCLView.register(UINib(nibName: PhotoItemCell.cellId, bundle: nil), forCellWithReuseIdentifier: PhotoItemCell.cellId)
        photoCLView.dataSource = self
        photoCLView.delegate = self
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    @IBAction func addClick(_ sender: Any) {
        onAddPhoto?()
    }
}

extension GalleryPhotoCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return source.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotoItemCell.cellId, for: indexPath) as! PhotoItemCell
        cell.photo = source[indexPath.row]
        cell.isEdit = false
        cell.onDelete = { photo in
            self.onDeletePhoto?(photo)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return .init(top: padding, left: padding, bottom: padding, right: 0)
        
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return padding/2
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return padding/2
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = 150
        let height = 150
        return CGSize(width: width, height: height)
        
    }
    
}
