//
//  StickerModel.swift
//  loc-tan
//
//  Created by EnchantCode on 2024/07/20.
//

import UIKit


final class StickerModel {
    
    private let id = UUID()
    
    weak var delegate: StickerModelDelegate?
    
    // MARK: - Properties
    
    /// ステッカーの画像
    let image: UIImage
    
    /// 中心座標
    var center: CGPoint {
        didSet {
            delegate?.stickerModel(self, didMove: center)
        }
    }
    
    /// 幅
    var width: CGFloat {
        didSet {
            delegate?.stickerModel(self, didChange: width)
        }
    }
    
    /// 傾き
    var angle: Angle {
        didSet {
            delegate?.stickerModel(self, didChange: angle)
        }
    }
    
    private enum CodingKeys: String, CodingKey {
        case center
        case width
        case angle
    }
    
    // MARK: - Initializing
    
    init(image: UIImage, center: CGPoint, width: CGFloat, angle: Angle) {
        self.image = image
        self.center = center
        self.width = width
        self.angle = angle
    }
}

extension StickerModel: Hashable {
    
    static func == (lhs: StickerModel, rhs: StickerModel) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
}
