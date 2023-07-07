//
//  PlayerVC.swift
//  LAS_SAMPLE_100
//
//  Created by Minh Tuan on 13/06/2023.
//

import UIKit
import AVFoundation

class PlayerVC: BaseVC {
    
    var path: String?
    
    @IBOutlet weak var customPlayer: VideoPlayer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        if path != nil {
            playVideoPath(videoStr: path!)
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
    
    
    func playVideoPath (videoStr: String) {
        
        guard let pathURL = URL.videoEditorFolder()?.appendingPathComponent(videoStr) else {return}
        
        let asset = AVURLAsset(url: pathURL)
        
        DispatchQueue.main.async { [self] in
            //play video
            self.customPlayer.playVideo(with: asset.url.absoluteString)
            
            //close
            self.customPlayer.dismissClosure = { [weak self] in
                self?.navigationController?.popViewController(animated: true)
            }
            
            //take photo
            self.customPlayer.captureVideo = { image in
                //  self.view.displayToast("Cannot capture!")
            }
            
            //compress video
            self.customPlayer.onConvertMp3 = {
                // validate
                // self.view.displayToast("Cannot Convert!")
            }
        }
    }
    
    @objc func savelibrary(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            // we got back an error!
            //    self.view.displayToast("Save error '\(error)'")
            
        } else {
            // self.view.displayToast("The image has been saved to your photos.")
            
        }
    }
    
    
    
    
}
