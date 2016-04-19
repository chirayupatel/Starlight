//
//  GameUI.swift
//  Starlight
//
//  Created by Terry on 2015-08-27.
//  Copyright © 2015 Flybits Inc. All rights reserved.
//

import SpriteKit

protocol GameUIDelegate {
    func onDodgeTapped(state: Bool, direction: GameUI.DodgeDirection)
    func onMovement(movementDelta: CGPoint)
    func onRestartSelected()
    func onExitSelected()
    func onContextToggled(contextIndex: Int, selected: Bool)
}

class GameUI: FLBUIElement, Updatable, FLBUITouchDelegate, PauseScreenDelegate, ContextScreenDelegate, GameOverScreenDelegate {

    // MARK: - Enums
    enum DodgeDirection {
        case Up
        case Down
    }

    // MARK: - Constants
    static let ZPosition: CGFloat = 1000

    // MARK: - Properties
    let atlas: SKTextureAtlas
    let size: CGSize
    let movementEndThreshold: CGFloat
    let dodgeEndThreshold: CGFloat
    let boostStartThreshold: CGFloat
    var delegate: GameUIDelegate?
    var lastTouchLocation: CGPoint = CGPointZero
    var isGamePaused = false
    var score: UInt = 0
    let overlayBackgroundColor = SKColor(red: 0, green: 0, blue: 0, alpha: 0.8)

    // MARK: - UI Elements
    var healthBar: FLBUIProgressBar!
    var boostBar: FLBUIProgressBar!
    var scoreLabel: FLBUILabel!
    var movementHint: SKSpriteNode!
    var boostHint: SKSpriteNode!
    var contextMenuButton: FLBUIButton!
    var contextMenu: ContextUI!
    var pauseMenuButton: FLBUIButton!
    var pauseMenu: PauseUI!
    var gameOverUI: GameOverUI!

