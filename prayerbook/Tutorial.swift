//
//  Tutorial.swift
//  prayerbook
//
//  Created by Alexey Smirnov on 2/3/16.
//  Copyright © 2016 Alexey Smirnov. All rights reserved.
//

import UIKit
import MediaPlayer
import swift_toolkit

class Tutorial : UIViewController {
    
    var videoController : MPMoviePlayerController!
    weak var delegate: UIViewController!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let videoURL = Bundle.main.url(forResource: "widget", withExtension: "mp4")
        videoController = MPMoviePlayerController()
        videoController.backgroundView.backgroundColor = UIColor.white
        videoController.contentURL = videoURL
        
        title = Translate.s("Add widget")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        view.addSubview(videoController.view)
        var frame = view.convert(view.frame, to: navigationController!.view)
        
        let navBarHeight = navigationController!.navigationBar.frame.size.height + UIApplication.shared.statusBarFrame.size.height
        
        frame.origin.y = navBarHeight
        frame.size.height -= navBarHeight
        
        videoController.view.frame = frame
        videoController.play()
    }

    @IBAction func close(_ sender: AnyObject) {
        delegate.dismiss(animated: true, completion: nil)

    }
}
