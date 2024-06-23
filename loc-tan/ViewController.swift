//
//  ViewController.swift
//  loc-tan
//
//  Created by EnchantCode on 2024/06/15.
//

import UIKit

class ViewController: UIViewController {
    
    /// ツールバー
    @IBOutlet private weak var toolbar: ToolBarView! {
        didSet {
            toolbar.delegate = self
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

}

extension ViewController: ToolBarViewDelegate {
    
    func modeWillSwitch(_ view: ToolBarView, to mode: ToolBarMode) {
        print("mode will switch to \(mode)")
    }
    
    func modeDidSwitch(_ view: ToolBarView, to mode: ToolBarMode) {
        print("mode switched to \(mode)")
    }
    
    func toolbar(_ view: ToolBarView, didTapItem type: ToolBarItemType) {
        print("item \(type) tapped")
    }
    
}
