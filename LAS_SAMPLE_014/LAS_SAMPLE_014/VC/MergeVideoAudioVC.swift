//
//  MergeVideoAudioVC.swift
//  LAS_SAMPLE_014
//
//  Created by Minh Tuan on 14/06/2023.
//

import UIKit
import Photos
import MediaPlayer

class MergeVideoAudioVC: BaseVC {
    
    var imagePickerController = UIImagePickerController()
    var songService: SongService = SongService()
    var navigationBar: NavigationCustomView!
    var loadingView: LoadingView!
    
    var videoURL: URL?
    var videoName: String = ""
    var audio: MPMediaItem?
    
    var layouts: [String] = [
        MergeVideoItemCell.cellId,
        GalleryAudioCell.cellId
    ]
    
    private let plusView: UIView = {
        let containerView = UIView()
        
        let mergeV = UIView()
        mergeV.backgroundColor = UIColor(rgb: 0x5F53FF)
        mergeV.translatesAutoresizingMaskIntoConstraints = false
        mergeV.layer.cornerRadius = 18
        
        let button = UIButton()
        button.setImage(UIImage(named: "ic_mergeVid-N-Aud"), for: .normal)
        button.contentVerticalAlignment = .fill
        button.contentHorizontalAlignment = .fill
        button.contentMode = .scaleToFill
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .clear
        button.tintColor = .white
        
        mergeV.addSubview(button)
        containerView.addSubview(mergeV)
        NSLayoutConstraint.activate([
            button.centerXAnchor.constraint(equalTo: mergeV.centerXAnchor),
            button.centerYAnchor.constraint(equalTo: mergeV.centerYAnchor),
            button.widthAnchor.constraint(equalTo: button.heightAnchor),
            button.widthAnchor.constraint(equalTo: mergeV.widthAnchor, multiplier: 1 / 2),
            
            mergeV.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 23),
            mergeV.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
        ])
        mergeV.setDimensions(width: 36, height: 36)
        return containerView
    }()
    
    private lazy var mergeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Merge", for: .normal)
        button.titleLabel?.font = UIFont.fontBold(16)
        button.setTitleColor(.white, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 10
        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(handleMergeButtonTapped), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        mergeTBView.reloadData()
    }
    
    @IBOutlet weak var mergeTBView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let config = LoadingViewConfig(messageText: "Merge Video & Audio...",
                                       animationName: "animation_merge_audio",
                                       animationConfig: LottieAnimationConfig(estimatedWidth: 324,
                                                                              aspectRatio: 324 / 280,
                                                                              spacingFromVerticalCenter: -40,
                                                                              spacingToImage: -15))
        loadingView = LoadingView(config: config)
        
        configureUI()
        requestData()
        mergeTBView.register(UINib(nibName: MergeVideoItemCell.cellId, bundle: nil), forCellReuseIdentifier: MergeVideoItemCell.cellId)
        mergeTBView.register(GalleryAudioCell.self, forCellReuseIdentifier: GalleryAudioCell.cellId)
        mergeTBView.delegate = self
        mergeTBView.dataSource = self
        mergeTBView.isScrollEnabled = false
    }
    
    func configureUI() {
        let attributeRightButton = AttibutesButton(tilte: "Cancel",
                                                   font: UIFont.fontMedium(14) ?? UIFont.systemFont(ofSize: 14),
                                                   titleColor: UIColor(rgb: 0x4B42ED)) { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }
        let attributed = NSAttributedString(attributedString: NSAttributedString(string: "Merge Video & Audio",
                                                                                 attributes: [.foregroundColor: UIColor.black, .font : UIFont.fontBold(16)]))
        self.navigationBar = NavigationCustomView(attributedTitle: attributed,
                                                  attributeLeftButtons: [],
                                                  attributeRightBarButtons: [attributeRightButton],
                                                  isHiddenDivider: true,
                                                  beginSpaceRightButton: 15)
        
        navigationBar.translatesAutoresizingMaskIntoConstraints = false
        navigationBar.backgroundColor = .white
        mergeTBView.translatesAutoresizingMaskIntoConstraints = false
        mergeTBView.separatorStyle = .none
        view.backgroundColor = .white
        
        view.addSubview(navigationBar)
        view.addSubview(mergeButton)
        NSLayoutConstraint.activate([
            navigationBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            navigationBar.leftAnchor.constraint(equalTo: view.leftAnchor),
            navigationBar.rightAnchor.constraint(equalTo: view.rightAnchor),
            navigationBar.heightAnchor.constraint(equalToConstant: 45),
            
            mergeTBView.topAnchor.constraint(equalTo: navigationBar.bottomAnchor, constant: 5),
            mergeTBView.leftAnchor.constraint(equalTo: view.leftAnchor),
            mergeTBView.rightAnchor.constraint(equalTo: view.rightAnchor),
            mergeTBView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 620 / 892),
            
            mergeButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            mergeButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -45),
        ])
        mergeButton.setDimensions(width: 168, height: 50)
        view.layoutIfNeeded()
        
        let colors: [UIColor] = [UIColor(rgb: 0x5D5BFA),
                                 UIColor(rgb: 0x45ABFF)]
        let startPoint = CGPoint(x: 0.0, y: 0.0)
        let endPoint = CGPoint(x: 0.0, y: 1.0)
        mergeButton.applyGradient(colors: colors, startPoint: startPoint, endPoint: endPoint)
    }
    
    func requestData() {
        if #available(iOS 14, *) {
            PHPhotoLibrary.requestAuthorization(for: .readWrite) { _ in
            }
        }
    }
    
    @objc func handleMergeButtonTapped() {
        VideoGenerator.fileName = "Merge_" +  videoName
        
        guard let urlVideo = videoURL else { self.view.displayToast("Merge Error"); return}
        guard let audio = audio else { self.view.displayToast("Merge Error"); return }
        loadingView.show()
        
        guard let urlAudio = songService.getSongURL(songId: "\(audio.persistentID)") else { return }
        
        VideoGenerator.current.mergeVideoWithAudio(videoUrl: urlVideo, audioUrl: urlAudio) { (result) in
            self.loadingView.dismiss()
            switch result {
            case .success(let url):
                self.view.displayToast("Merged success!")
                self.openMyFile()
            case .failure(let error):
                self.view.displayToast("Merged error!")
                print(error)
            }
        }
    }
    
}

