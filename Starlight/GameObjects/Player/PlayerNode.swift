//
//  PlayerNode.swift
//  Starlight
//
//  Created by Terry on 2015-08-24.
//  Copyright © 2015 Flybits Inc. All rights reserved.
//

import SpriteKit

class PlayerNode: AnimatedSpriteNode, Collidable {
    // MARK: - Constants
    static let EmitterPath = NSBundle.mainBundle().pathForResource("PropulsionEmitter", ofType: "sks")!

    struct BoostRecovery {
        static let Low: CGFloat      = 0.04
        static let Medium: CGFloat   = 0.1
        static let High: CGFloat     = 0.16
        static let VeryHigh: CGFloat = 0.2
    }

    struct BoostDepletion {
        static let Low: CGFloat      = 0.1
        static let Medium: CGFloat   = 0.2
        static let High: CGFloat     = 0.32
        static let VeryHigh: CGFloat = 0.4
    }

    // MARK: - Properties
    var shield: SKSpriteNode!
    var jetEmitters: [SKEmitterNode] = []
    var currentSpeed: CGFloat = 1
    var initialPosition: CGPoint = CGPointZero
    var targetPosition: CGPoint?
    var healthValue: CGFloat
    var movementSpeed: CGFloat = 1
    let boostMax: CGFloat
    var boostValue: CGFloat
    var boostDepletionRate: CGFloat
    var boostRecoveryRate: CGFloat
    var isBoosting: Bool {
        return self.currentSpeed > 1
    }

