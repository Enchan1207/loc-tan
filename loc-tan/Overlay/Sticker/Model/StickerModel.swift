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
    
    /// 操作対象になっているかどうか
    var isTargetted: Bool {
        didSet {
            guard oldValue != isTargetted else {return}
            delegate?.stickerModel(self, didChange: isTargetted)
        }
    }
    
    /// ステッカーの透明度
    private (set) var opacity: Float
    
    func setOpacity(to opacity: Float, animated: Bool) {
        self.opacity = opacity
        self.delegate?.stickerModel(self, didChange: opacity, animated: animated)
    }
    
    /// ターゲット状態を表示に反映すべきか
    var shouldIndicateState: Bool {
        didSet {
            delegate?.stickerModel(self, didChangeIndication: shouldIndicateState)
        }
    }
    
    // MARK: - Initializing
    
    init(image: UIImage, center: CGPoint, width: CGFloat, angle: Angle, isTargetted: Bool, opacity: Float, shouldIndicateState: Bool) {
        self.image = image
        self.center = center
        self.width = width
        self.angle = angle
        self.isTargetted = isTargetted
        self.opacity = opacity
        self.shouldIndicateState = shouldIndicateState
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
