//
//  StickerBoardModel.swift
//  loc-tan
//
//  Created by EnchantCode on 2024/07/20.
//

import Foundation

class StickerBoardModel: Codable {
    
    var stickers: [StickerModel] = []
    
    init(stickers: [StickerModel]) {
        self.stickers = stickers
    }
    
}
