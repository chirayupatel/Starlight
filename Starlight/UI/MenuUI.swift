//
//  MenuUI.swift
//  Starlight
//
//  Created by Terry on 2015-09-01.
//  Copyright © 2015 Flybits Inc. All rights reserved.
//

import SpriteKit

protocol MenuUIDelegate {
    func onStartTapped(state: Bool)
}

class MenuUI: FLBUIElement, FLBUITouchDelegate {

    // MARK: - Constants
    static let ZPosition: CGFloat = 1000

    // MARK: - Properties
    let atlas: SKTextureAtlas
    let size: CGSize
    var connectionAttempted: Bool {
        didSet {
            updateUIForConnection()
        }
    }
    var delegate: MenuUIDelegate?

    // MARK: - UI Elements
    var startButton: FLBUIButton!
    var connectingLabel: FLBUILabel!

    // MARK: - Lifecycle Functions
    init(atlasNamed atlasName: String, size: CGSize) {
        self.atlas = ResourceManager.atlas(named: atlasName)
        self.size = size
        self.connectionAttempted = false

        super.init()

        userInteractionEnabled = true

        layoutUI()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Functions
    func layoutUI() {
        zPosition = MenuUI.ZPosition

        // Add Background Layers
        let backgroundSize = size
        let layer1 = SKSpriteNode(texture: atlas.textureNamed("background_1"), color: SKColor.clearColor(), size: backgroundSize)
        addChild(layer1)

        let layer2 = SKSpriteNode(texture: atlas.textureNamed("background_2_planet"), color: SKColor.clearColor(), size: backgroundSize * 1.2)
        layer2.position = CGPointMake(backgroundSize.width * 0.20, -backgroundSize.height * 0.20)
        addChild(layer2)

        let layer3 = SKSpriteNode(texture: atlas.textureNamed("background_3"), color: SKColor.clearColor(), size: backgroundSize)
        addChild(layer3)

        let layer4 = SKSpriteNode(texture: atlas.textureNamed("background_4"), color: SKColor.clearColor(), size: backgroundSize)
        addChild(layer4)

        let elementSize = CGSizeMake(120, 30)

        // Start Button
        startButton = FLBUIButton(size: size, colors: nil, textures: nil, text: "PLAY")
        startButton.position = CGPointZero
        startButton.zPosition = zPosition + 1
        startButton.delegate = self
        startButton.userInteractionEnabled = false
        startButton.alpha = 0
        startButton.labelNode!.fontSize = 24
        addChild(startButton)

        // Connecting Label
        connectingLabel = FLBUILabel(texture: nil, color: SKColor.clearColor(), size: elementSize, text: "Flybits: Context at your service")
        connectingLabel.position = CGPointZero
        connectingLabel.zPosition = zPosition + 1
        addChild(connectingLabel)
    }

    func updateUIForConnection()
    {
        let waitAction = SKAction.waitForDuration(2)
        let fadeOutAction = SKAction.fadeOutWithDuration(1)
        let fadeInAction = SKAction.fadeInWithDuration(1)
        if connectionAttempted {
            connectingLabel.runAction(SKAction.sequence([waitAction, fadeOutAction])) {
                self.startButton.runAction(fadeInAction) {
                    self.startButton.userInteractionEnabled = true
                }
            }
        } else {
            startButton.runAction(fadeOutAction) {
                self.startButton.userInteractionEnabled = false
                self.connectingLabel.runAction(fadeInAction)
            }
        }
    }

    // MARK: FLBUITouchDelegate Functions
    func onTouchUp(uiNode: FLBUIElement) {
        if uiNode == startButton {
            delegate?.onStartTapped(true)
        }
    }

    func onTouchDown(uiNode: FLBUIElement) { /* NOT USED */ }
    func onTouchCancelled(uiNode: FLBUIElement) { /* NOT USED */ }
}
