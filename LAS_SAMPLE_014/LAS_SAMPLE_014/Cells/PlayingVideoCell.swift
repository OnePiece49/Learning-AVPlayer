//
//  PlayingVideoCell.swift
//  LAS_SAMPLE_014
//
//  Created by Đức Anh Trần on 23/06/2023.
//

import UIKit
import AVFoundation

class PlayingVideoCell: UITableViewCell {
    
    var titleVideo: String = "" {
        didSet {
            updateCell()
        }
    }
    
    @IBOutlet weak var posterImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        posterImageView.layer.cornerRadius = 16
        posterImageView.layer.masksToBounds = true
        titleLabel.font = UIFont.fontMedium(16)
        titleLabel.textColor = UIColor(rgb: 0x000000)
    }
    
    private func updateCell() {
        titleLabel.text = titleVideo
        guard let path = URL.videoEditorFolder()?.appendingPathComponent(titleVideo) else { return }
        generateThumbnail(path: path, identifier: titleVideo) { [weak self] thumbnail, identifier in
            if identifier == self?.titleVideo {
                self?.posterImageView.image = thumbnail
            }
        }
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
