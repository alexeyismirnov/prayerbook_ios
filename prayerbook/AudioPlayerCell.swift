//
//  AudioPlayerCell.swift
//  ponomar
//
//  Created by Alexey Smirnov on 11/6/18.
//  Copyright © 2018 Alexey Smirnov. All rights reserved.
//

import UIKit
import AVFoundation
import swift_toolkit

class AudioPlayerCell: UITableViewCell, AVAudioPlayerDelegate {
    @IBOutlet weak var playPauseButton: UIButton!
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var timeLabel: UILabel!
    
    var player: AVAudioPlayer!
    var updater : CADisplayLink! 

    let playImage = UIImage(named: "play")?.withRenderingMode(.alwaysTemplate)
    let pauseImage = UIImage(named: "pause")?.withRenderingMode(.alwaysTemplate)
    
    var durationString = ""
    let documentDirectory:URL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!

    var filename : String!  {
        didSet {
            let url = documentDirectory.appendingPathComponent("/tropari/tropari/\(filename!).mp3")

            do {
                playPauseButton.setImage(playImage, for: .normal)

                player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.mp3.rawValue)
                player.delegate = self
                player.prepareToPlay()
                
                slider.setValue(0.0, animated: false)
                slider.minimumValue = 0.0
                slider.maximumValue = Float(player.duration)
                
                let duration = Int(player.duration)
                durationString = String(format: "%02d:%02d", duration/60, duration%60)
                
                timeLabel.text = durationString
                
            } catch {
                print("Unexpected error: \(error).")
                
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        playPauseButton.setImage(playImage, for: .normal)

        playPauseButton.tintColor = UIBarButtonItem.appearance(whenContainedInInstancesOf: [UINavigationBar.self]).tintColor
        playPauseButton.backgroundColor = .clear
        
        timeLabel.textColor = Theme.textColor
        
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [.mixWithOthers, .allowAirPlay])
            try AVAudioSession.sharedInstance().setActive(true)

        } catch { }
        
    }

    @IBAction func buttonPressed(_ sender: Any) {
        if player.isPlaying {
            updater.invalidate()
            player.pause()
            playPauseButton.setImage(playImage, for: .normal)

        } else {
            updater = CADisplayLink(target: self, selector: #selector(self.trackAudio))
            updater.preferredFramesPerSecond = 2
            updater.add(to: RunLoop.current, forMode: RunLoop.Mode.common)
            
            player.play()
            playPauseButton.setImage(pauseImage, for: .normal)
        }
        
    }
    
    @objc func trackAudio() {
        slider.value = Float(player.currentTime)
        
        let current = Int(player.currentTime)
        timeLabel.text = String(format: "%02d:%02d", current/60, current%60)
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        playPauseButton.setImage(playImage, for: .normal)
        slider.setValue(0.0, animated: false)
        timeLabel.text = durationString

    }
    
    @IBAction func sliderMoved(_ sender: UISlider) {
       player.currentTime = TimeInterval(slider.value)
    }
    
}
