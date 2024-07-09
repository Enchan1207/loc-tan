//
//  ViewController.swift
//  loc-tan
//
//  Created by EnchantCode on 2024/06/15.
//

import UIKit

class ViewController: UIViewController {
    
    // MARK: - Properties
    
    let imageIdentifiers = [
        "dive_stage",
        "rainbow_bridge_night",
        "rainbow_bridge_noon",
        "tokyo_skytree"
    ]
    
    // MARK: - GUI Components
    
    /// オーバーレイオブジェクトを配置するボード
    @IBOutlet weak var overlayBoard: OverlayBoardView!
    
    // MARK: - View lifecycles

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    
    @IBAction func onTapAdd(_ sender: Any) {
        overlayBoard.addObject(.init(named: imageIdentifiers.randomElement()!)!)
    }
    
}

