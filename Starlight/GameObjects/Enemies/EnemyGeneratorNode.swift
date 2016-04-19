//
//  EnemyGenerator.swift
//  Starlight
//
//  Created by Terry on 2015-08-31.
//  Copyright © 2015 Flybits Inc. All rights reserved.
//

import SpriteKit

// MARK: - Enemy Types
enum EnemyType: Int {
    case Basic
    case Charger
}

class EnemyGeneratorNode: GeneratorNode {
    // MARK: - Functions
    override func generateElementOfType(type: Int, withTemplate template: Template) -> SKNode? {
        switch type {
        case EnemyType.Basic.rawValue:
            return EnemyNode(atlas: atlas, template: template, screenSize: screenSize)
        case EnemyType.Charger.rawValue:
            return ChargingEnemyNode(atlas: atlas, template: template, screenSize: screenSize)
        default:
            return nil
        }
    }
}