    // MARK: - Lifecycle Functions
    override init(atlas: SKTextureAtlas, baseTextureName: String, size: CGSize, animationNames: [String]? = nil) {
        self.healthValue = 4
        self.boostMax = 100
        self.boostValue = self.boostMax
        self.boostDepletionRate = BoostDepletion.Medium
        self.boostRecoveryRate = BoostRecovery.Medium

        super.init(atlas: atlas, baseTextureName: baseTextureName, size: size, animationNames: animationNames)
        self.name = Constants.Player

        addPhysics()
        addShield(atlas.textureNamed("shield"))
        addJets()

        runAction(SKAction.repeatActionForever(Utils.BobActionSequence))
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func update(deltaTime: CFTimeInterval, multiplier: CGFloat) {
        super.update(deltaTime, multiplier: multiplier)
        paused = multiplier < Constants.CGFloatEpsilon

        if isBoosting && boostValue > Constants.CGFloatEpsilon {
            boostValue = max(0, boostValue - boostDepletionRate)
        } else if isBoosting {
            boost(false)
        } else if !isBoosting && boostValue < boostMax {
            boostValue = min(boostMax, boostValue + boostRecoveryRate)
        }
/*
        if targetPosition == nil {
            return
        }

        let movementDelta = movementSpeed * CGFloat(deltaTime) * multiplier
        let distance = targetPosition!.y - position.y
        if abs(distance) < movementDelta {
            position.y = targetPosition!.y
            targetPosition = nil
        } else {
            position.y += distance * CGFloat(deltaTime) * multiplier
        }
 */
    }

    // MARK: - Functions
    func updateBoost(boostTrigger: String) {
        if boostTrigger.hasSuffix("1") {
            boostDepletionRate = PlayerNode.BoostDepletion.VeryHigh
            boostRecoveryRate = PlayerNode.BoostRecovery.Low
        } else if boostTrigger.hasSuffix("2") {
            boostDepletionRate = PlayerNode.BoostDepletion.High
            boostRecoveryRate = PlayerNode.BoostRecovery.Medium
        } else if boostTrigger.hasSuffix("3") {
            boostDepletionRate = PlayerNode.BoostDepletion.Medium
            boostRecoveryRate = PlayerNode.BoostRecovery.Medium
        } else if boostTrigger.hasSuffix("4") {
            boostDepletionRate = PlayerNode.BoostDepletion.Medium
            boostRecoveryRate = PlayerNode.BoostRecovery.High
        } else if boostTrigger.hasSuffix("5") {
            boostDepletionRate = PlayerNode.BoostDepletion.Low
            boostRecoveryRate = PlayerNode.BoostRecovery.VeryHigh
        }
    }
    func boost(start: Bool = true) {
        if start && boostValue < Constants.CGFloatEpsilon {
            return
        }

        if !hasAnimation(named: "boost") {
            return
        }

        if (start && animationDictionary["boost"]!.atStart) ||
            (!start && !animationDictionary["boost"]!.atStart){
                currentSpeed = isBoosting ? 1 : 2
                speed = isBoosting ? 2 : 1
                doAnimation(named: "boost")
        }
    }

    override func doAnimation(named animationName: String, completion: ((atStart: Bool) -> Void)? = nil) {
        if !hasAnimation(named: animationName) {
            return
        }

        animationDictionary[animationName]!.animate {
            if self.animationDictionary[animationName]!.atStart {
                self.jetEmitters[1].runAction(SKAction.fadeOutWithDuration(1))
                self.jetEmitters[2].runAction(SKAction.fadeOutWithDuration(1))
            } else {
                if self.jetEmitters[1].parent == nil {
                    self.addChild(self.jetEmitters[1])
                }
                if self.jetEmitters[2].parent == nil {
                    self.addChild(self.jetEmitters[2])
                }
                self.jetEmitters[1].runAction(SKAction.fadeInWithDuration(1))
                self.jetEmitters[2].runAction(SKAction.fadeInWithDuration(1))
            }
            if let completion = completion {
                completion(atStart: self.animationDictionary[animationName]!.atStart)
            }
        }
    }

    override func moveToParent(parent: SKNode) {
        super.moveToParent(parent)
        for jetEmitter in jetEmitters {
            jetEmitter.targetNode = parent
        }
    }
    private func addPhysics() {
        let radius = max(size.width, size.height) / 2
        physicsBody = SKPhysicsBody(circleOfRadius: radius)
        physicsBody!.friction = 0
        physicsBody!.linearDamping = 0
        physicsBody!.angularDamping = 0
        physicsBody!.categoryBitMask = Utils.ColliderTypePlayer
        physicsBody!.contactTestBitMask = Utils.ColliderTypeEnemy | Utils.ColliderTypeCollectible
    }

    private func addShield(texture: SKTexture) {
        shield = SKSpriteNode(texture: texture, color: SKColor.clearColor(), size: size * 1.5)
        shield.zPosition = 2
        addChild(shield)
    }

    private func createJetEmitterAtPostion(position: CGPoint, withZIndex zPosition: CGFloat) -> SKEmitterNode {
        let jetEmitter = NSKeyedUnarchiver.unarchiveObjectWithFile(PlayerNode.EmitterPath) as! SKEmitterNode
        jetEmitter.position = position
        jetEmitter.zPosition = zPosition

        return jetEmitter
    }

    private func addJets() {
        let jetEmitter = createJetEmitterAtPostion(CGPointMake(11, 7), withZIndex: 1)
        
        jetEmitters.append(jetEmitter)
        jetEmitters.append(createJetEmitterAtPostion(CGPointMake(20,  13), withZIndex: 3))
        jetEmitters.append(createJetEmitterAtPostion(CGPointMake(20, -10), withZIndex: 3))
        
        addChild(jetEmitter)
    }

    private func handleCollectiblePickup(collectible: BasicGameObjectNode) {
        print("Picked up coin!")
        collectible.runAction(SKAction.fadeOutWithDuration(0.1)) {
            collectible.removeFromParent()
        }
    }

    private func handleEnemyCollision(enemy: EnemyNode) {
        let flickerOut = SKAction.fadeAlphaTo(0.1, duration: 0.2)
        let flickerIn  = SKAction.fadeAlphaTo(1.0, duration: 0.2)
        
        // healthValue -= 1 // TODO: (TL) Re-enable this
        if healthValue < 1 {
            healthValue = 0.1
            runAction(flickerOut) {
                self.removeFromParent()
                self.healthValue = 0
            }
        } else if healthValue < 2 {
            shield.runAction(flickerOut) {
                self.shield.removeFromParent()
            }
        }
        if shield.parent != nil {
            shield.runAction(SKAction.sequence([flickerOut, flickerIn, flickerOut, flickerIn])) {
                self.runAction(SKAction.moveByX(self.initialPosition.x - self.position.x, y: 0, duration: 1.0))
            }
        }
    }

    // MARK: - Collidable Functions
    func didBeginCollisionWith(other: SKNode?) {
        guard let other = other, otherPhysicsBody = other.physicsBody else {
            return
        }
        if (otherPhysicsBody.categoryBitMask & Utils.ColliderTypeEnemy) > 0 {
            handleEnemyCollision(other as! EnemyNode)
        } else if (otherPhysicsBody.categoryBitMask & Utils.ColliderTypeCollectible) > 0 {
            handleCollectiblePickup(other as! BasicGameObjectNode)
        }
    }
    
    func didEndCollisionWith(other: SKNode?) { /* NOT CURRENTLY USED */ }
}
