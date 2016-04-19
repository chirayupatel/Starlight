//
//  FLBUIProtocols.swift
//  Starlight
//
//  Created by Terry on 2015-08-27.
//  Copyright © 2015 Flybits Inc. All rights reserved.
//

import SpriteKit

typealias FLBUIElement = SKNode
typealias FLBUIPanel = SKSpriteNode

protocol FLBUITouchDelegate {
    func onTouchDown(uiNode: FLBUIElement)
    func onTouchUp(uiNode: FLBUIElement)
    func onTouchCancelled(uiNode: FLBUIElement)
}