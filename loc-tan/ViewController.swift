//
//  ViewController.swift
//  loc-tan
//
//  Created by EnchantCode on 2024/06/15.
//

import UIKit
import PhotosUI

class ViewController: UIViewController {
    
    /// ステータスバーを隠す
    override var prefersStatusBarHidden: Bool {true}
    
    private var cameraViewController: CameraViewController!
    
    /// ステッカーボードを配置するコンテナ
    @IBOutlet private weak var containerView: UIView! {
        didSet {
            cameraViewController = .init(nibName: nil, bundle: nil)
            
            // CameraViewControllerを子ViewControllerとして追加
            addChild(cameraViewController)
            containerView.addSubview(cameraViewController.view)
            NSLayoutConstraint.activate([
                containerView.topAnchor.constraint(equalTo: cameraViewController.view.topAnchor),
                containerView.bottomAnchor.constraint(equalTo: cameraViewController.view.bottomAnchor),
                containerView.leftAnchor.constraint(equalTo: cameraViewController.view.leftAnchor),
                containerView.rightAnchor.constraint(equalTo: cameraViewController.view.rightAnchor),
            ])
            cameraViewController.didMove(toParent: self)
        }
    }
    
    // MARK: - View lifecycles
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
}
