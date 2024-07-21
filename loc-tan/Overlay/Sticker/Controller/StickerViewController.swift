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
    
    // MARK: - Gesture history
    
    private var panGestureTranslation: CGPoint = .zero
    
    private var pinchGestureScale: CGFloat = 1.0
    
    private var rotationGestureAngle: CGFloat = 0.0
    
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
    
    // MARK: - State modification
    
    func activate() async {
        await (self.view as! StickerView).setStatusRing(true)
        isActive = true
    }
    
    func deactivate() async {
        await (self.view as! StickerView).setStatusRing(false)
        isActive = false
    }
    
    // MARK: - Gestures
    
    @objc private func onTapSticker(_ gesture: UITapGestureRecognizer){        
        // 活性化されていないなら要求する
        if !isActive {
            delegate?.stickerViewDidRequireActivation(self)
        }
        
        // TODO: 活性化されたうえでさらにタップされた場合は、「削除」「複製」などのメニューを表示する
    }
    
    func onPanSticker(_ gesture: UIPanGestureRecognizer){
        switch gesture.state {
        case .began:
            print("pan: began (current:\(view.center))")
            panGestureTranslation = .zero
            fallthrough
            
        case .changed:
            let translation = gesture.translation(in: view.superview)
            panGestureTranslation += translation
            view.center += translation
            break
            
        case .ended:
            model.center += panGestureTranslation
            print("pan: end (diff:\(panGestureTranslation) view-center:\(view.center) model-center:\(model.center)")
            (view as! StickerView).setCenter(model.center)
            panGestureTranslation = .zero
            break
            
        case .cancelled:
            view.center -= panGestureTranslation
            panGestureTranslation = .zero
            break
        
        default:
            break
        }
        gesture.setTranslation(.zero, in: view)
    }
    
    func onPinchSticker(_ gesture: UIPinchGestureRecognizer){
        switch gesture.state {
        case .began:
            print("scale: began")
            pinchGestureScale = 1.0
            fallthrough
            
        case .changed:
            let scaleDiff = gesture.scale
            pinchGestureScale *= scaleDiff
            view.transform = view.transform.scaledBy(x: scaleDiff, y: scaleDiff)
            break
            
        case .ended:
            print("pan: end (diff:\(pinchGestureScale) current:\(view.center))")
            view.transform = view.transform.scaledBy(x: 1.0 / pinchGestureScale, y: 1.0 / pinchGestureScale)
            model.width *= pinchGestureScale
            (view as! StickerView).setWidth(model.width)
            pinchGestureScale = 1.0
            break
            
        case .cancelled:
            view.center -= panGestureTranslation
            pinchGestureScale = 1.0
            break
        
        default:
            break
        }
        gesture.scale = 1.0
    }
    
    func onRotateSticker(_ gesture: UIRotationGestureRecognizer){
        switch gesture.state {
        case .began:
            print("rot: began")
            rotationGestureAngle = 0.0
            fallthrough
            
        case .changed:
            let rotDiff = gesture.rotation
            rotationGestureAngle += rotDiff
            view.transform = view.transform.rotated(by: rotDiff)
            break
            
        case .ended:
            print("rot: end (diff:\(rotationGestureAngle)")
            let newAngle = (model.angle + rotationGestureAngle).truncatingRemainder(dividingBy: 2 * .pi)
            model.angle = newAngle >= 0 ? newAngle : newAngle + 2 * .pi
            rotationGestureAngle = 0.0
            break
            
        case .cancelled:
            view.transform = view.transform.rotated(by: -rotationGestureAngle)
            rotationGestureAngle = 0.0
            break
            
        default:
            break
        }
        gesture.rotation = 0.0
    }


}
