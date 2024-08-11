//
//  StickerBoardModel.swift
//  loc-tan
//
//  Created by EnchantCode on 2024/07/20.
//

import Foundation

class StickerBoardModel {
    
    // MARK: - Properties
    
    private (set) public var stickers: [StickerModel] = []
    
    /// アクティブなステッカーをハイライトすべきか
    var shouldHighLightActiveSticker: Bool = true {
        didSet {
            delegate?.stickerBoard(self, didChangeHighlightState: shouldHighLightActiveSticker)
        }
    }
    
    /// ステッカーの透明度
    var stickersOpacity: Float = 0.8 {
        didSet {
            delegate?.stickerBoard(self, didChangeStickersOpacity: stickersOpacity)
        }
    }
    
    weak var delegate: StickerBoardModelDelegate?
    
    // MARK: - Initializing
    
    init(stickers: [StickerModel]) {
        self.stickers = stickers
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
