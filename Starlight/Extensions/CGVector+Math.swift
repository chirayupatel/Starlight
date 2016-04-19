//
//  CGVector+Math.swift
//  Starlight
//
//  Created by Terry on 2015-08-26.
//  Copyright © 2015 Flybits Inc. All rights reserved.
//

import SpriteKit

extension CGVector {
    // TODO: (TL) Cache these
    var normalized: CGVector {
        let mag = magnitude
        if mag > 0 {
            return CGVectorMake(dx / mag, dy / mag)
        }
        return CGVectorMake(0, 0)
    }

    var magnitude: CGFloat {
        return sqrt(dx * dx + dy * dy)
    }
}

func * (left: CGVector, right: CGFloat) -> CGVector {
    return CGVectorMake(left.dx * right, left.dy * right)
}