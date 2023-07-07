//
//  MyFileVC.swift
//  LAS_SAMPLE_100
//
//  Created by Minh Tuan on 13/06/2023.
//

import UIKit
import AVFoundation
import AVKit

class MyFileVC: BaseVC {
    
    fileprivate var videoList: [String] = []
    
    @IBOutlet weak var myFileTBView: UITableView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var backButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTBView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadVideo()
    }
    
    private func setupUI() {
        titleLabel.font = UIFont.fontBold(16)
        titleLabel.textColor = UIColor(rgb: 0x000000)
        backButton.titleLabel?.font = UIFont.fontMedium(14)
        backButton.setTitleColor(UIColor(rgb: 0x4B42ED), for: .normal)
    }
    
    private func setupTBView() {
        //myFileTBView.separatorStyle = .none
        myFileTBView.delegate = self
        myFileTBView.dataSource = self
        myFileTBView.register(UINib(nibName: MyFileItemCell.cellId, bundle: nil), forCellReuseIdentifier: MyFileItemCell.cellId)
    }
    
    func deleteFile(videoPath: String) {
        guard let url = URL.videoEditorFolder()?.appendingPathComponent(videoPath) else {return}
        try? FileManager.default.removeItem(at: url)
        self.view.displayToast("File deleted")
    }
    
    func loadVideo() {
        guard let imageURL = URL.videoEditorFolder() else { return }
        do {
            videoList = try FileManager.default.contentsOfDirectory(atPath: imageURL.path)
            self.myFileTBView.reloadData()
        }
        catch  let error as NSError {
            print(error.localizedDescription)
            videoList = []
        }
    }
    
    @IBAction func backClick(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}

extension MyFileVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return videoList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: MyFileItemCell.cellId) as! MyFileItemCell
        cell.titleVideo = videoList[indexPath.row]
        cell.delegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let navi = UIWindow.keyWindow?.rootViewController as? UINavigationController else {
            return
        }
        let playerVC: PlayerController = PlayerController()
        playerVC.selectedIndex = indexPath.row
        playerVC.modalPresentationStyle = .fullScreen
        navi.pushViewController(playerVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            self.deleteFile(videoPath: videoList[indexPath.row])
            self.loadVideo()
        }
    }
}

extension MyFileVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 95
    }
}

extension MyFileVC: MyFileItemCellDelegate {
    func didTapOnShareButton(_ cell: MyFileItemCell) {
        guard let indexPath = myFileTBView.indexPath(for: cell) else { return }
        
        let videoUrl = URL.videoEditorFolder()!.appendingPathComponent(videoList[indexPath.row])
        let textToShare = "Share \(self.videoList[indexPath.row]) to"
        let objectsToShare: [Any] = [textToShare, videoUrl]
        let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
        activityVC.popoverPresentationController?.sourceView = self.view
        self.present(activityVC, animated: true, completion: nil)
    }
}
