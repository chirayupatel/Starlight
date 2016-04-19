//
//  FLBUIProgressBar.swift
//  Starlight
//
//  Created by Terry on 2015-08-27.
//  Copyright © 2015 Flybits Inc. All rights reserved.
//

import SpriteKit

class FLBUIProgressBar: SKSpriteNode { // TODO: (TL) add support for colors
    enum Direction {
        case Up
        case Down
        case Right
        case Left
    }

    // MARK: - Properties
    let foreground: SKSpriteNode
    let cropNode: SKCropNode
    let fgMask: SKSpriteNode
    let direction: Direction
    var progress: CGFloat
    var startValue: CGFloat { // TODO: (TL) Do we update progress to keep it proportionally filled?
        didSet {
            if progress < startValue {
                progress = startValue
            }
        }
    }
    var finishValue: CGFloat {
        didSet {
            if progress > finishValue {
                progress = finishValue
            }
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
    init(bgTexture: SKTexture, fgTexture: SKTexture, size: CGSize, startValue: CGFloat, finishValue: CGFloat, startsCompleted: Bool = false, direction: Direction = .Right) {
        self.startValue = startValue
        self.finishValue = finishValue
        self.direction = direction
        self.progress = startsCompleted ? self.finishValue : self.startValue

        // Set up the mask
        self.foreground = SKSpriteNode(texture: fgTexture, size: size)
        self.fgMask = SKSpriteNode(texture: fgTexture, size: size)
        self.cropNode = SKCropNode()
        self.cropNode.addChild(self.foreground)
        self.cropNode.maskNode = fgMask

        super.init(texture: bgTexture, color: SKColor.clearColor(), size: size)
        self.cropNode.zPosition = zPosition + 1

        addChild(cropNode)

        animateProgress()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Functions
    func updateProgress(amount: CGFloat) {
        if amount < Constants.CGFloatEpsilon && amount > -Constants.CGFloatEpsilon {
            return
        }

        progress = max(min(progress + amount, finishValue), startValue)
        animateProgress()
    }

    private func animateProgress() {
        let progressPercent = 1 - (progress - startValue) / (finishValue - startValue)
        switch direction {
        case .Up:
            fgMask.position.y = size.height * progressPercent
        case .Down:
            fgMask.position.y = -size.width * progressPercent
        case .Right:
            fgMask.position.x = size.width * progressPercent
        case .Left:
            fgMask.position.x = -size.width * progressPercent
        }
    }
}