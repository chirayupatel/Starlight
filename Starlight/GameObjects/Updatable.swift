//
//  Updatable.swift
//  Starlight
//
//  Created by Terry on 2015-10-09.
//  Copyright © 2015 Flybits Inc. All rights reserved.
//

import CoreGraphics

protocol Updatable {
    func update(deltaTime: CFTimeInterval, multiplier: CGFloat)
}