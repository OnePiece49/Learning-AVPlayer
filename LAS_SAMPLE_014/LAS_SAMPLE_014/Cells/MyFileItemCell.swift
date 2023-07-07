//
//  MyFileItemCell.swift
//  LAS_SAMPLE_100
//
//  Created by Minh Tuan on 13/06/2023.
//

import UIKit
import Photos

protocol MyFileItemCellDelegate: AnyObject {
    func didTapOnShareButton(_ cell: MyFileItemCell)
}

class MyFileItemCell: UITableViewCell {
    static let heigh: CGFloat = 100
    
    var titleVideo: String = "" {
        didSet {
            updateCell()
        }
    }
    
    weak var delegate: MyFileItemCellDelegate?
    
    //MARK: -outlets
    @IBOutlet weak var posterImage: UIImageView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        posterImage.layer.cornerRadius = 16
        posterImage.layer.masksToBounds = true
        timeLabel.font = UIFont.fontRegular(12)
        timeLabel.textColor = UIColor(rgb: 0xFFFFFF)
        titleLabel.font = UIFont.fontMedium(16)
        titleLabel.textColor = UIColor(rgb: 0x000000)
        dateLabel.font = UIFont.fontRegular(14)
        dateLabel.textColor = UIColor(rgb: 0x5B5B5B)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    @IBAction func shareClick(_ sender: Any) {
        delegate?.didTapOnShareButton(self)
    }
    
    private func updateCell() {
        titleLabel.text = titleVideo
        
        //        posterImage.image = generateThumbnail(path: path)
        guard let path = URL.videoEditorFolder()?.appendingPathComponent(titleVideo) else { return }
        generateThumbnail(path: path, identifier: titleVideo) { [weak self] thumbnail, identifier in
            if identifier == self?.titleVideo {
                self?.posterImage.image = thumbnail
            }
        }
        
        let asset = AVURLAsset(url: path)
        let duration = asset.duration
        guard let creationDate = asset.creationDate?.dateValue else { return }
        timeLabel.text = duration.getTimeString()
        dateLabel.text = creationDate.convertToString(format: "dd/MM/YYYY")
    }
    
    func generateThumbnail(path: URL, identifier: String,
                           completion: @escaping (_ thumbnail: UIImage?, _ identifier: String) -> Void) {
        
        let asset = AVURLAsset(url: path, options: nil)
        let imgGenerator = AVAssetImageGenerator(asset: asset)
        imgGenerator.appliesPreferredTrackTransform = true
        
        imgGenerator.generateCGImagesAsynchronously(forTimes: [NSValue(time: .zero)]) { _, image, _, _, _ in
            if let image = image {
                DispatchQueue.main.async {
                    completion(UIImage(cgImage: image), identifier)
                }
            }
        }
    }
}
