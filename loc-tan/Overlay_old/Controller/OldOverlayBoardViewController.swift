//
//  OldOverlayBoardViewController.swift
//  loc-tan
//
//  Created by EnchantCode on 2024/07/17.
//

import UIKit

class OldOverlayBoardViewController: UIViewController {
    
    private var boardModel: OldOverlayBoardModel!
    private var objectControllers: [OldOverlayObjectController] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        boardModel = .init()
        setupGestures()
    }
    
    private func setupGestures() {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        view.addGestureRecognizer(panGesture)
    }
    
    func addObject(at center: CGPoint, with image: UIImage){
        let id = UUID().uuidString
        let newObject = OldOverlayObjectModel(id: id, center: center, image: image)
        boardModel.addObject(newObject)
        
        let newController = OldOverlayObjectController(model: newObject)
        objectControllers.append(newController)
        
        let overlayView = newController.view
        overlayView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(overlayView)
        
        NSLayoutConstraint.activate([
            //
        ])
    }
    
    
    @objc private func handlePanGesture(_ sender: UIPanGestureRecognizer) {
        guard let selectedObject = boardModel.getSelectedOverlayObject() else { return }
        guard let overlayController = objectControllers.first(where: { $0.model.id == selectedObject.id }) else { return }
        let overlayView = overlayController.view
        let translation = sender.translation(in: view)
//        
//        switch sender.state {
//        case .began, .changed:
//            let newX = overlayView.leadingConstraint.constant + translation.x
//            let newY = overlayView.topConstraint.constant + translation.y
//            overlayView.updatePosition(x: newX, y: newY)
//            sender.setTranslation(.zero, in: view)
//        case .ended:
//            let finalPosition = CGPoint(x: overlayView.leadingConstraint.constant, y: overlayView.topConstraint.constant)
//            overlayController.updatePosition(to: finalPosition)
//        default:
//            break
//        }
    }
    
    
    func handleTapGesture(_ sender: UITapGestureRecognizer, for overlayView: OldOverlayObjectView) {
        deselectAllOverlayObjects()
        if let objectController = objectControllers.first(where: { $0.view == overlayView }) {
            objectController.select()
            boardModel.selectObject(with: objectController.model.id)
        }
    }
    
    private func deselectAllOverlayObjects() {
        boardModel.deselectObject()
        objectControllers.forEach { $0.deselect() }
    }
    
}
