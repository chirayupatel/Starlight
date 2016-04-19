//
//  SKTexture+Gradient.swift
//  Starlight
//
//  Created by Terry on 2015-09-04.
//  Copyright © 2015 Flybits Inc. All rights reserved.
//

import SpriteKit

enum GradientDirection {
    case Up
    case Left
    case UpLeft
    case UpRight
}

extension SKTexture {
    convenience init(size: CGSize, color1: CIColor, color2: CIColor, direction: GradientDirection = .Up) {
        let coreImageContext = CIContext(options: nil)
        let gradientFilter = CIFilter(name: "CILinearGradient")
        gradientFilter!.setDefaults()
        let startVector: CIVector
        let endVector: CIVector
        switch direction {
        case .Up:
            startVector = CIVector(x: size.width / 2, y: 0)
            endVector = CIVector(x: size.width / 2, y: size.height)
        case .Left:
            startVector = CIVector(x: size.width, y: size.height / 2)
            endVector = CIVector(x: 0, y: size.height / 2)
        case .UpLeft:
            startVector = CIVector(x: size.width, y: 0)
            endVector = CIVector(x: 0, y: size.height)
        case .UpRight:
            startVector = CIVector(x: 0, y: 0)
            endVector = CIVector(x: size.width, y: size.height)
        }
        gradientFilter!.setValue(startVector, forKey: "inputPoint0")
        gradientFilter!.setValue(endVector, forKey: "inputPoint1")
        gradientFilter!.setValue(color1, forKey: "inputColor0")
        gradientFilter!.setValue(color2, forKey: "inputColor1")
        let rect = CGRectMake(0, 0, size.width, size.height)
        let cgImg = coreImageContext.createCGImage(gradientFilter!.outputImage!, fromRect: rect)
        self.init(CGImage: cgImg)
    }
}