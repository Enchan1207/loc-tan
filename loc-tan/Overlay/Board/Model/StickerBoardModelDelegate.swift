//
//  StickerBoardModelDelegate.swift
//  loc-tan
//
//  Created by EnchantCode on 2024/07/24.
//

import Foundation

protocol StickerBoardModelDelegate: AnyObject {
    
    func stickerBoard(_ board: StickerBoardModel, didAddSticker sticker: StickerModel)
    
    func stickerBoard(_ board: StickerBoardModel, didRemoveSticker sticker: StickerModel)
    
    func stickerBoard(_ board: StickerBoardModel, didChangeHighlightState shouldHighlight: Bool)
    
    func stickerBoard(_ board: StickerBoardModel, didChangeStickersOpacity opacity: Float)
    
}
