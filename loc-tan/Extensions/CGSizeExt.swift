//
//  CGSizeExt.swift
//  loc-tan
//
//  Created by EnchantCode on 2024/08/13.
//

import Foundation

extension CGSize {
    
    /// 指定されたアスペクト比の矩形について、自身に収まる最大サイズを返す
    /// - Parameter ratio: 内接矩形のアスペクト比
    func maxFitSize(at ratio: AspectRatio) -> CGSize {
        let heightBasedWidth = height * ratio.rawValue
        if heightBasedWidth <= width {
            return .init(width: heightBasedWidth, height: height)
        }
        return .init(width: width, height: width / ratio.rawValue)
    }
    
}
