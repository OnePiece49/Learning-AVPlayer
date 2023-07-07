//
//  PhotoItemCell.swift
//  LAS_SAMPLE_100
//
//  Created by Minh Tuan on 12/06/2023.
//

import UIKit
import Photos

protocol PhotoItemCellDelegate: NSObject {
    func addOrRemove(_ photo: PHAsset)
    func isExists(_ photo: PHAsset) -> Bool
}

class PhotoItemCell: UICollectionViewCell {
    
    weak var delegate: PhotoItemCellDelegate?
    
    private lazy var checklistImageView: UIImageView = {
        let iv = UIImageView(image: UIImage(named: "ic_checklist"))
        iv.setDimensions(width: 20, height: 20)
        return iv
    }()
    
    var photo: PHAsset! {
        didSet {
            photoImage.image = photo.getImageThumb
            durationLabel.text = videoDuration(videoAsset: photo)
        }
    }
    
    var isEdit: Bool = false {
        didSet {
            //            checkButton.isHidden = !isEdit
            //            deleteButton.isHidden = isEdit
        }
    }
    
    var onDelete:((_ photo: PHAsset)->Void)?
    
    @IBOutlet weak var photoImage: UIImageView!
    @IBOutlet weak var checkButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var durationLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        addSubview(checklistImageView)
        durationLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            checklistImageView.topAnchor.constraint(equalTo: topAnchor, constant: 5),
            checklistImageView.rightAnchor.constraint(equalTo: rightAnchor, constant: -5),
            
            durationLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -6),
            durationLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: -6),
        ])
        checklistImageView.isHidden = true
    }
    
    @IBAction func deleteClick(_ sender: Any) {
        onDelete?(photo)
    }
    
    func checkClick() {
        delegate?.addOrRemove(photo)
        checklistImageView.isHidden = !(delegate?.isExists(photo) ?? false)
    }
    
    func updateCheckList(photo: PHAsset) {
        if self.photo.localIdentifier == photo.localIdentifier {
            checklistImageView.isHidden = true
        }
    }
    
    func isRemoved() -> Bool {
        return checklistImageView.isHidden == true
    }
    
    func hasAddPhoto() {
        checklistImageView.isHidden = !(delegate?.isExists(photo) ?? false)
    }
    
    func videoDuration(videoAsset: PHAsset?) -> String {
        guard let asset = videoAsset else { return "00:00" }
        let duration: TimeInterval = asset.duration
        let s: Int = Int(duration) % 60
        let m: Int = Int(duration) / 60
        let formattedDuration = String(format: "%02d:%02d", m, s)
        return formattedDuration
    }
}


