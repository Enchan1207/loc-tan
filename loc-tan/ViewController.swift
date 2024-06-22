//
//  ViewController.swift
//  loc-tan
//
//  Created by EnchantCode on 2024/06/15.
//

import UIKit

class ViewController: UIViewController {
    
    /// ステータスバーを隠す
    override var prefersStatusBarHidden: Bool {true}
    
    /// キャンバス上端からセーフエリアへの制約
    @IBOutlet private weak var canvasTopConstraintToSafeArea: NSLayoutConstraint!
    
    /// キャンバス上端からトップバー下端への制約
    @IBOutlet private weak var canvasTopConstraintToTopbar: NSLayoutConstraint!
    
    /// デバイスがノッチを持つかどうか
    private var hasNotch: Bool {
        return view.safeAreaInsets.bottom > 0
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    override func updateViewConstraints() {
        // ノッチがあるならキャンバスをトップビューまで、なければセーフエリアまで広げる
        canvasTopConstraintToSafeArea.priority = hasNotch ? .defaultLow : .defaultHigh
        canvasTopConstraintToTopbar.priority = hasNotch ? .defaultHigh : .defaultLow
        
        super.updateViewConstraints()
    }

}

