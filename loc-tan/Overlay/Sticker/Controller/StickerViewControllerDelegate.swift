//
//  StickerViewControllerDelegate.swift
//  loc-tan
//
//  Created by EnchantCode on 2024/07/20.
//

import Foundation

protocol StickerViewControllerDelegate: AnyObject {
    
    func stickerViewDidRequireActivation(_ sticker: StickerViewController)
    
}
