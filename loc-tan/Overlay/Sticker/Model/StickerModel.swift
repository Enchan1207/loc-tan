//
//  StickerModel.swift
//  loc-tan
//
//  Created by EnchantCode on 2024/07/20.
//

import UIKit


final class StickerModel: Codable {
    
    private let id = UUID()
    
    weak var delegate: StickerModelDelegate?
    
    // MARK: - Properties
    
    /// ステッカーの画像を表す識別子
    let imageIdentifier: String
    
    /// ステッカーの画像
    var image: UIImage? {
        StickerImageProvider.shared.image(for: imageIdentifier)
    }
    
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
        case imageIdentifier
        case center
        case width
        case angle
    }
    
    // MARK: - Initializing
    
    init(imageIdentifier: String, center: CGPoint, width: CGFloat, angle: Angle) {
        self.imageIdentifier = imageIdentifier
        self.center = center
        self.width = width
        self.angle = angle
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.imageIdentifier = try container.decode(String.self, forKey: .imageIdentifier)
        self.center = try container.decode(CGPoint.self, forKey: .center)
        self.width = try container.decode(CGFloat.self, forKey: .width)
        self.angle = try container.decode(Angle.self, forKey: .angle)
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.imageIdentifier, forKey: .imageIdentifier)
        try container.encode(self.center, forKey: .center)
        try container.encode(self.width, forKey: .width)
        try container.encode(self.angle, forKey: .angle)
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
