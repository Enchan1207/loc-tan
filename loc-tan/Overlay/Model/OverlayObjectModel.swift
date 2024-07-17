//
//  OverlayObjectModel.swift
//  loc-tan
//
//  Created by EnchantCode on 2024/07/17.
//

import UIKit

class OverlayObjectModel {
    
    /// オブジェクト識別子
    let id: String
    
    /// 画面中央を基準とした座標
    var center: CGPoint
    
    /// 表示する画像
    let image: UIImage
    
    init(id: String, center: CGPoint, image: UIImage) {
        self.id = id
        self.center = center
        self.image = image
    }
    
}
