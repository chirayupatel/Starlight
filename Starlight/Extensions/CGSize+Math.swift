//
//  CGSize+Math.swift
//  Starlight
//
//  Created by Terry on 2015-08-26.
//  Copyright © 2015 Flybits Inc. All rights reserved.
//

import CoreGraphics

func * (left: CGSize, right: CGFloat) -> CGSize {
    return CGSizeMake(left.width * right, left.height * right)
}

func *= (inout left: CGSize, right: CGFloat) {
    left.width *= right
    left.height *= right
}

func / (left: CGSize, right: CGFloat) -> CGSize {
    return CGSizeMake(left.width / right, left.height / right)
}

func /= (inout left: CGSize, right: CGFloat) {
    left.width /= right
    left.height /= right
}