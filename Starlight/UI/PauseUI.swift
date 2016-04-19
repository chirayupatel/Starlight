//
//  PauseUI.swift
//  Starlight
//
//  Created by Terry on 2015-08-28.
//  Copyright © 2015 Flybits Inc. All rights reserved.
//

import SpriteKit

enum PauseScreenAction {
    case Close
    case Restart
    case Exit
}

protocol PauseScreenDelegate {
    func onPauseScreenClosed(pauseScreenAction: PauseScreenAction)
}

class PauseUI: FLBUIPanel, FLBUITouchDelegate {

    // MARK: - Properties
    var atlas: SKTextureAtlas
    var delegate: PauseScreenDelegate?

    // MARK: - UI Elements
    var closeButton: FLBUIButton!
    var restartButton: FLBUIButton!
    var exitButton: FLBUIButton!
    var settingsButton: FLBUIButton!

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

        // Close Button
        let closeButtonTextures = [
            FLBUIButton.State.Normal   : atlas.textureNamed("cancelbutton"),
            FLBUIButton.State.Selected : atlas.textureNamed("cancelbutton"),
            FLBUIButton.State.Disabled : atlas.textureNamed("cancelbutton")]
        
        closeButton = FLBUIButton(size: CGSizeMake(48, 48), colors: buttonColors, textures: closeButtonTextures, cornerRadius: 2)
        closeButton.anchorPoint = CGPointMake(0, 1)
        closeButton.position = CGPointMake(-size.width / 2 + 5, size.height / 2 - 5)
        closeButton.zPosition = zPosition + 1
        closeButton.delegate = self
        addChild(closeButton)

        let buttonSize = CGSizeMake(size.width, 80)
        // Restart Button
        restartButton = FLBUIButton(size: buttonSize, colors: buttonColors, textures: nil, text: "RESTART")
        restartButton.position = CGPointMake(0, 80)
        restartButton.zPosition = zPosition + 1
        restartButton.delegate = self
        addChild(restartButton)

        // Exit Button
        exitButton = FLBUIButton(size: buttonSize, colors: buttonColors, textures: nil, text: "EXIT")
        exitButton.position = CGPointZero
        exitButton.zPosition = zPosition + 1
        exitButton.delegate = self
        addChild(exitButton)

        // Settings Button
        settingsButton = FLBUIButton(size: buttonSize, colors: buttonColors, textures: nil, text: "SETTINGS")
        settingsButton.position = CGPointMake(0, -80)
        settingsButton.zPosition = zPosition + 1
        settingsButton.delegate = self
        addChild(settingsButton)
    }

    // MARK: - FLBUITouchDelegate Functions
    func onTouchUp(uiNode: FLBUIElement) {
        if uiNode == closeButton {
            delegate?.onPauseScreenClosed(.Close)
        } else if uiNode == restartButton {
            delegate?.onPauseScreenClosed(.Restart)
        }
        else if uiNode == exitButton {
            delegate?.onPauseScreenClosed(.Exit)
        }
        runAction(SKAction.fadeAlphaTo(0, duration: 0.2)) {
            self.removeFromParent()
        }
    }

    func onTouchDown(uiNode: FLBUIElement) {
    }

    func onTouchCancelled(uiNode: FLBUIElement) {
    }
}