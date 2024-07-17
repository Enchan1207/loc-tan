//
//  OverlayBoardModel.swift
//  loc-tan
//
//  Created by EnchantCode on 2024/07/17.
//

import Foundation

class OverlayBoardModel {
    
    private (set) public var overlayObjects: [OverlayObjectModel]
    var selectedObjectID: String?
    
    init(){
        overlayObjects = []
        selectedObjectID = nil
    }
    
    func addObject(_ object: OverlayObjectModel){
        overlayObjects.append(object)
    }
    
    func selectObject(with id: String){
        guard (overlayObjects.contains(where: {$0.id == id})) else {return}
        selectedObjectID = id
    }
    
    func deselectObject(){
        selectedObjectID = nil
    }
    
    func getSelectedOverlayObject() -> OverlayObjectModel? {
        guard let id = selectedObjectID else { return nil }
        return overlayObjects.first { $0.id == id }
    }
    
}
