//
//  Generator.swift
//  Starlight
//
//  Created by Terry on 2015-10-09.
//  Copyright © 2015 Flybits Inc. All rights reserved.
//

import SpriteKit

struct Template {
    // MARK: - Properties
    var baseTextureName: String
    var size: CGSize
    var speed: CGFloat
    var spawnRate: CFTimeInterval
    var categoryType: UInt32
    var colliderType: UInt32
    var idleAction: SKAction
    var direction: ParallaxDirection
    var animationNames: [String]?
    
    // MARK: - Computed Properties
    var spawnRateUpperOffset: UInt32 {
        return 3
    }
    var spawnRateLowerOffset: UInt32 {
        return 1
    }
    
    // MARK: - Lifecycle Methods
    init(baseTextureName: String, size: CGSize, speed: CGFloat, spawnRate: CFTimeInterval, colliderType: UInt32, idleAction: SKAction, direction: ParallaxDirection = .Left, animationNames: [String]? = nil) {
        self.baseTextureName = baseTextureName
        self.size = size
        self.speed = speed
        self.spawnRate = spawnRate
        self.categoryType = colliderType
        self.colliderType = colliderType
        self.idleAction = idleAction
        self.direction = direction
        self.animationNames = animationNames
    }
}

class GeneratorNode: SKNode {
    // MARK: - Properties
    let atlas: SKTextureAtlas
    var screenSize: CGSize
    var templates: [Int : Template]
    var timers: [Int : CFTimeInterval] = [:]

    // MARK: - Lifecycle Functions
    init(atlasName: String, templates: [Int : Template], screenSize: CGSize) {
        self.atlas = ResourceManager.atlas(named: atlasName)
        self.screenSize = screenSize
        self.templates = templates

        super.init()
        for (index, template) in templates {
            timers[index] = template.spawnRate
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func update(deltaTime: CFTimeInterval, multiplier: CGFloat) {
        for (type, timer) in timers {
            if timer < 0 {
                let template = templates[type]!
                timers[type] = template.spawnRate * randomOffset(upper: template.spawnRateUpperOffset, lower: template.spawnRateLowerOffset)
                if let element = generateElementOfType(type, withTemplate: template) {
                    addChild(element)
                }
            } else {
                timers[type]! -= deltaTime * CFTimeInterval(multiplier)
            }
        }
        for child in children {
            if let child = child as? Updatable {
                child.update(deltaTime, multiplier: multiplier)
            }
        }
    }

    internal func generateElementOfType(type: Int, withTemplate template: Template) -> SKNode? {
        // Intended to be extended by sub-classes
        return nil
    }

    private func randomOffset(upper upper: UInt32, lower: UInt32) -> CFTimeInterval {
        return ((CFTimeInterval(arc4random_uniform(upper) + lower) * 0.1) + CFTimeInterval(lower))
    }
}
