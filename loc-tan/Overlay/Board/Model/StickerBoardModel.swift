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
    private (set) var stickersOpacity: Float = 0.8
    
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
    
    func setOpacity(_ opacity: Float, animated: Bool = true) {
        stickersOpacity = opacity
        delegate?.stickerBoard(self, didChangeStickersOpacity: stickersOpacity, animated: animated)
    }
    
    func switchTarget(to: StickerModel){
        guard stickers.contains(to) else {return}
        stickers.forEach({$0.isTargetted = $0 == to})
    }
    
}