    // MARK: - Lifecycle Functions
    init(atlasNamed atlasName: String, size: CGSize) {
        self.atlas = ResourceManager.atlas(named: atlasName)
        self.size = size
        self.movementEndThreshold = size.width / 4
        self.dodgeEndThreshold = size.width / 2
        self.boostStartThreshold = movementEndThreshold * 3

        super.init()
        layoutUI()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func update(deltaTime: CFTimeInterval, multiplier: CGFloat) {
        if !isGamePaused {
            score += UInt(round(1 * multiplier))
            scoreLabel.textLabel.text = "\(score) pts"
        }
    }

    // MARK: - Functions
    func hasOverlay() -> Bool {
        return ((pauseMenu != nil && pauseMenu.parent != nil) ||
            (contextMenu != nil && contextMenu.parent != nil) ||
            (gameOverUI != nil && gameOverUI.parent != nil))
    }

    func useBoost(amount: CGFloat) {
        boostBar.updateProgress(amount)
    }

    func updateBoostValue(boostValue: CGFloat) {
        let delta = boostValue - boostBar.progress
        boostBar.updateProgress(delta)
    }

    func updateHealthValue(healthValue: CGFloat) {
        let delta = healthValue - healthBar.progress
        healthBar.updateProgress(delta)
    }

    private func layoutUI() {
        userInteractionEnabled = true
        zPosition = GameUI.ZPosition

        let barSize = CGSizeMake(200, 26)

        // Health Bar
        healthBar = FLBUIProgressBar(bgTexture: atlas.textureNamed("healthunderlay"), fgTexture: atlas.textureNamed("healthoverlay"), size: barSize, startValue: 0, finishValue: 3, startsCompleted: true)
        healthBar.anchorPoint = CGPointMake(0.5, 1)
        healthBar.position = CGPointMake(size.width / 2 - 153, size.height + 2)
        healthBar.zPosition = zPosition + 1
        addChild(healthBar)

        // Boost Bar
        boostBar = FLBUIProgressBar(bgTexture: atlas.textureNamed("boostunderlay"), fgTexture: atlas.textureNamed("boostoverlay"), size: barSize, startValue: 0, finishValue: 100, startsCompleted: true, direction: .Left)
        boostBar.anchorPoint = CGPointMake(0.5, 1)
        boostBar.position = CGPointMake(size.width / 2 + 153, size.height + 2)
        boostBar.zPosition = zPosition + 1
        addChild(boostBar)

        // Score Bar
        scoreLabel = FLBUILabel(texture: atlas.textureNamed("scoreboard"), color: SKColor.clearColor(), size: CGSizeMake(160, 40), text: "0 pts")
        scoreLabel.anchorPoint = CGPointMake(0.5, 1)
        scoreLabel.position = CGPointMake(size.width / 2, size.height)
        scoreLabel.zPosition = zPosition + 1003
        scoreLabel.fontName = Constants.Font
        scoreLabel.fontSize = 18
        scoreLabel.verticalAlignmentMode = .Center
        scoreLabel.horizontalAlignmentMode = .Right
        scoreLabel.textLabel.position.x += 40
        scoreLabel.textLabel.position.y += 1
        addChild(scoreLabel)

        let buttonSize = CGSizeMake(48, 48)
        let buttonColors = [
            FLBUIButton.State.Normal   : SKColor(red: 0, green: 0, blue: 0, alpha: 0.1),
            FLBUIButton.State.Selected : SKColor(red: 0, green: 0, blue: 0, alpha: 0.1),
            FLBUIButton.State.Disabled : SKColor(red: 0, green: 0, blue: 0, alpha: 0.1)]

        // Flybits Menu Button
        let contextButtonTextures = [
            FLBUIButton.State.Normal   : atlas.textureNamed("contextbutton"),
            FLBUIButton.State.Selected : atlas.textureNamed("contextbutton_glow"),
            FLBUIButton.State.Disabled : atlas.textureNamed("contextbutton")]

        contextMenuButton = FLBUIButton(size: buttonSize, colors: buttonColors, textures: contextButtonTextures, cornerRadius: 2)
        contextMenuButton.anchorPoint = CGPointMake(0, 1)
        contextMenuButton.position = CGPointMake(0, size.height)
        contextMenuButton.zPosition = zPosition + 1
        contextMenuButton.delegate = self
        addChild(contextMenuButton)

        // Pause Menu Button
        let pauseButtonTextures = [
            FLBUIButton.State.Normal   : atlas.textureNamed("pausebutton"),
            FLBUIButton.State.Selected : atlas.textureNamed("pausebutton_glow"),
            FLBUIButton.State.Disabled : atlas.textureNamed("pausebutton")]
        
        pauseMenuButton = FLBUIButton(size: buttonSize, colors: buttonColors, textures: pauseButtonTextures, cornerRadius: 2)
        pauseMenuButton.anchorPoint = CGPointMake(1, 1)
        pauseMenuButton.position = CGPointMake(size.width, size.height)
        pauseMenuButton.zPosition = zPosition + 1
        pauseMenuButton.delegate = self
        addChild(pauseMenuButton)

        // Tutorial Areas
        let textureSize = CGSizeMake(movementEndThreshold, size.height)

        let moveGradientStart = CIColor(red: 0, green: 0, blue: 0, alpha: 0.0)
        let moveGradientEnd = CIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
        let moveTexture = SKTexture(size: textureSize, color1: moveGradientStart, color2: moveGradientEnd, direction: .Left)
        movementHint = SKSpriteNode(texture: moveTexture, color: SKColor.clearColor(), size: textureSize)
        movementHint.position = CGPointMake(textureSize.width / 2, size.height / 2)

        let movementTutorialSize = CGSizeMake(56, 320)
        let movementTutorial = SKSpriteNode(texture: atlas.textureNamed("tutorial_arrow"), color: SKColor.clearColor(), size: movementTutorialSize)
        movementHint.addChild(movementTutorial)

        addChild(movementHint)
/*
        let dodgeUpStrokeColor = SKColor(red: 1, green: 1, blue: 0, alpha: 0.8)
        let dodgeUpFillColor = SKColor(red: 1, green: 1, blue: 0, alpha: 0.1)
        let dodgeUpHighlight = Utils.RectShapeNode(CGRectMake(movementEndThreshold, 0, movementEndThreshold, size.height / 2), strokeColor: dodgeUpStrokeColor, fillColor: dodgeUpFillColor)
        // addChild(dodgeUpHighlight)
        
        let dodgeDownStrokeColor = SKColor(red: 1, green: 153/255.0, blue: 51/255.0, alpha: 0.8)
        let dodgeDownFillColor = SKColor(red: 1, green: 153/255.0, blue: 51/255.0, alpha: 0.1)
        let dodgeDownHighlight = Utils.RectShapeNode(CGRectMake(movementEndThreshold, size.height / 2, movementEndThreshold, size.height / 2), strokeColor: dodgeDownStrokeColor, fillColor: dodgeDownFillColor)
        // addChild(dodgeDownHighlight)
 */
        let boostGradientStart = CIColor(red: 0, green: 237/255.0, blue: 1.0, alpha: 0.5)
        let boostGradientEnd = CIColor(red: 0, green: 237/255.0, blue: 1.0, alpha: 0.0)
        let boostTexture = SKTexture(size: textureSize, color1: boostGradientStart, color2: boostGradientEnd, direction: .Left)
        boostHint = SKSpriteNode(texture: boostTexture, color: SKColor.clearColor(), size: textureSize)
        boostHint.position = CGPointMake(size.width - textureSize.width / 2, size.height / 2)

        let boostTutorial = SKSpriteNode(texture: atlas.textureNamed("tutorial_turbo"), color: SKColor.clearColor(), size: movementTutorialSize)
        boostHint.addChild(boostTutorial)

        addChild(boostHint)

        showHotZoneHints()
    }

    func showHotZoneHints() {
        let fadeInAction = SKAction.fadeInWithDuration(1.0)
        let fadeOutAction = SKAction.fadeOutWithDuration(1.0)
        let waitAction = SKAction.waitForDuration(2)
        movementHint.runAction(SKAction.sequence([fadeInAction, waitAction, fadeOutAction]))
        boostHint.runAction(SKAction.sequence([fadeInAction, waitAction, fadeOutAction]))
    }

    func showGameOverScreen() {
        isGamePaused = true
        if gameOverUI == nil {
            gameOverUI = GameOverUI(atlasNamed: "UI", color: overlayBackgroundColor, size: size)
            gameOverUI.position = CGPointMake(size.width / 2, size.height / 2)
            gameOverUI.zPosition = zPosition + 5000
            gameOverUI.delegate = self
        }
        gameOverUI.alpha = 0
        addChild(gameOverUI!)
        gameOverUI.runAction(SKAction.fadeAlphaTo(1, duration: 0.2))
        contextMenuButton.runAction(SKAction.fadeOutWithDuration(0.2))
        pauseMenuButton.runAction(SKAction.fadeOutWithDuration(0.2))
    }

    // MARK: - User Interaction
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        parent?.touchesBegan(touches, withEvent: event)
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        parent?.touchesMoved(touches, withEvent: event)
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        parent?.touchesEnded(touches, withEvent: event)
    }
    
