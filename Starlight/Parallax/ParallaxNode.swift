//
//  ParallaxSystem.swift
//  Starlight
//
//  Created by Terry Latanville on 2015-08-25.
//  Copyright © 2015 Flybits Inc. All rights reserved.
//

import SpriteKit

class ParallaxNode: SKNode, Updatable {
    // MARK: - Lifecycle Functions
    init(nodeConfigs: [ParallaxNodeConfig], size: CGSize) {
        super.init()

        for nodeConfig in nodeConfigs {
            let atlas = ResourceManager.atlas(named: nodeConfig.atlasName)
            let layerTextures = ResourceManager.texturesFromAtlas(atlas, named: nodeConfig.assetGroup)
            let layer: ParallaxLayerNode = ParallaxLayerNode(textures: layerTextures, size: size, parallaxConfig: nodeConfig)
            addChild(layer)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func update(deltaTime: CFTimeInterval, multiplier: CGFloat = 1) {
        for child in children {
            (child as? ParallaxLayerNode)?.update(deltaTime, multiplier: multiplier)
        }
    }

    // MARK: - Functions
    func switchAtlas(atlasName: String) {
        let nextAtlas = ResourceManager.atlas(named: atlasName)
        for child in children {
            (child as? ParallaxLayerNode)?.nextAtlas = nextAtlas
        }
    }
}