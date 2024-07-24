//
//  StickerBoardModel.swift
//  loc-tan
//
//  Created by EnchantCode on 2024/07/20.
//

import Foundation

class StickerBoardModel: Codable {
    
    // MARK: - Properties
    
    private (set) public var stickers: [StickerModel] = []
    
    weak var delegate: StickerBoardModelDelegate?
    
    private enum CodingKeys: String, CodingKey {
        case stickers
    }
    
    // MARK: - Initializing
    
    init(stickers: [StickerModel]) {
        self.stickers = stickers
    }
    
    required init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.stickers = try container.decode([StickerModel].self, forKey: .stickers)
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(stickers, forKey: .stickers)
    }
    
    // MARK: - Operations
    
    func add(_ sticker: StickerModel){
        stickers.append(sticker)
        delegate?.stickerBoard(self, didAddSticker: sticker)
    }
    
    func remove(_ sticker: StickerModel){
        stickers.removeAll(where: {$0 == sticker})
        delegate?.stickerBoard(self, didRemoveSticker: sticker)
    }
    
    func remove(at index: Int){
        let target = stickers.remove(at: index)
        delegate?.stickerBoard(self, didRemoveSticker: target)
    }
    
}