    override func touchesCancelled(touches: Set<UITouch>?, withEvent event: UIEvent?) {
        parent?.touchesCancelled(touches, withEvent: event)
    }

    // MARK: - TouchDelegate Functions
    func onTouchDown(uiNode: FLBUIElement) {
    }

    func onTouchUp(uiNode: FLBUIElement) {
        if uiNode == pauseMenuButton {
            isGamePaused = true
            if pauseMenu == nil {
                pauseMenu = PauseUI(atlasNamed: "UI", color: overlayBackgroundColor, size: size)
                pauseMenu.position = CGPointMake(size.width / 2, size.height / 2)
                pauseMenu.zPosition = zPosition + 5000
                pauseMenu.delegate = self
            }
            pauseMenu.alpha = 0
            addChild(pauseMenu)
            pauseMenu.runAction(SKAction.fadeAlphaTo(1, duration: 0.2))
            contextMenuButton.runAction(SKAction.fadeOutWithDuration(0.2))
            pauseMenuButton.runAction(SKAction.fadeOutWithDuration(0.2))
        } else if uiNode == contextMenuButton {
            isGamePaused = true
            if contextMenu == nil {
                contextMenu = ContextUI(atlasNamed: "UI", color: overlayBackgroundColor, size: size)
                contextMenu.position = CGPointMake(size.width / 2, size.height / 2)
                contextMenu.zPosition = zPosition + 5000
                contextMenu.delegate = self
            }
            contextMenu.alpha = 0
            addChild(contextMenu)
            contextMenu.runAction(SKAction.fadeAlphaTo(1, duration: 0.2))
            contextMenuButton.runAction(SKAction.fadeOutWithDuration(0.2))
            pauseMenuButton.runAction(SKAction.fadeOutWithDuration(0.2))
        }
    }

    func onTouchCancelled(uiNode: FLBUIElement) {
    }

    // MARK: - PauseScreenDelegate Functions
    func onPauseScreenClosed(action: PauseScreenAction) {
        isGamePaused = false
        switch action {
        case .Restart:
            delegate?.onRestartSelected()
        case .Exit:
            delegate?.onExitSelected()
        default:
            break // Do nothing for .Close
        }
        contextMenuButton.runAction(SKAction.fadeInWithDuration(0.2))
        pauseMenuButton.runAction(SKAction.fadeInWithDuration(0.2))
        showHotZoneHints()
    }

    // MARK: - ContextScreenDelegate Functions
    func onContextToggled(contextIndex: Int, selected: Bool) {
        delegate?.onContextToggled(contextIndex, selected: selected)
    }
    func onContextScreenClosed() {
        isGamePaused = false
        contextMenuButton.runAction(SKAction.fadeInWithDuration(0.2))
        pauseMenuButton.runAction(SKAction.fadeInWithDuration(0.2))
        showHotZoneHints()
    }

    // MARK: - GameOverScreenDelegate Functions
    func onGameOverScreenClosed(action: GameOverAction) {
        switch action {
        case .Restart:
            delegate?.onRestartSelected()
        case .Exit:
            delegate?.onExitSelected()
        }
        contextMenuButton.runAction(SKAction.fadeInWithDuration(0.2))
        pauseMenuButton.runAction(SKAction.fadeInWithDuration(0.2))
    }
}