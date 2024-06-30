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
            toolbar.dataSource = self
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // TODO: 別にこれでも構わないんだけど、いちいちリロードしないと初期アイテムすら設定できないのは正直どうなの?
        toolbar.reloadItemStack()
    }
    
}

extension ViewController: ToolBarViewDelegate, ToolBarViewDataSource {
    
    func modeWillSwitch(_ view: ToolBarView, to mode: ToolBarMode) {
        print("mode will switch to \(mode)")
    }
    
    func modeDidSwitch(_ view: ToolBarView, to mode: ToolBarMode) {
        print("mode switched to \(mode)")
    }
    
    func toolbar(_ view: ToolBarView, didTapItem type: ToolBarItemType) {
        print("item \(type) tapped")
    }
    
    func toolbar(_ view: ToolBarView, buttonTypesFor mode: ToolBarMode) -> [ToolBarItemType] {
        switch mode {
        case .normal:
            return [.config]
        case .edit:
            return [.rotate, .resize, .add]
        }
    }
    
}
