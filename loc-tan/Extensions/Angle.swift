//
//  Angle.swift
//  loc-tan
//
//  Created by EnchantCode on 2024/07/22.
//

import Foundation

struct Angle: Equatable, CustomStringConvertible, Codable {
    
    /// 内部角度情報(ラジアン)
    private var angle: CGFloat
    
    /// 弧度法表現を返す
    var radians: CGFloat { angle }
    
    /// 度数法表現を返す
    var degrees: CGFloat { angle / (2 * .pi) * 360.0 }
    
    var description: String { .init(format: "Angle(%.2f deg, %.2f rad)", degrees, radians) }
    
    /// 垂直・水平方向に角度をスナップする
    var snapedToCross: Angle {
        if self.degrees > 0 {
            if self.degrees > 135 {
                return .init(degrees: 180)
            }
            if self.degrees > 45 {
                return .init(degrees: 90)
            }
        } else {
            if self.degrees < -135 {
                return .init(degrees: -180)
            }
            if self.degrees < -45 {
                return .init(degrees: -90)
            }
        }
        return .zero
    }
    
    init(radians: CGFloat) {
        // 一旦0~2πの範囲に丸める
        let roundedAngle = radians.truncatingRemainder(dividingBy: 2 * .pi)
        
        // 絶対値がπを超えないよう丸める
        let clippedAngle: CGFloat
        if abs(roundedAngle) <= .pi {
            clippedAngle = roundedAngle
        } else {
            clippedAngle = roundedAngle + 2 * .pi * (roundedAngle > 0 ? -1 : 1)
        }
        self.angle = clippedAngle
    }
    
    init(degrees: CGFloat){
        self.init(radians: degrees / 360.0 * 2 * .pi)
    }
    
    // ゼロ度
    static let zero: Angle = .init(radians: 0)
    
    static func == (lhs: Angle, rhs: Angle) -> Bool {
        return lhs.angle == rhs.angle
    }
    
    static func + (lhs: Angle, rhs: Angle) -> Angle {
        return Angle(radians: lhs.radians + rhs.radians)
    }
    
    static func - (lhs: Angle, rhs: Angle) -> Angle {
        return Angle(radians: lhs.radians - rhs.radians)
    }
    
    static func + (lhs: Angle, rhs: CGFloat) -> Angle {
        return Angle(radians: lhs.radians + rhs)
    }
    
    static func - (lhs: Angle, rhs: CGFloat) -> Angle {
        return Angle(radians: lhs.radians - rhs)
    }
    
    static func * (lhs: Angle, rhs: CGFloat) -> Angle {
        return Angle(radians: lhs.radians * rhs)
    }
    
    static func += (lhs: inout Angle, rhs: Angle) {
        lhs = lhs + rhs
    }
    
    static func += (lhs: inout Angle, rhs: CGFloat) {
        lhs = lhs + rhs
    }
    
    static func -= (lhs: inout Angle, rhs: Angle) {
        lhs = lhs - rhs
    }
    
    static func -= (lhs: inout Angle, rhs: CGFloat) {
        lhs = lhs - rhs
    }
    
    static func *= (lhs: inout Angle, rhs: CGFloat) {
        lhs = lhs * rhs
    }
    
}
