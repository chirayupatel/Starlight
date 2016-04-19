//
//  ContextUI.swift
//  Starlight
//
//  Created by Terry on 2015-08-28.
//  Copyright © 2015 Flybits Inc. All rights reserved.
//

import SpriteKit

protocol ContextScreenDelegate {
    func onContextToggled(contextIndex: Int, selected: Bool)
    func onContextScreenClosed()
}

class ContextUI: FLBUIPanel, FLBUITouchDelegate {
    
    // MARK: - Properties
    var atlas: SKTextureAtlas
    var delegate: ContextScreenDelegate?

    // MARK: - UI Elements
    var closeButton: FLBUIButton!
    var titleLabel: FLBUILabel!
    var contextButtons: [FLBUIButton] = []
    let contexts: [String] = [Constants.Context.Time, Constants.Context.Boost, Constants.Context.Location, Constants.Context.Weather, Constants.Context.Gyro]

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

        // Active Context Label
        titleLabel = FLBUILabel(texture: nil, color: SKColor.clearColor(), size: CGSizeMake(size.width * 0.8, 25), text: "Active Context")
        titleLabel.anchorPoint = CGPointMake(0.5, 1)
        titleLabel.position = CGPointMake(0, size.height / 2 - 20)
        titleLabel.fontSize = 18
        titleLabel.zPosition = zPosition + 1
        addChild(titleLabel)

        let buttonSize = CGSizeMake(50, 50) // Inset on each size = button width / 2
        let widthBetweenButtons = (size.width - buttonSize.width) / CGFloat(contexts.count)
        let initialOffset = widthBetweenButtons / 2 + buttonSize.width / 2
        // Context Buttons
        for (index, context) in contexts.enumerate() {
            let textures = [
                FLBUIButton.State.Normal   : atlas.textureNamed("\(context)_dark"),
                FLBUIButton.State.Selected : atlas.textureNamed(context),
                FLBUIButton.State.Disabled : atlas.textureNamed(context)]

            let contextButton = FLBUIButton(size: buttonSize, colors: nil, textures: textures, cornerRadius: 2)
            contextButton.position = CGPointMake(-size.width / 2 + (initialOffset + CGFloat(index) * widthBetweenButtons), 0)
            contextButton.zPosition = zPosition + 1
            contextButton.isToggle = true
            contextButton.delegate = self
            addChild(contextButton)

            contextButtons.append(contextButton)
        }
    }
    
    // MARK: - FLBUITouchDelegate Functions
    func onTouchUp(uiNode: FLBUIElement) {
        if uiNode == closeButton {
            delegate?.onContextScreenClosed()
            runAction(SKAction.fadeAlphaTo(0, duration: 0.2)) {
                self.removeFromParent()
            }
        } else if let buttonNode = uiNode as? FLBUIButton {
            if let contextIndex = contextButtons.indexOf(buttonNode) {
                delegate?.onContextToggled(contextIndex, selected: buttonNode.isSelected)
            }
        }
    }
    
    func onTouchDown(uiNode: FLBUIElement) {
    }
    
    func onTouchCancelled(uiNode: FLBUIElement) {
    }
}