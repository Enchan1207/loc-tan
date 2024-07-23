//
//  StickerImageProvider.swift
//  loc-tan
//
//  Created by EnchantCode on 2024/07/23.
//

import UIKit


class StickerImageProvider {
    
    static let shared = StickerImageProvider()
    
    private init(){
    }
    
    func image(for identifier: String) -> UIImage? {
        // TODO: ほとんどモックのようなもの 本来はちゃんとキャッシュしたりPHAssetから取得したりしたい
        
        let assetNames = [
            "dive_stage",
            "rainbow_bridge_night",
            "rainbow_bridge_noon",
            "tokyo_skytree"
        ]
        
        if assetNames.contains(identifier){
            return .init(named: identifier)
        }
        
        return nil
    }
    
}
