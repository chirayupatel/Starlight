//
//  AnimationAction.swift
//  GameDemo
//
//  Created by Terry on 2015-09-02.
//  Copyright © 2015 Flybits Inc. All rights reserved.
//

import SpriteKit

struct AnimationAction {
    // MARK: - Enums
    enum AnimationDirection {
        case Forward
        case Backward
    }

    // MARK: - Typealiases
    typealias AnimationCompletion = (animationAction: AnimationAction) -> Void

    let startFrame: Int
    let endFrame: Int
    let direction: AnimationDirection
    let completion: AnimationCompletion?

    init(startFrame: Int, endFrame: Int, direction: AnimationDirection = .Forward, completion: AnimationCompletion? = nil) {
        self.startFrame = startFrame
        self.endFrame = endFrame
        self.direction = direction
        self.completion = completion
    }
}