//
//  FLBUILabel.swift
//  Starlight
//
//  Created by Terry on 2015-08-27.
//  Copyright © 2015 Flybits Inc. All rights reserved.
//

import SpriteKit

class FLBUILabel: SKSpriteNode { // TODO: (TL) better support for vertical / horizontal alignment/

    // MARK: - Properties
    let textLabel: SKLabelNode

    var fontName: String? {
        didSet {
            textLabel.fontName = fontName
        }
    }

    var fontColor: SKColor? {
        didSet {
            textLabel.fontColor = fontColor
        }
    }

    var fontSize: CGFloat? {
        didSet {
            textLabel.fontSize = fontSize ?? 32 // Default size of SKLabelNode
        }
    }

    var verticalAlignmentMode: SKLabelVerticalAlignmentMode? {
        didSet {
            textLabel.verticalAlignmentMode = verticalAlignmentMode ?? .Baseline
            switch textLabel.verticalAlignmentMode { // TODO: (TL) Take offset into account?
            case .Baseline:
                textLabel.position.y = -size.height / 2 + textLabel.fontSize / 2 // TODO: (TL) Not correct
            case .Bottom:
                textLabel.position.y = -size.height
            case .Top:
                textLabel.position.y = 0
            case .Center:
                textLabel.position.y = -size.height / 2
            }
        }
    }

    var horizontalAlignmentMode: SKLabelHorizontalAlignmentMode? {
        didSet {
            textLabel.horizontalAlignmentMode = horizontalAlignmentMode ?? .Center
        }
    }

    override var anchorPoint: CGPoint {
        didSet {
            let offsetDelta = CGPointMake(oldValue.x - anchorPoint.x, oldValue.y - anchorPoint.y)
            for child in children {
                child.position.x += offsetDelta.x * size.width
                child.position.y += offsetDelta.y * size.height
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
    init(texture: SKTexture?, color: SKColor, size: CGSize, text: String) {
        textLabel = SKLabelNode(text: text)
        textLabel.verticalAlignmentMode = .Center
        fontSize = textLabel.fontSize

        super.init(texture: texture, color: color, size: size)
        textLabel.zPosition = zPosition + 1

        addChild(textLabel)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}