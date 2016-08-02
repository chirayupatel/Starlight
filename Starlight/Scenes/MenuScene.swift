//
//  MenuScene.swift
//  Starlight
//
//  Created by Terry on 2015-09-01.
//  Copyright © 2015 Flybits Inc. All rights reserved.
//

import SpriteKit
import FlybitsSDK

class MenuScene: SKScene, MenuUIDelegate {
    // MARK: - Properties
    var connectionAttempted = false {
        didSet {
            if let menuUI = menuUI {
                menuUI.connectionAttempted = connectionAttempted
            }
        }
    }

    // MARK: - UI Elements
    var menuUI: MenuUI!

    // MARK: - Lifecycle Functions
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        self.size = view.frame.size
        self.userInteractionEnabled = true

        setupScene()
        connectToFlybits()
    }

    // MARK: - Functions
    func setupScene() {
        menuUI = MenuUI(atlasNamed: "StartUI", size: size)
        menuUI.position = CGPointMake(size.width / 2, size.height / 2)
        menuUI.delegate = self
        addChild(menuUI)
    }

    func connectToFlybits() {
        Session.sharedInstance.configuration.environment = SessionConfiguration.Environment.Production
        Session.sharedInstance.configuration.APIKey = "<#API Key#>"

        print(Session.sharedInstance.configuration.serverURL)
        SessionRequest.Login(email: Constants.Username, password: Constants.Password, rememberMe: false) { (user, error) in
            self.connectionAttempted = true
            guard let error = error else {
                print(Session.sharedInstance.jwtToken!)
                return
            }
            print(error)
        }.execute()
    }

    func disconnectFromFlybits() {
        if Session.sharedInstance.status == .Connected {
            SessionRequest.Logout { (success, error) -> Void in
                self.connectionAttempted = false
            }.execute()
        }
    }

    // MARK: - MenuUIDelegate Functions
    func onStartTapped(state: Bool) {
        if state {
            let gameScene = GameScene(fileNamed: "GameScene")!
            let transition = SKTransition.doorsOpenHorizontalWithDuration(0.5)
            view?.presentScene(gameScene, transition: transition)
        }
    }
}
