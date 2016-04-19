//
//  ParallaxNodeConfig.swift
//  Starlight
//
//  Created by Terry Latanville on 2015-08-25.
//  Copyright © 2015 Flybits Inc. All rights reserved.
//

import SpriteKit

enum ParallaxDirection {
    case Up
    case Down
    case Right
    case Left
}

struct ParallaxNodeConfig {
    enum Anchor {
        case Top
        case Bottom
        case Center
    }

    enum NodeType {
        case Standard
        case Oscillating
        case Bordered
    }

    let atlasName: String
    let assetGroup: String
    let speed: CGFloat
    let distance: CGFloat
    let maxItems: Int
    let colorAdjust: SKColor
    let colorAdjustPct: CGFloat
    let anchor: Anchor
    let layerOffset: CGFloat
    let direction: ParallaxDirection
    let oscillation: CGFloat
    let oscillationSpeed: CGFloat
    let elementDelay: CGFloat
    let borderColor: SKColor

    init(atlasName: String, assetGroup: String, speed: CGFloat, distance: CGFloat, maxItems: Int = 1, colorAdjust: SKColor = SKColor.clearColor(), colorAdjustPct: CGFloat = 0, anchor: Anchor = .Bottom, layerOffset: CGFloat = 0, direction: ParallaxDirection = .Left, oscillation: CGFloat = 0, oscillationSpeed: CGFloat = 0, elementDelay: CGFloat = 0, borderColor: SKColor = SKColor.clearColor()) {
        self.atlasName = atlasName
        self.assetGroup = assetGroup
        self.speed = speed
        self.distance = distance
        self.maxItems = maxItems
        self.colorAdjust = colorAdjust
        self.colorAdjustPct = colorAdjustPct
        self.anchor = anchor
        self.layerOffset = layerOffset
        self.direction = direction
        self.oscillation = oscillation
        self.oscillationSpeed = oscillationSpeed
        self.elementDelay = elementDelay
        self.borderColor = borderColor
    }
}