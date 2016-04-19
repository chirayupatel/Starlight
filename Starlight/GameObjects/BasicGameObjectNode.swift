//
//  BasicGameObjectNode.swift
//  Starlight
//
//  Created by Terry on 2015-10-09.
//  Copyright © 2015 Flybits Inc. All rights reserved.
//

import SpriteKit

class BasicGameObjectNode: AnimatedSpriteNode, Collidable {
    let categoryType: UInt32
    let colliderType: UInt32
    let direction: ParallaxDirection
    var screenSize: CGSize
    var movementSpeed: CGFloat

    // MARK: - Lifecycle Functions
    init(atlas: SKTextureAtlas, template: Template, screenSize: CGSize) {
        self.categoryType = template.categoryType
        self.colliderType = template.colliderType
        self.direction = template.direction
        self.screenSize = screenSize
        self.movementSpeed = template.speed
        
        super.init(atlas: atlas, baseTextureName: template.baseTextureName, size: template.size, animationNames: template.animationNames)
        
        addPhysics()
        resetPosition()
        runAction(SKAction.repeatActionForever(template.idleAction))
        if let animationName = template.animationNames?[0] {
            doAnimation(named: animationName)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func update(deltaTime: CFTimeInterval, multiplier: CGFloat) {
        let movementDelta = movementSpeed * CGFloat(deltaTime) * multiplier
        switch direction {
        case .Up:
            position.y += movementDelta
            if position.y > screenSize.height + size.height {
                removeFromParent()
            }
        case .Down:
            position.y -= movementDelta
            if position.y < -size.height {
                removeFromParent()
            }
        case .Right:
            position.x += movementDelta
            if position.x > screenSize.width + size.width {
                removeFromParent()
            }
        case .Left:
            position.x -= movementDelta
            if position.x < -size.width {
                removeFromParent()
            }
        }
        super.update(deltaTime, multiplier: multiplier)
    }

    // MARK: - Functions
    func addPhysics() {
        let radius = max(size.width, size.height) / 2
        physicsBody = SKPhysicsBody(circleOfRadius: radius)
        physicsBody!.friction = 0
        physicsBody!.linearDamping = 0
        physicsBody!.angularDamping = 0
        physicsBody!.categoryBitMask = categoryType
        physicsBody!.contactTestBitMask = colliderType
    }

    func resetPosition() {
        let randomAmount: CGFloat = CGFloat(arc4random_uniform(6)) / 10
        let offsetAmount: CGFloat = 0.2 // 1 - (RandomAmountMax / 2)
        switch direction {
        case .Up:
            position = CGPointMake(randomAmount * screenSize.width + screenSize.width * offsetAmount, -size.height)
        case .Down:
            position = CGPointMake(randomAmount * screenSize.width + screenSize.width * offsetAmount, screenSize.height + size.height)
        case .Right:
            position = CGPointMake(-size.width, randomAmount * screenSize.height + screenSize.height * offsetAmount)
        case .Left:
            position = CGPointMake(screenSize.width + size.width, randomAmount * screenSize.height + screenSize.height * offsetAmount)
        }
    }
    
    // MARK: - Collidable Functions
    func didBeginCollisionWith(other: SKNode?) { /* SUBCLASSES TO PROVIDE */ }
    func didEndCollisionWith(other: SKNode?)   { /* SUBCLASSES TO PROVIDE */ }
}
