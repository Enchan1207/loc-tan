//
//  StickerModel.swift
//  loc-tan
//
//  Created by EnchantCode on 2024/07/20.
//

import UIKit


final class StickerModel: Codable {
    
    /// ステッカーの画像を表す識別子
    let imageIdentifier: String
    
    /// ステッカーの画像
    var image: UIImage? {
        StickerImageProvider.shared.image(for: imageIdentifier)
    }
    
    /// 中心座標
    var center: CGPoint
    
    /// 幅
    var width: CGFloat
    
    /// 傾き
    var angle: Angle
    
    init(imageIdentifier: String, center: CGPoint, width: CGFloat, angle: Angle) {
        self.imageIdentifier = imageIdentifier
        self.center = center
        self.width = width
        self.angle = angle
    }
    
}
