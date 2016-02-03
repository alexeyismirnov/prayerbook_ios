//
//  Tutorial.swift
//  prayerbook
//
//  Created by Alexey Smirnov on 2/3/16.
//  Copyright © 2016 Alexey Smirnov. All rights reserved.
//

import UIKit
import MediaPlayer

class Tutorial : UIViewController {
    
    var videoController : MPMoviePlayerController!
    weak var delegate: UIViewController!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let videoURL = NSBundle.mainBundle().URLForResource("widget", withExtension: "mp4")
        videoController = MPMoviePlayerController()
        videoController.backgroundView.backgroundColor = UIColor.whiteColor()
        videoController.contentURL = videoURL
        
        title = Translate.s("Add widget")
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        view.addSubview(videoController.view)
        var frame = view.convertRect(view.frame, toView: navigationController!.view)
        
        let navBarHeight = navigationController!.navigationBar.frame.size.height + UIApplication.sharedApplication().statusBarFrame.size.height
        
        frame.origin.y = navBarHeight
        frame.size.height -= navBarHeight
        
        videoController.view.frame = frame
        videoController.play()
    }

    @IBAction func close(sender: AnyObject) {
        delegate.dismissViewControllerAnimated(true, completion: nil)

    }
}
