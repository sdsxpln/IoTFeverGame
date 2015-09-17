//
//  GameEnd.swift
//  IoTFeverGame
//
//  Created by Foitzik Andreas on 15/9/15.
//  Copyright (c) 2015 Foitzik Andreas. All rights reserved.
//

import UIKit

class GameEndViewController : UIViewController {

    
    @IBOutlet weak var lblResult        : UILabel!
    @IBOutlet weak var lblScore         : UILabel!
    @IBOutlet weak var lblScoreResult   : UILabel!
    @IBOutlet weak var btnRestart: UIButton!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        gameEnvironment!.sensorService.disconnect()
        
        if currentGame.player.score == 100 {
            self.lblResult.text = "You are a Dance God!"
        } else {
            self.lblResult.text = "Game Over!"
        }
        
        self.lblScoreResult.text = String(currentGame.player.score)
        self.btnRestart.setTitle("Restart Game", forState: .Normal)
       
        // TODO replace with Publisher (Protocol)
        gameEnvironment!.rankingService.publish(currentGame.player)
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func restartGame(sender: AnyObject) {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.performSegueWithIdentifier("restartGameIdentifier", sender: self)
        });
    }
}
