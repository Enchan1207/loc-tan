//
//  StickerViewController.swift
//  loc-tan
//
//  Created by EnchantCode on 2024/07/20.
//

import UIKit

class StickerViewController: UIViewController {
    
    private let model: StickerModel
    
    private var isActive: Bool = false
    
    weak var delegate: StickerViewControllerDelegate?
    
    // MARK: - Initializing
    
    init(model: StickerModel){
        self.model = model
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        guard let model = coder.decodeObject(forKey: "model") as? StickerModel else {return nil}
        self.model = model
        super.init(coder: coder)
    }
    
    override func encode(with coder: NSCoder) {
        super.encode(with: coder)
        coder.encode(model, forKey: "model")
    }
    
    override func encodeRestorableState(with coder: NSCoder) {
        super.encodeRestorableState(with: coder)
        coder.encode(model, forKey: "model")
    }
    
    // MARK: - View lifecycle
    
    override func loadView() {
        let sticker = StickerView(frame: .zero, image: model.image)
        sticker.setWidth(model.width)
        sticker.setCenter(model.center)
        sticker.setAngle(model.angle)
        
        self.view = sticker
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(onTapSticker))
        self.view.addGestureRecognizer(tapGesture)
    }
    
    // MARK: - Gestures
    
    @objc private func onTapSticker(_ gesture: UITapGestureRecognizer){        
        // 活性化されていないなら要求する
        if !isActive {
            delegate?.stickerViewDidRequireActivation(self)
        }
        
        // TODO: 活性化されたうえでさらにタップされた場合は、「削除」「複製」などのメニューを表示する
    }
    
    
    func activate() async {
        await (self.view as! StickerView).setStatusRing(true)
        isActive = true
    }
    
    func deactivate() async {
        await (self.view as! StickerView).setStatusRing(false)
        isActive = false
    }

}
