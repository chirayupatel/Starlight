//
//  GameScene.swift
//  Starlight
//
//  Created by Terry on 2015-08-24.
//  Copyright (c) 2015 Flybits Inc. All rights reserved.
//

import SpriteKit
import FlybitsSDK
import HealthKit

class GameScene: SKScene, SKPhysicsContactDelegate, GameUIDelegate {

    // MARK: - Constants
    static let RainEmitterPath = NSBundle.mainBundle().pathForResource("RainEmitter", ofType: "sks")!
    static let SnowEmitterPath = NSBundle.mainBundle().pathForResource("SnowEmitter", ofType: "sks")!

    // MARK: - Properties
    var playerNode: PlayerNode!
    var enemyGeneratorNode: EnemyGeneratorNode!
    var collectibleGeneratorNode: CollectibleGeneratorNode!
    var parallaxNode: ParallaxNode!
    var contextRuleNames = [String]()
    var contextRuleSubscriptions = [false, false, false, false, false]
    var lastTouchLocation: CGPoint = CGPointZero
    var rainEmitter: SKEmitterNode!
    var snowEmitter: SKEmitterNode!
    var lastUpdateTime: CFTimeInterval = 0
    var lastAPIRequest: CFTimeInterval = 0
    var notificationQueue: NSOperationQueue!

    var zoneRequestTime: CFTimeInterval = 0

    // MARK: - UI Elements
    var gameUI: GameUI!
    
    // MARK: - Lifecyle Functions
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        self.size = view.frame.size
        self.userInteractionEnabled = true

        // TODO: (TL) TEMPORARY
        UIApplication.sharedApplication().idleTimerDisabled = true
        // TODO: (TL) TEMPORARY

