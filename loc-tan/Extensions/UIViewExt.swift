//
//  UIViewExt.swift
//  loc-tan
//
<<<<<<< HEAD
//  Created by EnchantCode on 2024/06/23.
=======
//  Created by EnchantCode on 2024/06/30.
>>>>>>> develop
//

import UIKit

extension UIView {
    
    // NOTE: この辺わざわざ実装しなくてもいいんじゃないかなあ
    
    @discardableResult
    class func animate(withDuration duration: TimeInterval,
                       animations: @escaping () -> Void) async -> Bool {
        return await withCheckedContinuation { continuation in
            animate(withDuration: duration, animations: animations, completion: {result in continuation.resume(returning: result)})
        }
    }
    
    @discardableResult
    class func transision(with: UIView,
                          duration: TimeInterval,
                          options: AnimationOptions = [],
                          animations: ( () -> Void)?) async -> Bool {
        await withCheckedContinuation { continuation in
            transition(with: with, duration: duration, options: options, animations: animations, completion: {result in continuation.resume(returning: result) })
        }
    }
    
}
