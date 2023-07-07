//
//  MergeVideoItemCell.swift
//  LAS_SAMPLE_014
//
//  Created by Minh Tuan on 15/06/2023.
//

import UIKit
import AVFoundation
import Photos

protocol MergeVideoItemCellDelegate: AnyObject {
    func didSelecChooseVideoButton()
}

class MergeVideoItemCell: UITableViewCell {
    weak var delegate: MergeVideoItemCellDelegate?
    
    private lazy var thumbImageView: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.isHidden = true
        iv.backgroundColor = .red
        iv.layer.cornerRadius = 20
        iv.layer.masksToBounds = true
        return iv
    }()
    
    private lazy var editButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "ic_editVideo"), for: .normal)
        button.contentMode = .scaleToFill
        button.contentVerticalAlignment = .fill
        button.contentHorizontalAlignment = .fill
        button.setDimensions(width: 14, height: 14)
        button.tintColor = .white
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(handlePickVideoTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var editLabelButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Edit", for: .normal)
        button.setTitleColor(UIColor.white, for: .normal)
        button.titleLabel?.font = UIFont.fontMedium(14)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(handlePickVideoTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var containerEditView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(editButton)
        view.addSubview(editLabelButton)
        view.backgroundColor = .black
        view.layer.opacity = 0.3552725613117218
        
        NSLayoutConstraint.activate([
            editButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 12),
            editButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            editLabelButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -6),
            editLabelButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
        
        view.setDimensions(width: 66, height: 26)
        view.layer.cornerRadius = 8
        view.isHidden = true
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handlePickVideoTapped)))
        return view
    }()
    
    private lazy var videoImagevIew: UIImageView = {
        let iv = UIImageView(image: UIImage(named: "ic_pickVideo"))
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private lazy var pickVideoButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Choose Video", for: .normal)
        button.setTitleColor(UIColor(rgb: 0x4B42ED), for: .normal)
        button.titleLabel?.font = UIFont.fontMedium(14)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 10
        button.layer.borderColor = UIColor(rgb: 0x4B42ED).cgColor
        button.layer.borderWidth = 1
        button.addTarget(self, action: #selector(handlePickVideoTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor(rgb: 0xEAF4FF)
        view.layer.cornerRadius = 20
        view.layer.masksToBounds = true
        
        view.addSubview(videoImagevIew)
        view.addSubview(pickVideoButton)
        NSLayoutConstraint.activate([
            videoImagevIew.widthAnchor.constraint(equalTo: videoImagevIew.heightAnchor, multiplier: 59 / 48),
            videoImagevIew.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            videoImagevIew.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -30),
            videoImagevIew.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 66 / 358),
            
            pickVideoButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            pickVideoButton.topAnchor.constraint(equalTo: videoImagevIew.bottomAnchor, constant: 14),
        ])
        return view
    }()
    
    var videoUrl: URL? {
        didSet {
            guard let url = videoUrl else { return }
            posterImage.image = generateThumbnail(path: url)
        }
    }
    
    @IBOutlet weak var posterImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configureUI()
    }
    
    private func configureUI() {
        contentView.addSubview(containerView)
        contentView.addSubview(thumbImageView)
        contentView.addSubview(containerEditView)
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: topAnchor, constant: 0),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0),
            containerView.leftAnchor.constraint(equalTo: leftAnchor, constant: 18),
            containerView.rightAnchor.constraint(equalTo: rightAnchor, constant: -18),
            
            thumbImageView.topAnchor.constraint(equalTo: containerView.topAnchor),
            thumbImageView.leftAnchor.constraint(equalTo: containerView.leftAnchor),
            thumbImageView.rightAnchor.constraint(equalTo: containerView.rightAnchor),
            thumbImageView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            
            containerEditView.rightAnchor.constraint(equalTo: containerView.rightAnchor, constant: -10),
            containerEditView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 10),
        ])
        
        pickVideoButton.setDimensions(width: 116, height: 36)
    }
    
    override var frame: CGRect {
        didSet {
            applyBorder()
        }
    }
    
    func applyBorder() {
        self.containerView.layer.sublayers?.forEach{ layer in
            if layer.name == "borderLayer" {
                layer.removeFromSuperlayer()
            }
        }
        
        let borderLayer = CAShapeLayer()
        
        borderLayer.cornerRadius = 20
        borderLayer.strokeColor = UIColor(rgb: 0x4B42ED).cgColor
        borderLayer.lineWidth = 2
        borderLayer.backgroundColor = UIColor.clear.cgColor
        borderLayer.fillColor = .none
        borderLayer.lineDashPattern = [4, 2]
        borderLayer.name = "borderLayer"
        
        let path = UIBezierPath()
        path.cgPath = CGPath(roundedRect: self.containerView.bounds, cornerWidth: 20, cornerHeight: 20, transform: .none)
        borderLayer.path = path.cgPath
        borderLayer.frame = self.containerView.bounds
        
        self.containerView.layer.addSublayer(borderLayer)
    }
    
    private func generateThumbnail(path: URL) -> UIImage? {
        do {
            let asset = AVURLAsset(url: path, options: nil)
            let imgGenerator = AVAssetImageGenerator(asset: asset)
            imgGenerator.appliesPreferredTrackTransform = true
            let cgImage = try imgGenerator.copyCGImage(at: CMTimeMake(value: 0, timescale: 1), actualTime: nil)
            let thumbnail = UIImage(cgImage: cgImage)
            return thumbnail
        } catch let error {
            print("*** Error generating thumbnail: \(error.localizedDescription)")
            return nil
        }
    }
    
    func updateCell(path: URL) {
        containerEditView.isHidden = false
        thumbImageView.isHidden = false
        thumbImageView.image = generateThumbnail(path: path)
    }
    
    //MARK: - Selectors
    @objc func handlePickVideoTapped() {
        self.delegate?.didSelecChooseVideoButton()
    }
    
}
