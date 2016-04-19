//
//  CollectibleGeneratorNode.swift
//  Starlight
//
//  Created by Terry on 2015-10-09.
//  Copyright © 2015 Flybits Inc. All rights reserved.
//

import SpriteKit

enum CollectibleType: Int {
    case Coin
}

class CollectibleGeneratorNode: GeneratorNode {
    // MARK: - Functions
    override func generateElementOfType(type: Int, withTemplate template: Template) -> SKNode? {
        switch type {
        case CollectibleType.Coin.rawValue:
            return BasicGameObjectNode(atlas: atlas, template: template, screenSize: screenSize)
        default:
            return nil
        }
    }
}
