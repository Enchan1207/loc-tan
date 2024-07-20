//
//  StickerModel.swift
//  loc-tan
//
//  Created by EnchantCode on 2024/07/20.
//

import UIKit


final class StickerModel {

    /// ステッカーの画像
    let image: UIImage
    
    /// 中心座標
    var center: CGPoint
    
    /// 幅
    var width: CGFloat
    
    /// 傾き
    var angle: CGFloat
    
    init(image: UIImage, center: CGPoint, width: CGFloat, angle: CGFloat) {
        self.image = image
        self.center = center
        self.width = width
        self.angle = angle
    }
    
}
