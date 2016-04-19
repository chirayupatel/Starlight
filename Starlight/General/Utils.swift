//
//  Utilities.swift
//  Starlight
//
//  Created by Terry on 2015-08-26.
//  Copyright © 2015 Flybits Inc. All rights reserved.
//

import SpriteKit

class Utils {
    static let ColliderTypeEnemy      : UInt32 = (1 << 0)
    static let ColliderTypePlayer     : UInt32 = (1 << 1)
    static let ColliderTypeCollectible: UInt32 = (1 << 2)

    class var BobActionSequence: SKAction {
        let bobUpActionEaseOut = SKAction.moveByX(0, y: 5, duration: 1)
        bobUpActionEaseOut.timingMode = .EaseOut
        let bobUpActionEaseIn  = SKAction.moveByX(0, y: 5, duration: 1)
        bobUpActionEaseIn.timingMode = .EaseIn
        let bobDownActionEaseOut = SKAction.moveByX(0, y: -5, duration: 1)
        bobDownActionEaseOut.timingMode = .EaseOut
        let bobDownActionEaseIn = SKAction.moveByX(0, y: -5, duration: 1)
        bobDownActionEaseIn.timingMode = .EaseIn
        
        return SKAction.sequence([bobUpActionEaseOut, bobDownActionEaseIn, bobDownActionEaseOut, bobUpActionEaseIn])
    }

    class var SpinActionSequence: SKAction {
        let spinStep1 = SKAction.scaleXBy(0.1, y: 0, duration: 1)
        return SKAction.sequence([spinStep1])
    }

    class func CircleShapeNode(radius: CGFloat, strokeColor: SKColor, fillColor: SKColor? = nil) -> SKShapeNode {
        let circle = SKShapeNode()
        let rect = CGRectMake(-radius / 2, -radius / 2, radius, radius)
        circle.path = CGPathCreateWithRoundedRect(rect, rect.size.width / 2, rect.size.height / 2, nil)
        circle.strokeColor = strokeColor
        circle.fillColor = fillColor ?? strokeColor

        return circle
    }

    class func RectShapeNode(rect: CGRect, strokeColor: SKColor, fillColor: SKColor? = nil) -> SKShapeNode {
        let rectangle = SKShapeNode()
        rectangle.path = CGPathCreateWithRect(rect, nil)
        rectangle.strokeColor = strokeColor
        rectangle.fillColor = fillColor ?? strokeColor

        return rectangle
    }
}