extension MergeVideoAudioVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: MergeVideoItemCell.cellId) as! MergeVideoItemCell
            cell.videoUrl = videoURL
            cell.titleLabel.text = videoName
            cell.selectionStyle = .none
            cell.delegate = self
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: GalleryAudioCell.cellId) as! GalleryAudioCell
        cell.selectionStyle = .none
        cell.delegate = self
        return cell
    }
}

extension MergeVideoAudioVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return (mergeTBView.frame.height - 87) / 2
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return layouts.count
    }
    
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == 0 {
            return 87
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if section == 0 {
            return plusView
        }
        return nil
    }
}

extension MergeVideoAudioVC: MergeVideoItemCellDelegate {
    func didSelecChooseVideoButton() {
        let chooseVideo = PhotoVC(type: .mergeAudio)
        chooseVideo.selectedVideo = { asset, filename in
            guard let url = asset?.url else {return}
            self.videoName = filename ?? ""
            self.videoURL = asset?.url
            let cell = self.mergeTBView.cellForRow(at: IndexPath(row: 0, section: 0)) as! MergeVideoItemCell
            cell.updateCell(path: url)
        }
        self.navigationController?.pushViewController(chooseVideo, animated: true)
    }
}

extension MergeVideoAudioVC: GalleryAudioCellDelegate {
    func didSelectChoseAudioButton(cell: GalleryAudioCell) {
        let audio = AudioVC()
        audio.onSelectedAudio = { audio in
            self.audio = audio
            cell.source = audio
        }
        self.navigationController?.pushViewController(audio, animated: true)
    }
}
