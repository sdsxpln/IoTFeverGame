//
//  IoTFeverGameViewController.swift
//  IoTFeverGame
//
//  Created by Foitzik Andreas on 3/9/15.
//  Copyright (c) 2015 Foitzik Andreas. All rights reserved.
//

import UIKit
import CoreData
import CoreBluetooth
import AVFoundation

var currentGame                         : IoTFeverGame!


class IoTFeverGameViewController: UIViewController, SensorDataListener, AnyObject {
    
    var hitMessages : [String] = ["Whatta move!",
                                  "You're on fire!",
                                  "It's getting hot in here"]
    
    var missMessages : [String] = ["Oops",
                                   "Ouch!",
                                   "Ain't your day huh"]
    
    // MARK: UI Properties
    @IBOutlet weak var score                : UILabel!
    @IBOutlet weak var bonusPoints          : UILabel!
    @IBOutlet weak var try1Image            : UIImageView!
    @IBOutlet weak var try2Image            : UIImageView!
    @IBOutlet weak var try3Image            : UIImageView!
    
    @IBOutlet weak var imageView            : UIImageView!
    
    @IBOutlet weak var timeLabel            : UILabel!
    @IBOutlet weak var timeCountLabel       : UILabel!
    
    @IBOutlet weak var levelLabel           : UILabel!
    @IBOutlet weak var levelAmountLabel     : UILabel!
    
    @IBOutlet weak var GameOver             : UILabel!
    
    
    var gameTimer : NSTimer?
    var levelTimer: NSTimer?
    var moveTimer : NSTimer?
    
    var emitterLayer : CAEmitterLayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let sensorService = gameEnvironment!.sensorService
        sensorService.subscribe(self)
        
        currentGame = IoTFeverGame(username: "test")
        let firstLevel = currentGame.start()
        self.timeCountLabel.text = String(firstLevel.duration)
        createNewMove(firstLevel)
        scheduleLevelTimers(firstLevel)
        
        // Visualizer
        let vizView = VisualizerView()
        vizView.backgroundColor = UIColor.blackColor()
        self.view.addSubview(vizView)
        self.view.sendSubviewToBack(vizView)    
    }
    
    func scheduleLevelTimers(level : Level) {
         // starts level Countdown timer
         gameTimer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: Selector("levelCountdown"), userInfo: nil, repeats: true)
         // starts Level duration timer
         levelTimer = NSTimer.scheduledTimerWithTimeInterval(NSTimeInterval(level.duration+1), target: self, selector: Selector("levelEnded"), userInfo: nil, repeats: true)
         // starts Move change timer
         moveTimer = NSTimer.scheduledTimerWithTimeInterval(NSTimeInterval(level.delayBetweenMoves), target: self, selector: Selector("validateLastAndCreateNewMove"), userInfo: nil, repeats: true)
    }
    
    func unscheduleTimers() {
        gameTimer!.invalidate()
        levelTimer!.invalidate()
        moveTimer!.invalidate()
    }
    
    func levelEnded() {
        unscheduleTimers()
        if (currentGame.hasNextLevel()) {
            let nextLevel = currentGame.getNextLevel()
            levelAmountLabel.text = String(nextLevel.name)
            createNewMove(nextLevel)
            scheduleLevelTimers(nextLevel)
        } else {
            currentGame.stopGame()
            renderGameOver()
        }
    }
    
    func renderGameOver() {
        self.performSegueWithIdentifier("gameEndIdentifier", sender: self)
    }
    
    func validateLastAndCreateNewMove() {
        var currentLevel = currentGame.getCurrentLevel()
        if (!currentLevel.currentMove!.isCompleted()) {
            isMiss()
        } else {
            isHit()
        }
        createNewMove(currentLevel)
    }
    
    func isMiss() {
        flashRed()
        currentGame.player.deductLive()
        var livesLeft = currentGame.player.lives
        if (livesLeft == 2) {
            self.try3Image.hidden = true
        } else if (livesLeft == 1) {
            self.try2Image.hidden = true
        } else {
            self.try1Image.hidden = true
            currentGame.stopGame()
            unscheduleTimers()
            renderGameOver()
            return
        }
    }
    
    func flashRed() {
        let result = Int(arc4random_uniform(UInt32(self.missMessages.count)))
        self.GameOver.text = missMessages[result]
    }
    
    func isHit() {
        currentGame.increaseHits()
        self.score.text = String(currentGame.player.score)
        self.bonusPoints.text = String(currentGame.player.bonus)
        flashGreen()
    }
    
    func flashGreen() {
        let result = Int(arc4random_uniform(UInt32(self.hitMessages.count)))
        self.GameOver.text = hitMessages[result]
    }
    
    func createNewMove(level : Level) {
        level.newMove()
        self.imageView.image = UIImage(named: level.currentMove!.getImage())
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func onDataRightIncoming(data: [Double]) {
        if (currentGame.isRunning) {
            var currentMove = currentGame.getCurrentLevel().currentMove as! TwoStepMove
            currentMove.rightArm.mimicMove(data)
        }
    }
    
    func onDataLeftIncoming(data: [Double]) {
        if (currentGame.isRunning) {
            var currentMove = currentGame.getCurrentLevel().currentMove as! TwoStepMove
            currentMove.leftArm.mimicMove(data)
        }
    }
    
    func levelCountdown() {
        self.timeCountLabel.text = String(currentGame.getCurrentLevel().duration--)
    }
}
