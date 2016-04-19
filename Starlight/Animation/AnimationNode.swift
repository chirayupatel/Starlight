//
//  AnimationLayer.swift
//  Starlight
//
//  Created by Terry on 2015-08-24.
//  Copyright © 2015 Flybits Inc. All rights reserved.
//

import SpriteKit

class AnimationNode: SKSpriteNode {
    // MARK: - Constants
    static let TimePerFrame = 1/60.0

    // MARK: - Properties
    let textures: [SKTexture]
    var atStart: Bool = true
    var isAnimating: Bool = false
    var currentAction: SKAction?
    var animationQueue: [() -> Void] = []

    // MARK: - Lifecycle Functions
    init(textures: [SKTexture], size: CGSize) {
        self.textures = textures

        super.init(texture: textures[0], color: SKColor.clearColor(), size: size)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Functions
    func animate(completion: () -> Void) { // TODO: (TL) Make this not look sucky when stopping mid-animation
        // Common completion block
        if isAnimating {
            animationQueue.append(completion)
            return
        }

        let actionComplete: () -> Void = {
            self.atStart = !self.atStart
            self.currentAction = nil
            self.isAnimating = false
            completion()
            
            if self.animationQueue.count > 0 {
                self.animate(self.animationQueue.popLast() as (() -> Void)!)
            }
        }

        isAnimating = true
        if currentAction != nil {
            self.atStart = !self.atStart
            currentAction = currentAction!.reversedAction()
            runAction(currentAction!, completion: actionComplete)
        } else {
            currentAction = SKAction.animateWithTextures(textures, timePerFrame: AnimationNode.TimePerFrame)
            if !atStart {
                currentAction = currentAction!.reversedAction()
            }
            runAction(currentAction!, completion: actionComplete)
        }
    }
}