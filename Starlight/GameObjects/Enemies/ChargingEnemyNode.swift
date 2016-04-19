//
//  ChargingEnemyNode.swift
//  Starlight
//
//  Created by Terry Latanville on 2015-09-04.
//  Copyright © 2015 Flybits Inc. All rights reserved.
//

import SpriteKit

class ChargingEnemyNode: EnemyNode {
    // MARK: - Properties
    let detectionRadius: CGFloat = 150
    var isCharging = false
    var playerPosition: CGPoint = CGPointZero
    var chargeDirection: CGVector = CGVector.zero

    // MARK: - Lifecycle Functions
    override func update(deltaTime: CFTimeInterval, multiplier: CGFloat) {
        let movementDelta = movementSpeed * CGFloat(deltaTime) * multiplier

        super.update(deltaTime, multiplier: multiplier)
        playerPosition = scene?.childNodeWithName(Constants.Player)?.position ?? CGPointZero

        if playerPosition == CGPointZero {
            return
        }

        let distanceVector = CGVectorMake(playerPosition.x - position.x, playerPosition.y - position.y)
        if !isCharging && distanceVector.magnitude < detectionRadius {
            chargePlayer(distanceVector)
        } else if isCharging {
            position.x += movementDelta * chargeDirection.dx
            position.y += movementDelta * chargeDirection.dy
        }
    }

    // MARK: - Functions
    func chargePlayer(distanceVector: CGVector) {
        isCharging = true
        chargeDirection = distanceVector.normalized
    }
}
