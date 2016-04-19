//
//  AnimatedSpriteNode.swift
//  Starlight
//
//  Created by Terry on 2015-08-26.
//  Copyright © 2015 Flybits Inc. All rights reserved.
//

import SpriteKit

class AnimatedSpriteNode: SKSpriteNode, Updatable {

    // MARK: - Properties
    let animationNames: [String]?
    var animationDictionary: [String:AnimationNode] = [:]

    // MARK: - Lifecycle Functions
    init(atlas: SKTextureAtlas, baseTextureName: String, size: CGSize, animationNames: [String]? = nil) {
        self.animationNames = animationNames

        super.init(texture: atlas.textureNamed(baseTextureName), color: SKColor.clearColor(), size: size)

        addAnimations(atlas)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func update(deltaTime: CFTimeInterval, multiplier: CGFloat) { /* NOT USED */ }

    // MARK: - Functions
    func addAnimations(atlas: SKTextureAtlas) {
        if let animationNames = animationNames {
            for animationName in animationNames {
                let textures = ResourceManager.texturesFromAtlas(atlas, named: animationName)
                let animationLayer = AnimationNode(textures: textures, size: size)
                animationDictionary[animationName] = animationLayer
                // TODO: (TL) Animation layers zPosition
                animationLayer.zPosition = 2
                addChild(animationLayer)
            }
        }
    }

    func hasAnimation(named animationName: String) -> Bool {
        return (animationNames != nil && animationNames?.contains(animationName) != nil)
    }

    func doAnimation(named animationName: String, completion: ((isDone: Bool) -> Void)? = nil) {
        if !hasAnimation(named: animationName) {
            return
        }
        
        if !animationDictionary[animationName]!.isAnimating {
            animationDictionary[animationName]!.animate {
                if let completion = completion {
                    completion(isDone: self.animationDictionary[animationName]!.atStart)
                }
            }
        }
    }
}
