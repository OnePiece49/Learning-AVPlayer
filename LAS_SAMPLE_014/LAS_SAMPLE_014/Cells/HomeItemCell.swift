//
//  HomeItemCell.swift
//  LAS_SAMPLE_100
//
//  Created by Minh Tuan on 12/06/2023.
//

import UIKit

class HomeItemCell: UICollectionViewCell {
    //MARK: - outlets
    @IBOutlet weak var homeImage: UIImageView!
    @IBOutlet weak var homeLabel: UILabel!
    @IBOutlet weak var ovalBackgroundView: UIView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        addGradient()
        setupOvalView()
    }
    
    var homeDetail: GenerateType = .cutterVideo {
        didSet {
            homeLabel.text = homeDetail.title()
            homeImage.image = UIImage(named: homeDetail.imageName())
        }
    }
    
    private func setupUI() {
        homeLabel.font = UIFont.fontMedium(14)
        homeLabel.textColor = UIColor(rgb: 0x4B42ED)
        self.layer.cornerRadius = 20
    }
    
    private func addGradient() {
        let colors: [UIColor] = [UIColor(rgb: 0xC2CDFF),
                                 UIColor(rgb: 0xF8FEFF)]
        let startPoint = CGPoint(x: 0.0, y: 0.0)
        let endPoint = CGPoint(x: 1.0, y: 1.0)
        contentView.applyGradient(colors: colors, startPoint: startPoint, endPoint: endPoint)
    }
    
    private func setupOvalView() {
        ovalBackgroundView.layer.cornerRadius = ovalBackgroundView.bounds.height/2
        ovalBackgroundView.clipsToBounds = true
        ovalBackgroundView.alpha = 0.1
        ovalViewAddGradient()
    }
    
    private func ovalViewAddGradient() {
        let colors: [UIColor] = [UIColor(rgb: 0x5D5BFA),
                                 UIColor(rgb: 0x45ABFF)]
        let startPoint = CGPoint(x: 0.0, y: 0.0)
        let endPoint = CGPoint(x: 0.0, y: 1.0)
        ovalBackgroundView.applyGradient(colors: colors, startPoint: startPoint, endPoint: endPoint)
    }
    
}
