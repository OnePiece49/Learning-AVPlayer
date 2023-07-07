//
//  AudioCell.swift
//  LAS_SAMPLE_100
//
//  Created by Minh Tuan on 12/06/2023.
//

import UIKit
import MediaPlayer

class AudioItemCell: UITableViewCell {
    
    var audio: MPMediaItem! {
        didSet{
            titleLabel.text = audio.title
            let duration = audio.playbackDuration
            durationLabel.text = audioDuration(time: duration)
        }
    }
    
    //MARK: - outlets
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func audioDuration(time: Double) -> String {
        let s: Int = Int(time) % 60
        let m: Int = Int(time) / 60
        let formattedDuration = String(format: "%02d:%02d", m, s)
        return formattedDuration
    }
    
    
}
