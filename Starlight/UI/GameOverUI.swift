//
//  GameOverUI.swift
//  Starlight
//
//  Created by Terry on 2015-09-04.
//  Copyright © 2015 Flybits Inc. All rights reserved.
//

import SpriteKit

enum GameOverAction {
    case Restart
    case Exit
}

protocol GameOverScreenDelegate {
    func onGameOverScreenClosed(result: GameOverAction)
}

class GameOverUI: FLBUIPanel, FLBUITouchDelegate {
    
    // MARK: - Properties
    var atlas: SKTextureAtlas
    var delegate: GameOverScreenDelegate?
    
    // MARK: - UI Elements
    var gameOverLabel: FLBUILabel!
    var restartButton: FLBUIButton!
    var exitButton: FLBUIButton!
    
    override var anchorPoint: CGPoint {
        didSet {
            let offsetDelta = CGPointMake(oldValue.x - anchorPoint.x, oldValue.y - anchorPoint.y)
            for child in children {
                child.position.x += offsetDelta.x * size.width
                child.position.y += offsetDelta.y * size.height
            }
        }
    }
    
    override var zPosition: CGFloat {
        didSet {
            let offsetDelta = zPosition - oldValue
            for child in children {
                child.zPosition += offsetDelta
            }
        }
    }
    
    // MARK: - Lifecycle Functions
    init(atlasNamed atlasName: String, color: SKColor, size: CGSize, baseTextureName: String? = nil) {
        self.atlas = ResourceManager.atlas(named: atlasName)
        if let baseTextureName = baseTextureName {
            super.init(texture: atlas.textureNamed(baseTextureName), color: color, size: size)
        } else {
            super.init(texture: nil, color: color, size: size)
        }
        
        layoutUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Functions
    func layoutUI() {
        let buttonColors = [
            FLBUIButton.State.Normal   : SKColor.clearColor(),
            FLBUIButton.State.Selected : SKColor(red: 1, green: 1, blue: 1, alpha: 0.2),
            FLBUIButton.State.Disabled : SKColor.clearColor()]
        
        let buttonSize = CGSizeMake(size.width, 80)
        // Game Over Label
        gameOverLabel = FLBUILabel(texture: nil, color: SKColor.clearColor(), size: buttonSize, text: "GAME OVER")
        gameOverLabel.position = CGPointMake(0, 100)
        gameOverLabel.zPosition = zPosition + 1
        addChild(gameOverLabel)

        // Restart Button
        restartButton = FLBUIButton(size: buttonSize, colors: buttonColors, textures: nil, text: "RESTART")
        restartButton.position = CGPointZero
        restartButton.zPosition = zPosition + 1
        restartButton.delegate = self
        addChild(restartButton)
        
        // Exit Button
        exitButton = FLBUIButton(size: buttonSize, colors: buttonColors, textures: nil, text: "EXIT")
        exitButton.position = CGPointMake(0, -80)
        exitButton.zPosition = zPosition + 1
        exitButton.delegate = self
        addChild(exitButton)
    }
    
    // MARK: - FLBUITouchDelegate Functions
    func onTouchUp(uiNode: FLBUIElement) {
        if uiNode == restartButton {
            delegate?.onGameOverScreenClosed(.Restart)
            runAction(SKAction.fadeAlphaTo(0, duration: 0.2)) {
                self.removeFromParent()
            }
        } else if uiNode == exitButton {
            delegate?.onGameOverScreenClosed(.Exit)
            runAction(SKAction.fadeAlphaTo(0, duration: 0.2)) {
                self.removeFromParent()
            }
        }
    }
    
    func onTouchDown(uiNode: FLBUIElement) {
    }
    
    func onTouchCancelled(uiNode: FLBUIElement) {
    }
}