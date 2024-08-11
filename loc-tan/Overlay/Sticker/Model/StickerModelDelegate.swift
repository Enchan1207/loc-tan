//
//  StickerModelDelegate.swift
//  loc-tan
//
//  Created by EnchantCode on 2024/07/27.
//

import Foundation

protocol StickerModelDelegate: AnyObject {
    
    func stickerModel(_ model: StickerModel, didMove to: CGPoint)
    
    func stickerModel(_ model: StickerModel, didChange width: CGFloat)
    
    func stickerModel(_ model: StickerModel, didChange angle: Angle)
    
    func stickerModel(_ model: StickerModel, didChange isTargetted: Bool)
    
    func stickerModel(_ model: StickerModel, didChange opacity: Float, animated: Bool)
    
    func stickerModel(_ model: StickerModel, didChangeIndication shouldIndicateState: Bool)
    
}
