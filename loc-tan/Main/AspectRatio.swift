//
//  AspectRatio.swift
//  loc-tan
//
//  Created by EnchantCode on 2024/08/13.
//

import Foundation

enum AspectRatio: RawRepresentable {
    
    init?(rawValue: CGFloat) {
        self = .custom(rawValue)
    }
    
    /// 標準 (4:3)
    case standard
    
    /// ワイド (16:9)
    case wide
    
    /// スクエア (1:1)
    case square
    
    /// カスタム
    case custom(_ ratio: CGFloat)
    
    var rawValue: CGFloat {
        switch self {
        case .standard:
            4.0 / 3.0
        case .wide:
            16.0 / 9.0
        case .square:
            1.0
        case let .custom(ratio):
            ratio
        }
    }
    
}
