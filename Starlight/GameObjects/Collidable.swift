//
//  Collidable.swift
//  Starlight
//
//  Created by Terry on 2015-08-26.
//  Copyright © 2015 Flybits Inc. All rights reserved.
//

import SpriteKit

protocol Collidable {
    func didBeginCollisionWith(other: SKNode?)
    func didEndCollisionWith(other: SKNode?)
}