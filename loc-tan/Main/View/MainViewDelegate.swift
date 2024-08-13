//
//  MainViewDelegate.swift
//  loc-tan
//
//  Created by EnchantCode on 2024/08/13.
//

import Foundation

protocol MainViewDelegate: AnyObject {
    
    func mainViewDidTapCaptureButton(_ view: MainView)
    
    func mainViewDidTapZoomFactorButton(_ view: MainView)
    
    func mainView(_ view: MainView, didChangeOpacitySliderValue to: Float)
    
}
