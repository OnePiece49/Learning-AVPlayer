//
//  PlayerController.swift
//  LAS_SAMPLE_014
//
//  Created by Đức Anh Trần on 22/06/2023.
//

import UIKit
import AVFoundation

class PlayerController: UIViewController {

    // MARK: - Properties

    private var videoList: [String] = []
    var selectedIndex: Int?

    // MARK: - Outlets

    @IBOutlet weak var customPlayer: VideoPlayerView!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var myFileTBView: UITableView!

    // MARK: - Life cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        loadVideo()
        setupUI()
        setupTBView()
        if let index = selectedIndex {
            let path = videoList[index]
            playVideoPath(videoStr: path)
            myFileTBView.scrollToRow(at: IndexPath(row: index, section: 0), at: .top, animated: false)
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        customPlayer.updateLayoutSubviews()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.post(name: .stop_player, object: nil)
    }

    // MARK: - Methods

    private func setupUI() {
        backButton.titleLabel?.font = UIFont.fontMedium(14)
        backButton.setTitleColor(UIColor(rgb: 0x4B42ED), for: .normal)
    }

    private func setupTBView() {
        myFileTBView.separatorStyle = .none
        myFileTBView.delegate = self
        myFileTBView.dataSource = self
        myFileTBView.register(UINib(nibName: PlayingVideoCell.cellId, bundle: nil), forCellReuseIdentifier: PlayingVideoCell.cellId)
    }

    @IBAction func backButtonTapped(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }

    @IBAction func shareButtonTapped(_ sender: Any) {
        if let index = selectedIndex {
            let videoUrl = URL.videoEditorFolder()!.appendingPathComponent(videoList[index])
            let textToShare = "Share \(videoList[index]) to"
            let objectsToShare: [Any] = [textToShare, videoUrl]
            let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
            activityVC.popoverPresentationController?.sourceView = self.view
            self.present(activityVC, animated: true, completion: nil)
        }
    }

    private func loadVideo() {
        guard let imageURL = URL.videoEditorFolder() else { return }
        do {
            videoList = try FileManager.default.contentsOfDirectory(atPath: imageURL.path)
        }
        catch let error as NSError {
            print(error.localizedDescription)
            videoList = []
        }
    }

    private func playVideoPath(videoStr: String) {
        guard let pathURL = URL.videoEditorFolder()?.appendingPathComponent(videoStr) else {return}
        let asset = AVURLAsset(url: pathURL)

        DispatchQueue.main.async {
            self.customPlayer.playVideo(with: asset.url.absoluteString)
        }
    }

}

extension PlayerController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return videoList.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: PlayingVideoCell.cellId) as! PlayingVideoCell
        cell.titleVideo = videoList[indexPath.row]
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        selectedIndex = indexPath.row
        let path = videoList[indexPath.row]
        playVideoPath(videoStr: path)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
}
