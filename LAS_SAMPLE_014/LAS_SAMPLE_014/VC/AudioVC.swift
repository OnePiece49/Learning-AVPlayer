//
//  AudioVC.swift
//  LAS_SAMPLE_100
//
//  Created by Minh Tuan on 12/06/2023.
//

import UIKit
import MediaPlayer

class AudioVC: BaseVC {
    //MARK: - properties
    var songService: SongService = SongService()
    var musics:[MPMediaItem] = []
    
    var onSelectedAudio:((_ audios: MPMediaItem)->Void)?
    
    //MARK: - outlets
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var addAudioButton: UIButton!
    @IBOutlet weak var audioTBView: UITableView!
    
    //MARK: - life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        //setup UI
        audioTBView.register(UINib(nibName: AudioItemCell.cellId, bundle: nil), forCellReuseIdentifier: AudioItemCell.cellId)
        audioTBView.delegate = self
        audioTBView.dataSource = self
        // audioTBView.separatorStyle = .none
        backButton.setTitleColor(UIColor(rgb: 0x4B42ED), for: .normal)
        
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadData()
    }
    
    private func loadData() {
        //load music local
        MPMediaLibrary.requestAuthorization { (status) in
            if status == .authorized {
                self.musics = self.songService.getAudio()
                print(self.musics.count)
                DispatchQueue.main.async {
                    self.audioTBView.reloadData()
                }
            } else {
                self.displayMediaLibraryError()
            }
        }
    }
    
    func displayMediaLibraryError() {
        
        var error: String
        switch MPMediaLibrary.authorizationStatus() {
        case .restricted:
            error = "Media library access restricted by corporate or parental settings"
        case .denied:
            error = "Media library access denied by user"
        default:
            error = "Unknown error"
        }
        DispatchQueue.main.async {
            let controller = UIAlertController(title: "Error", message: error, preferredStyle: .alert)
            controller.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            controller.addAction(UIAlertAction(title: "Open Settings", style: .default, handler: { (action) in
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: [:], completionHandler: nil)
                } else {
                    // Fallback on earlier versions
                }
            }))
            self.present(controller, animated: true, completion: nil)
        }
    }
    
    
    @IBAction func backClick(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
}

extension AudioVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return musics.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: AudioItemCell.cellId) as! AudioItemCell
        cell.audio = musics[indexPath.row]
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let audio = musics[indexPath.row]
        onSelectedAudio?(audio)
        self.navigationController?.popViewController(animated: true)
    }
}
extension AudioVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
}
