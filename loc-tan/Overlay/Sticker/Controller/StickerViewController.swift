//
//  StickerViewController.swift
//  loc-tan
//
//  Created by EnchantCode on 2024/07/20.
//

import UIKit

class StickerViewController: UIViewController {
    
    private let model: StickerModel
    
    weak var delegate: StickerViewControllerDelegate?
    
    // MARK: - Initializing
    
    init(model: StickerModel){
        self.model = model
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        // TODO: 実装
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - View lifecycle
    
    override func loadView() {
        let sticker = StickerView(frame: .zero, image: model.image)
        sticker.setWidth(model.width)
        
        self.view = sticker
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let tapGesture = UITapGestureRecognizer(target: self.view, action: #selector(onTapSticker))
        self.view.addGestureRecognizer(tapGesture)
    }
    
    // MARK: - Gestures
    
    @objc private func onTapSticker(_ gesture: UITapGestureRecognizer){
        if gesture.state == .began {
            delegate?.stickerViewDidRequireActivation(self)
        }
    }
    
    
    func activate() async {
        await (self.view as! StickerView).setStatusRing(true)
    }
    
    func deactivate() async {
        await (self.view as! StickerView).setStatusRing(false)
    }

}
