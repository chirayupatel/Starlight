//
//  ParallaxNode.swift
//  Starlight
//
//  Created by Terry on 2015-08-24.
//  Copyright © 2015 Flybits Inc. All rights reserved.
//

import SpriteKit

class ParallaxLayerNode: SKNode, Updatable {
    static let LayersPerNode:CGFloat = 5

    // MARK: - Properties
    let size: CGSize
    let parallaxConfig: ParallaxNodeConfig
    var background: SKSpriteNode?
    var textures: [SKTexture]
    var timeToNextItem: CFTimeInterval = 0
    var averageDeltaTime: CFTimeInterval = 1/60.0
    var totalOscillationOffset: CGFloat = 0
    var oscillationDirection: CGFloat = 1
    var oscillationOffset: CGFloat = 0
    var oscillation: CGFloat

    var nextAtlas: SKTextureAtlas? {
        didSet {
            if let nextAtlas = nextAtlas {
                textures = ResourceManager.texturesFromAtlas(nextAtlas, named: parallaxConfig.assetGroup)
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
    init(textures: [SKTexture], size: CGSize, parallaxConfig: ParallaxNodeConfig) {
        self.textures = textures
        self.size = size
        self.parallaxConfig = parallaxConfig
        if parallaxConfig.anchor == .Center {
            self.oscillation = parallaxConfig.oscillation / 2
        } else {
            self.oscillation = parallaxConfig.oscillation
        }

        super.init()
        if parallaxConfig.borderColor != SKColor.clearColor() {
            let backgroundSize: CGSize
            switch parallaxConfig.direction {
            case .Up, .Down:
                backgroundSize = CGSizeMake(parallaxConfig.layerOffset, size.height)
            case .Right, .Left:
                backgroundSize = CGSizeMake(size.width, parallaxConfig.layerOffset)
            }
            self.background = SKSpriteNode(color: parallaxConfig.borderColor, size: backgroundSize)
            switch parallaxConfig.anchor {
            case .Top:
                self.background!.anchorPoint = CGPointMake(0.5, 1)
                self.background!.position = CGPointMake(size.width / 2, size.height)
            case .Center:
                // TODO: (TL) ... add to top and bottom
                break
            case .Bottom:
                self.background!.anchorPoint = CGPointMake(0.5, 0)
                self.background!.position = CGPointMake(size.width / 2, 0)
            }
            self.background!.zPosition = self.zPosition + 1
            addChild(self.background!)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func update(deltaTime: CFTimeInterval, multiplier: CGFloat) {
        averageDeltaTime = max((averageDeltaTime + deltaTime) / 2, 1/60.0)

        if timeToNextItem > 0 {
            timeToNextItem -= deltaTime
        } else if children.count < parallaxConfig.maxItems {
            let pixelsPerUpdate = CFTimeInterval(parallaxConfig.speed) * averageDeltaTime
            let newElement = nextScreenElement()
            switch parallaxConfig.direction {
            case .Up, .Down:
                timeToNextItem = CFTimeInterval(newElement.size.height) * CFTimeInterval(1 + parallaxConfig.elementDelay) / pixelsPerUpdate * averageDeltaTime
            case .Right, .Left:
                timeToNextItem = CFTimeInterval(newElement.size.width) * CFTimeInterval(1 + parallaxConfig.elementDelay) / pixelsPerUpdate * averageDeltaTime
            }
            addChild(newElement)
        }

        if parallaxConfig.oscillationSpeed > Constants.CGFloatEpsilon {
            updateOscillation(deltaTime, multiplier: multiplier)
        }

        for child in children {
            if let spriteChild = child as? SKSpriteNode {
                updatePosition(spriteChild, deltaTime: CGFloat(deltaTime), multiplier: multiplier)
            }
        }
    }

    // MARK: - Functions
    func nextScreenElement() -> SKSpriteNode {
        let elementIndex: Int = Int(arc4random_uniform(UInt32(textures.count)))
        let newElement = SKSpriteNode(texture: textures[elementIndex], size: textures[elementIndex].size())
        newElement.position = startPositionForElement(newElement)
        newElement.zPosition = parallaxConfig.distance * ParallaxLayerNode.LayersPerNode
        if parallaxConfig.colorAdjustPct > Constants.CGFloatEpsilon {
            newElement.color = parallaxConfig.colorAdjust
            newElement.colorBlendFactor = parallaxConfig.colorAdjustPct
        }
        return newElement
    }

    func updateOscillation(deltaTime: CFTimeInterval, multiplier: CGFloat) {
        totalOscillationOffset += oscillationDirection * oscillationOffset * multiplier
        if totalOscillationOffset > oscillation {
            totalOscillationOffset = oscillation
            oscillationDirection = -1
        } else {
            let lowerOscillationTarget = parallaxConfig.anchor == .Center ? -oscillation : 0
            if totalOscillationOffset < lowerOscillationTarget {
                totalOscillationOffset = -oscillation
                oscillationDirection = 1
            }
        }
    }

    func updatePosition(child: SKSpriteNode, deltaTime: CGFloat, multiplier: CGFloat) {
        if parallaxConfig.oscillationSpeed > Constants.CGFloatEpsilon {
            updatePositionForOscillation(child, deltaTime: deltaTime, multiplier: multiplier)
        }

        if child == self.background { // Background doesn't move!
            return
        }

        switch parallaxConfig.direction {
        case .Up:
            child.position.y += parallaxConfig.speed * deltaTime * multiplier
            if child.position.y + child.size.height > size.height {
                child.removeFromParent()
            }
            
        case .Down:
            child.position.y -= parallaxConfig.speed * deltaTime * multiplier
            if child.position.y + child.size.height < 0 {
                child.removeFromParent()
            }
            
        case .Right:
            child.position.x += parallaxConfig.speed * deltaTime * multiplier
            if child.position.x + child.size.width > size.width {
                child.removeFromParent()
            }
            
        case .Left:
            child.position.x -= parallaxConfig.speed * deltaTime * multiplier
            if child.position.x + child.size.width < 0 {
                child.removeFromParent()
            }
        }
    }

    func updatePositionForOscillation(child: SKSpriteNode, deltaTime: CGFloat, multiplier: CGFloat) {
        let oscillationDelta = oscillationDirection * oscillationOffset * multiplier
        switch parallaxConfig.direction {
        case .Up, .Down:
            child.position.x += oscillationDelta
        case .Right, .Left:
            child.position.y += oscillationDelta
        }
    }

    // MARK: - Utilities
    func startPositionForElement(element: SKSpriteNode) -> CGPoint {
        var startPosition: CGPoint = CGPointZero
        switch parallaxConfig.anchor {
        case .Top:
            element.anchorPoint = CGPointMake(0.5, 1)
            startPosition.y = size.height - parallaxConfig.layerOffset
        case .Center:
            let offsetMultiplier:CGFloat = CGFloat(arc4random_uniform(20)) * 0.1
            let offsetDirection: CGFloat = arc4random_uniform(2) < 1 ? -1 : 1
            let offset:CGFloat = offsetDirection * offsetMultiplier * parallaxConfig.layerOffset
            element.anchorPoint = CGPointMake(0.5, 0.5)
            startPosition.y = size.height / 2 + offset
        case .Bottom:
            element.anchorPoint = CGPointMake(0.5, 0)
            startPosition.y = parallaxConfig.layerOffset
        }

        switch parallaxConfig.direction {
        case .Up, .Down:
            startPosition.x = size.width / 2 + totalOscillationOffset
        case .Left:
            startPosition.x = size.width + element.size.width
        case .Right:
            startPosition.x = -element.size.width
            startPosition.y += totalOscillationOffset
        }

        return startPosition
    }
}