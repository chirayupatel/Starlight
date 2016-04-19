//
//  EnemyNode.swift
//  Starlight
//
//  Created by Terry on 2015-08-26.
//  Copyright © 2015 Flybits Inc. All rights reserved.
//

import SpriteKit

class EnemyNode: BasicGameObjectNode {
    override func update(deltaTime: CFTimeInterval, multiplier: CGFloat) {
        paused = multiplier < Constants.CGFloatEpsilon

        super.update(deltaTime, multiplier: multiplier)
    }

    // MARK: - Collidable Functions
    override func didBeginCollisionWith(other: SKNode?) {
        guard other as? PlayerNode != nil else {
            return
        }
        runAction(SKAction.fadeOutWithDuration(0.1)) {
            self.removeFromParent()
        }
    }
}