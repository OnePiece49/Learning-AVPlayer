//
//  GalleryAudioCell.swift
//  LAS_SAMPLE_100
//
//  Created by Minh Tuan on 12/06/2023.
//

import UIKit
import MediaPlayer

protocol GalleryAudioCellDelegate: AnyObject {
    func didSelectChoseAudioButton(cell: GalleryAudioCell)
}

class GalleryAudioCell: UITableViewCell {
    
    //MARK: - Properties
    weak var delegate: GalleryAudioCellDelegate?
    var source: MPMediaItem? {
        didSet {
            updateCell()
        }
    }
    
    private lazy var nameAudioLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .black
        label.font = .fontBold(16)
        return label
    }()
    
    private lazy var durationAudioLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .black
        label.font = .fontRegular(14)
        return label
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
        button.addTarget(self, action: #selector(handlePickAudioButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var editLabelButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Edit", for: .normal)
        button.setTitleColor(UIColor.white, for: .normal)
        button.titleLabel?.font = UIFont.fontMedium(14)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(handlePickAudioButtonTapped), for: .touchUpInside)
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
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handlePickAudioButtonTapped)))
        return view
    }()
    
    private lazy var audioImagevIew: UIImageView = {
        let iv = UIImageView(image: UIImage(named: "ic_pickAudi"))
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private lazy var pickAudioButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Choose Audio", for: .normal)
        button.setTitleColor(UIColor(rgb: 0x4B42ED), for: .normal)
        button.titleLabel?.font = UIFont.fontMedium(14)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 10
        button.layer.borderColor = UIColor(rgb: 0x4B42ED).cgColor
        button.layer.borderWidth = 1
        button.backgroundColor = .clear
        button.layer.backgroundColor = UIColor.clear.cgColor
        button.addTarget(self, action: #selector(handlePickAudioButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor(rgb: 0xEAF4FF)
        view.layer.cornerRadius = 20
        view.layer.masksToBounds = true
        
        view.addSubview(audioImagevIew)
        view.addSubview(pickAudioButton)
        view.addSubview(containerEditView)
        view.addSubview(nameAudioLabel)
        view.addSubview(durationAudioLabel)
        
        NSLayoutConstraint.activate([
            audioImagevIew.widthAnchor.constraint(equalTo: audioImagevIew.heightAnchor, multiplier: 51 / 54),
            audioImagevIew.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            audioImagevIew.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -30),
            audioImagevIew.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 66 / 358),
            
            pickAudioButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            pickAudioButton.topAnchor.constraint(equalTo: audioImagevIew.bottomAnchor, constant: 14),
            
            containerEditView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -10),
            containerEditView.topAnchor.constraint(equalTo: view.topAnchor, constant: 10),
            
            nameAudioLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            nameAudioLabel.topAnchor.constraint(equalTo: audioImagevIew.bottomAnchor, constant: 11),
            
            durationAudioLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            durationAudioLabel.topAnchor.constraint(equalTo: nameAudioLabel.bottomAnchor, constant: 14),
        ])
        return view
    }()
    
    //MARK: - LifeCycle
    override var frame: CGRect {
        didSet {
            applyBorder()
        }
    }
    
    //MARK: - Helpers
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
        borderLayer.lineDashPattern = [3, 2]
        borderLayer.name = "borderLayer"
        
        let path = UIBezierPath()
        path.cgPath = CGPath(roundedRect: self.containerView.bounds, cornerWidth: 20, cornerHeight: 20, transform: .none)
        borderLayer.path = path.cgPath
        borderLayer.frame = self.containerView.bounds
        
        self.containerView.layer.addSublayer(borderLayer)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        configureUI()
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureUI() {
        contentView.addSubview(containerView)
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: topAnchor, constant: 0),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0),
            containerView.leftAnchor.constraint(equalTo: leftAnchor, constant: 18),
            containerView.rightAnchor.constraint(equalTo: rightAnchor, constant: -18),
            
        ])
        pickAudioButton.setDimensions(width: 116, height: 36)
    }
    
    private func updateCell() {
        guard let source = source else {
            return
        }
        
        audioImagevIew.image = UIImage(named: "ic_selectedAudio")
        nameAudioLabel.isHidden = false
        durationAudioLabel.isHidden = false
        pickAudioButton.isHidden = true
        nameAudioLabel.text = source.title
        let time  = CMTimeMakeWithSeconds(source.playbackDuration, preferredTimescale: 1000)
        durationAudioLabel.text = getTimeString(time: time)
        containerEditView.isHidden = false
    }
    
    func getTimeString(time: CMTime) -> String? {
        let totalSeconds = CMTimeGetSeconds(time)
        guard !(totalSeconds.isNaN || totalSeconds.isInfinite) else {
            return nil
        }
        let hours = Int(totalSeconds / 3600)
        let minutes = Int(totalSeconds / 60) % 60
        let seconds = Int(totalSeconds.truncatingRemainder(dividingBy: 60))
        if hours > 0 {
            return String(format: "%i:%02i:%02i",arguments: [hours, minutes, seconds])
        } else {
            return String(format: "%02i:%02i", arguments: [minutes, seconds])
        }
    }
    
    
    //MARK: - Selector:
    @objc func handlePickAudioButtonTapped() {
        delegate?.didSelectChoseAudioButton(cell: self)
    }
    
}
