//
//  FLBUIButton.swift
//  Starlight
//
//  Created by Terry on 2015-08-27.
//  Copyright © 2015 Flybits Inc. All rights reserved.
//

import SpriteKit

class FLBUIButton: SKSpriteNode { // TODO: (TL) Label alignment, text size, etc.
    enum State {
        case Normal
        case Selected
        case Disabled
    }

    // MARK: - Properties
    var textures: [State : SKTexture]?
    var colors: [State : SKColor]?
    var labelNode: SKLabelNode?
    var backgroundNode: SKShapeNode?
    var delegate: FLBUITouchDelegate?
    var isToggle: Bool = false
    var isDisabled: Bool {
        didSet {
            self.userInteractionEnabled = !isDisabled
            if let texture = textures?[.Disabled] {
                self.texture = texture
            }
            if let color = colors?[.Disabled] {
                backgroundNode?.strokeColor = color
                backgroundNode?.fillColor = color
            }
        }
    }

    var isSelected: Bool {
        didSet {
            let state: State
            if isDisabled {
                state = .Disabled
            } else if isSelected {
                state = .Selected
            } else {
                state = .Normal
            }
            if let texture = textures?[state] {
                self.texture = texture
            }
            if let color = colors?[state] {
                backgroundNode?.fillColor = color
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

    private var state: State = .Normal
    init(size: CGSize, colors: [State : SKColor]? = nil, textures: [State : SKTexture]? = nil, cornerRadius: CGFloat = 0, text: String? = nil) {
        self.textures = textures
        self.colors = colors
        self.isSelected = false
        self.isDisabled = false

        super.init(texture: textures?[.Normal], color: SKColor.clearColor(), size: size)
        self.userInteractionEnabled = true

        if let color = colors?[.Normal] {
            let rect = CGRectMake(-size.width / 2, -size.height / 2, size.width, size.height)
            let path = cornerRadius > 0 ? CGPathCreateWithRoundedRect(rect, cornerRadius, cornerRadius, nil) : CGPathCreateWithRect(rect, nil)
            self.backgroundNode = SKShapeNode(path: path)
            self.backgroundNode!.strokeColor = SKColor.clearColor()
            self.backgroundNode!.fillColor = color
            self.backgroundNode!.zPosition = self.zPosition - 1
            addChild(self.backgroundNode!)
        }

        if let text = text {
            self.labelNode = SKLabelNode(text: text)
            self.labelNode!.verticalAlignmentMode = .Center
            self.labelNode!.zPosition = self.zPosition + 1

            addChild(self.labelNode!)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Utility Functions
    func touchInsideButton(touch: UITouch?) -> Bool {
        if self.parent == nil || touch == nil {
            return false
        }

        let touchPoint = touch!.locationInNode(self.parent!)
        return CGRectContainsPoint(frame, touchPoint)
    }

    // MARK: - Interactive Functions
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if touchInsideButton(touches.first) {
            if !isToggle {
                isSelected = true
            }
            delegate?.onTouchDown(self)
        }
    }

    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if !isToggle {
            isSelected = touchInsideButton(touches.first)
        }
    }

    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if touchInsideButton(touches.first) {
            isSelected = isToggle ? !isSelected : false
            delegate?.onTouchUp(self)
        }
    }

    override func touchesCancelled(touches: Set<UITouch>?, withEvent event: UIEvent?) {
        isSelected = isToggle ? !isSelected : false
        delegate?.onTouchCancelled(self)
    }
}