        setupScene()
        registerForContextChanges()
    }
    
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
        if playerNode.healthValue < Constants.CGFloatEpsilon && !gameUI.isGamePaused {
            // Game Over!
            gameUI.isGamePaused = true
            gameUI.showGameOverScreen()
        }

        let deltaTime = lastUpdateTime > 0 ? (currentTime - lastUpdateTime) : 0
        let multiplier = gameUI.isGamePaused ? 0 : playerNode.currentSpeed

        // Update UI
        gameUI.updateHealthValue(playerNode.healthValue)
        gameUI.updateBoostValue(playerNode.boostValue)
        gameUI.update(deltaTime, multiplier: multiplier)

        // Update Game Objects
        playerNode.update(deltaTime, multiplier: multiplier)
        enemyGeneratorNode.update(deltaTime, multiplier: multiplier)
        collectibleGeneratorNode.update(deltaTime, multiplier: multiplier)
        parallaxNode.update(deltaTime, multiplier: multiplier)

        lastAPIRequest += deltaTime
        if lastAPIRequest > Constants.RuleRefreshRate && contextRuleSubscriptions.filter({ $0 } ).count > 0 {
            lastAPIRequest = 0
                ContextManager.sharedManager.refreshRules()
        }

        // Update the last time we did an update
        lastUpdateTime = currentTime

        // TODO: (TL) TEMPORARY
        if lastUpdateTime > zoneRequestTime {
            zoneRequestTime = lastUpdateTime + (10 * 60) // 10 mins
            let query = ZonesQuery(limit: 1, offset: 0)
            ZoneRequest.Query(query) { (zones, pagination, error) in
                print("Retrieved Zones")
            }.execute()
        }
        // TODO: (TL) TEMPORARY
    }
    
    // MARK: - Functions
    func setupScene() {
        physicsWorld.contactDelegate = self
/*
        backgroundColor = SKColor.clearColor()
        let backgroundGradient = SKTexture(size: size, color1: CIColor(red: 0, green: 0, blue: 0, alpha: 1), color2: CIColor(red: 1, green: 1, blue: 1, alpha: 1))
        let backgroundGradientSprite = SKSpriteNode(texture: backgroundGradient)
        backgroundGradientSprite.position = CGPointMake(size.width / 2, size.height / 2)
        addChild(backgroundGradientSprite)
 */
        
        // Add player
        addPlayerNode()
        
        // Add enemy/obstacle Layer
        addEnemyGeneratorNode()

        // Add collectible layer
        addCollectibleGeneratorNode()

        // Add backgrounds (parallax and static)
        addBackgrounds()
        
        // Add UI
        gameUI = GameUI(atlasNamed: "UI", size: size)
        gameUI.delegate = self
        addChild(gameUI)
    }
    
    func addPlayerNode() {
        let shipAtlas = ResourceManager.atlas(named: "Ship")
        playerNode = PlayerNode(atlas: shipAtlas, baseTextureName: "idle", size: CGSizeMake(50, 50), animationNames: ["boost"])
        playerNode.zPosition = 0
        playerNode.position = CGPointMake(size.width / 4, size.height / 2)
        playerNode.initialPosition = playerNode.position
        playerNode.xScale = -1
        
        addChild(playerNode)
    }
    
    func addEnemyGeneratorNode() {
        let enemySize = CGSizeMake(40, 40)
        let enemyTemplates = [
            EnemyType.Basic.rawValue   : Template(baseTextureName: "enemy_mine", size: enemySize, speed: 30, spawnRate: 10, colliderType: Utils.ColliderTypeEnemy, idleAction: Utils.BobActionSequence),
            EnemyType.Charger.rawValue : Template(baseTextureName: "enemy_flyer", size: enemySize, speed: 60, spawnRate: 20, colliderType: Utils.ColliderTypeEnemy, idleAction: Utils.BobActionSequence)]

        enemyGeneratorNode = EnemyGeneratorNode(atlasName: "Enemies", templates: enemyTemplates, screenSize: size)
        enemyGeneratorNode.zPosition = 0
        addChild(enemyGeneratorNode)
    }

    func addCollectibleGeneratorNode() {
        let collectibleSize = CGSizeMake(20, 20)
        let collectibleTemplates = [
            CollectibleType.Coin.rawValue : Template(baseTextureName: "point", size: collectibleSize, speed: 30, spawnRate: 30, colliderType: Utils.ColliderTypeCollectible, idleAction: Utils.BobActionSequence, animationNames: ["point"])]
        collectibleGeneratorNode = CollectibleGeneratorNode(atlasName: "Collectibles", templates: collectibleTemplates, screenSize: size)
        collectibleGeneratorNode.zPosition = 0
        addChild(collectibleGeneratorNode)
    }
    
    func addBackgrounds() {
        let foregroundBorderColor = SKColor(red: 208/255.0, green: 100/255.0, blue: 90/255.0, alpha: 1.0)
        let backgroundBorderColor = SKColor(red: 88/255.0, green: 45/255.0, blue: 37/255.0, alpha: 1.0)

        // Add parallax backgrounds
        let parallaxConfig = [
            // Small
            // Large
            // PLAYER
            // ENEMY
            // OBSTACLE -> large, small, float
            // Float
            // Large
            // Sky

            // Small --v //
            ParallaxNodeConfig(atlasName: "Desert", assetGroup: "ground_small", speed: 125, distance: 2, maxItems: 1, colorAdjust: SKColor.redColor(), colorAdjustPct: 0.2, oscillation: 10, oscillationSpeed: 2, elementDelay: 0.2),
            // Large --v //
            ParallaxNodeConfig(atlasName: "Desert", assetGroup: "ground_large", speed: 100, distance: 1, maxItems: 3, colorAdjust: SKColor.redColor(), colorAdjustPct: 0.1, layerOffset: 10, borderColor: foregroundBorderColor),

            // < Player >   //
            // < Enemy >    //
            // < Obstacle > // [ground_ ...]

            // Float --v //
            ParallaxNodeConfig(atlasName: "Desert", assetGroup: "ground_float", speed: 30, distance: -1, maxItems: 3, colorAdjust: SKColor.blackColor(), colorAdjustPct: 0.2, anchor: .Center, layerOffset: 50),

            // Large --v //
            ParallaxNodeConfig(atlasName: "Desert", assetGroup: "ground_large", speed: 12, distance: -2, maxItems: 3, colorAdjust: SKColor.blackColor(), colorAdjustPct: 0.4, layerOffset: 10, borderColor: backgroundBorderColor),

            // Sky --v //
            ParallaxNodeConfig(atlasName: "Skybox", assetGroup: "planet", speed: 1, distance: -3, maxItems: 1, anchor: .Top)
        ]

        parallaxNode = ParallaxNode(nodeConfigs: parallaxConfig, size: size)
        addChild(parallaxNode)
    }

    func registerForContextChanges() {
        notificationQueue = NSOperationQueue()
        notificationQueue.name = "com.flybits.starlight.notifications"
        NSNotificationCenter.defaultCenter().addObserverForName(ContextManager.Constants.ContextRuleAdded, object: nil, queue: notificationQueue) { (notification) -> Void in
            print("RULE ADDED: \(notification)")
            if let rule = (notification.userInfo as? [String:FlybitsSDK.Rule])?[ContextManager.Constants.ContextRule], ruleName = rule.name {
                self.addContextRule(ruleName)
                self.toggleContextChange(rule)
            }
        }
        NSNotificationCenter.defaultCenter().addObserverForName(ContextManager.Constants.ContextRuleChanged, object: nil, queue: notificationQueue) { (notification) -> Void in
            print("RULE CHANGED: \(notification)")
            if let rule = (notification.userInfo as? [String:FlybitsSDK.Rule])?[ContextManager.Constants.ContextRule] {
                self.toggleContextChange(rule)
            }
        }

        let typesToRead: Set<HKObjectType> = Set(arrayLiteral: HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierStepCount)!)
        HealthContextDataStore.sharedStore.authorizeHealthKitToShareTypes(nil, readTypes: typesToRead) { (authorized, error) -> Void in
            guard authorized else {
                print("[FAIL] HKHealthKit was not authorized!")
                return
            }
            print("[ OK ] HKHealthKit was authorized!")

            NSOperationQueue.mainQueue().addOperationWithBlock {
                let _ = ContextManager.sharedManager.registerSDKContextProvider(.HealthKitSteps, priority: .Any, pollFrequency: 5 * 60, uploadFrequency: 5 * 60)
            }
        }
        let _ = ContextManager.sharedManager.registerSDKContextProvider(.Network, priority: .Any, pollFrequency: 5 * 60, uploadFrequency: 5 * 60)
        let _ = ContextManager.sharedManager.registerSDKContextProvider(.Carrier, priority: .Any, pollFrequency: 12 * 60 * 60, uploadFrequency: 12 * 60 * 60)
        let _ = ContextManager.sharedManager.registerSDKContextProvider(.Language, priority: .Any, pollFrequency: 12 * 60 * 60, uploadFrequency: 12 * 60 * 60)
        let _ = ContextManager.sharedManager.registerSDKContextProvider(.Availability, priority: .Any, pollFrequency: 12 * 60 * 60, uploadFrequency: 12 * 60 * 60)

        ContextManager.sharedManager.startDataPolling()
    }

    func addContextRule(ruleName: String) {
        if !contextRuleNames.contains(ruleName) {
            contextRuleNames.append(ruleName)

            let lowercaseRuleName = ruleName.lowercaseString
            for (contextIndex, selected) in contextRuleSubscriptions.enumerate() {
                let rulePrefix = Constants.contextIndexToRulePrefix(contextIndex)
                if lowercaseRuleName.hasPrefix(rulePrefix) {
                    ContextManager.sharedManager.updateRuleSubscription(ruleName, subscribe: selected)
                }
            }
        }
    }

    func toggleContextChange(rule: FlybitsSDK.Rule) {
        if rule.lastResult != nil && !rule.lastResult! {
            return // TODO: (TL) Ignore rules that are false -- no, should this toggle things?
        }

        if let ruleName = rule.name {
            let ruleIndex = Constants.rulePrefixToContextIndex(Constants.Rules.Boost)
            guard ruleIndex >= 0 && ruleIndex < contextRuleSubscriptions.count else {
                return // Invalid rule or we're not using it yet
            }
            if ruleName.hasPrefix(Constants.Rules.Boost) && contextRuleSubscriptions[ruleIndex] {
                // TODO: (TL) TEMPORARY --v
                if ruleName.hasSuffix("5") || ruleName.hasSuffix("3") || ruleName.hasSuffix("1") {
                    parallaxNode.switchAtlas("Tundra")
                    toggleRain(false)
                    toggleSnow(true)
                } else {
                    parallaxNode.switchAtlas("Lush")
                    toggleSnow(false)
                    toggleRain(true)
                }
                // TODO: (TL) TEMPORARY --^
                playerNode.updateBoost(ruleName)
            } else if ruleName.hasPrefix(Constants.Rules.Location) && contextRuleSubscriptions[ruleIndex] {
                // TODO: (TL) Update Adding city?
            } else if ruleName.hasPrefix(Constants.Rules.Weather) && contextRuleSubscriptions[ruleIndex] {
                let newAtlasName = ruleName.componentsSeparatedByString(" ").last!
                parallaxNode.switchAtlas(newAtlasName)
                if newAtlasName == "Tundra" {
                    toggleRain(false)
                    toggleSnow(true)
                } else if newAtlasName == "Lush" {
                    toggleSnow(false)
                    toggleRain(true)
                } else {
                    toggleRain(false)
                    toggleSnow(false)
                }
            }
        }
    }

    func toggleRain(isRaining: Bool) {
        if isRaining {
            if rainEmitter == nil {
                rainEmitter = NSKeyedUnarchiver.unarchiveObjectWithFile(GameScene.RainEmitterPath) as! SKEmitterNode
                rainEmitter.particlePositionRange = CGVector(dx: size.width, dy: rainEmitter.particlePositionRange.dy)
                rainEmitter.position = CGPointMake(size.width / 2, size.height)
                rainEmitter.zPosition = 70
            }
            rainEmitter.paused = false
            addChild(rainEmitter)
        } else {
            if rainEmitter != nil && rainEmitter.parent != nil {
                rainEmitter.removeFromParent()
                rainEmitter = nil
            }
        }
    }

    func toggleSnow(isSnowing: Bool) {
        if isSnowing {
            if snowEmitter == nil {
                snowEmitter = NSKeyedUnarchiver.unarchiveObjectWithFile(GameScene.SnowEmitterPath) as! SKEmitterNode
                snowEmitter.particlePositionRange = CGVector(dx: size.width, dy: snowEmitter.particlePositionRange.dy)
                snowEmitter.position = CGPointMake(size.width / 2, size.height)
                snowEmitter.zPosition = 70
            }
            snowEmitter.paused = false
            addChild(snowEmitter)
        } else {
            if snowEmitter != nil && snowEmitter.parent != nil {
                snowEmitter.removeFromParent()
                snowEmitter = nil
            }
        }
    }

    // MARK: - User Interaction Functions
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if gameUI.hasOverlay() {
            return
        }
        
        for touch in touches {
            let location = touch.locationInNode(self)
            if location.x > gameUI.boostStartThreshold {
                    playerNode.boost()
            } else if location.x > gameUI.movementEndThreshold && location.x < gameUI.dodgeEndThreshold {
                // TODO: (TL) Dodge animations
                if location.y < size.height / 2 { // Dodge down
                    onDodgeTapped(true, direction: .Up)
                } else { // Dodge up
                    onDodgeTapped(true, direction: .Down)
                }
            } else if location.x < gameUI.movementEndThreshold {
                lastTouchLocation = location
            }
        }
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if gameUI.hasOverlay() {
            return
        }
        
        for touch in touches {
            let location = touch.locationInNode(self)
            if location.x > gameUI.dodgeEndThreshold && location.x < gameUI.boostStartThreshold && playerNode.isBoosting {
                playerNode.boost(false)
            } else if location.x > gameUI.dodgeEndThreshold && location.x > gameUI.boostStartThreshold && !playerNode.isBoosting {
                playerNode.boost()
            }
            
            if location.x < gameUI.movementEndThreshold {
                let movementDelta = CGPointMake(lastTouchLocation.x - location.x, lastTouchLocation.y - location.y)
                onMovement(movementDelta)
                lastTouchLocation = location
            }
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if gameUI.hasOverlay() {
            return
        }
        
        for touch in touches {
            let location = touch.locationInNode(self)
            if location.x > gameUI.boostStartThreshold {
                playerNode.boost(false)
            }
        }
    }
    
    override func touchesCancelled(touches: Set<UITouch>?, withEvent event: UIEvent?) {
        if gameUI.hasOverlay() {
            return
        }
        
        if let touches = touches {
            for touch in touches {
                let location = touch.locationInNode(self)
                if location.x > gameUI.boostStartThreshold {
                    playerNode.boost(false)
                }
            }
        }
    }

    // MARK: - GameUIDelegate Functions
    func onDodgeTapped(state: Bool, direction: GameUI.DodgeDirection) {
        // TODO: (TL) ...
    }

    func onMovement(movementDelta: CGPoint) {
        var newYPosition = playerNode.position.y - movementDelta.y
        if newYPosition < playerNode.size.height / 2 {
            newYPosition = playerNode.size.height / 2
        } else if newYPosition > size.height - playerNode.size.height / 2 {
            newYPosition = size.height - playerNode.size.height / 2
        }
        playerNode.position.y = newYPosition
    }

    func onRestartSelected() {
        let gameScene = GameScene(fileNamed: "GameScene")!
        let transition = SKTransition.moveInWithDirection(.Up, duration: 0.5)
        view?.presentScene(gameScene, transition: transition)
    }

    func onExitSelected() {
        let menuScene = MenuScene(fileNamed: "MenuScene")!
        let transition = SKTransition.doorsCloseVerticalWithDuration(0.5)

        ContextManager.sharedManager.stopDataPolling()
        menuScene.disconnectFromFlybits()
        view?.presentScene(menuScene, transition: transition)
    }

    func onContextToggled(contextIndex: Int, selected: Bool) {
        contextRuleSubscriptions[contextIndex] = selected

        if Session.sharedInstance.isConnected {
            let rulePrefix = Constants.contextIndexToRulePrefix(contextIndex)
            let ruleNames = contextRuleNames.filter({ $0.lowercaseString.hasPrefix(rulePrefix) })
            for ruleName in ruleNames {
                ContextManager.sharedManager.updateRuleSubscription(ruleName, subscribe: selected)
            }
        } else { // Fake it
            let rule = Rule()
            if contextIndex == Constants.Context.BoostIndex {
                rule.name = "\(Constants.Rules.Boost) 5"
            } else if contextIndex == Constants.Context.WeatherIndex {
                rule.name = "\(Constants.Rules.Weather) Tundra"
            }
            let userInfo: [String:AnyObject] = [
                ContextManager.Constants.ContextRule : rule
            ]
            NSNotificationCenter.defaultCenter().postNotificationName(ContextManager.Constants.ContextRuleChanged, object: nil, userInfo: userInfo)
        }
    }

    // MARK: - SKPhysicsContactDelegate Functions
    func didBeginContact(contact: SKPhysicsContact) {
        if let nodeA = contact.bodyA.node {
            (nodeA as? Collidable)?.didBeginCollisionWith(contact.bodyB.node)
        }
        if let nodeB = contact.bodyB.node {
            (nodeB as? Collidable)?.didBeginCollisionWith(contact.bodyA.node)
        }
    }
    
    func didEndContact(contact: SKPhysicsContact) {
        if let nodeA = contact.bodyA.node {
            (nodeA as? Collidable)?.didEndCollisionWith(contact.bodyB.node)
        }
        if let nodeB = contact.bodyB.node {
            (nodeB as? Collidable)?.didEndCollisionWith(contact.bodyA.node)
        }
    }
}
