//
//  ResourceManager.swift
//  Starlight
//
//  Created by Terry on 2015-08-25.
//  Copyright © 2015 Flybits Inc. All rights reserved.
//

import SpriteKit

private let instance = ResourceManager()

class ResourceManager {
    // MARK: - Constants
    static let DensitySuffix = "@%.0fx%@"

    // MARK: - Properties
    var loadedAtlases: [String: SKTextureAtlas] = [:]

    // MARK: - Functions
    class func atlas(named atlasName: String) -> SKTextureAtlas {
        if let atlas = instance.loadedAtlases[atlasName] {
            return atlas
        }

        let atlas = SKTextureAtlas(named: atlasName)
        instance.loadedAtlases[atlasName] = atlas

        return atlas
    }

    class func texturesFromAtlas(atlas: SKTextureAtlas, named subSectionName: String) -> [SKTexture] {
        let resolutionSuffix: String = suffixForDensity(UIScreen.mainScreen().scale, withExtension: ".png")

        var textures: [SKTexture] = []
        let sortedTextureNames = atlas.textureNames.sort{ $0 < $1 }.filter{ $0.hasSuffix(resolutionSuffix) }
        for textureName in sortedTextureNames {
            if textureName.hasPrefix(subSectionName) {
                textures.append(atlas.textureNamed(textureName))
            }
        }
        return textures
    }

    class func textureNameWithDensity(baseTextureName: String) -> String {
        return baseTextureName.stringByAppendingString(suffixForDensity(UIScreen.mainScreen().scale))
    }

    private class func suffixForDensity(densityScale: CGFloat, withExtension fileExtension: String = "") -> String {
        if densityScale > 1 {
            return String(format: ResourceManager.DensitySuffix, arguments: [UIScreen.mainScreen().scale, fileExtension])
        } else {
            return fileExtension // TODO: (TL) This is likely a bug waiting to happen
        }
    }
}