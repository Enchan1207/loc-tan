//
//  DeviceOrientation.swift
//  loc-tan
//
//  Created by EnchantCode on 2024/08/25.
//

import UIKit
import CoreMotion

/// デバイス姿勢の管理
final class DeviceOrientation {
    
    // MARK: - Properties
    
    static let shared = DeviceOrientation()
    
    private (set) public var currentOrientation: UIDeviceOrientation
    
    static let orientationDidChangeNotification = Notification.Name("me.enchan.loc-tan.deviceorientation.change")
    
    private let motionManager = CMMotionManager()
    
    // MARK: - Initializing
    
    private init(){
        self.currentOrientation = .unknown
    }
    
    // MARK: - Motion observation
    
    func startDeviceMotionUpdates(){
        guard motionManager.isDeviceMotionAvailable else {return}
        
        motionManager.deviceMotionUpdateInterval = 0.2
        motionManager.startDeviceMotionUpdates(to: .main, withHandler: {[weak self] motion, error in
            guard error == nil, let gravity = motion?.gravity else {return}
            let newOrientation: UIDeviceOrientation
            if fabs(gravity.y) >= fabs(gravity.x) {
                newOrientation = gravity.y >= 0 ? .portraitUpsideDown : .portrait
            } else {
                newOrientation = gravity.x >= 0 ? .landscapeRight : .landscapeLeft
            }
            
            guard newOrientation != self?.currentOrientation else {return}
            self?.currentOrientation = newOrientation
            NotificationCenter.default.post(name: Self.orientationDidChangeNotification, object: nil)
        })
    }
    
    func stopDeviceMotionUpdates(){
        guard motionManager.isDeviceMotionActive else {return}
        motionManager.stopDeviceMotionUpdates()
    }
}
