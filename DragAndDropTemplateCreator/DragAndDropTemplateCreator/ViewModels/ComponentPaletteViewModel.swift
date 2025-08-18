//
//  ComponentPaletteViewModel.swift
//  DragAndDropTemplateCreator
//
//  Created by Dheeraj Verma on 17/08/25.
//

import SwiftUI

// MARK: - Component Palette ViewModel
class ComponentPaletteViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var availableComponents: [ComponentType] = ComponentType.allCases
    @Published var draggedComponent: ComponentType?
    
    // MARK: - Private Properties
    private weak var editorViewModel: EditorViewModel?
    
    // MARK: - Initialization
    init(editorViewModel: EditorViewModel) {
        self.editorViewModel = editorViewModel
    }
    
    // MARK: - Public Methods
    func startDragging(_ componentType: ComponentType) {
        draggedComponent = componentType
    }
    
    func endDragging() {
        draggedComponent = nil
    }
    
    func addComponentToCanvas(_ type: ComponentType, at position: CGPoint) {
        editorViewModel?.addComponent(type, at: position)
    }
    
    func canDropComponent(at location: CGPoint, screenWidth: CGFloat) -> Bool {
        let canvasStart = screenWidth * 0.2
        let canvasEnd = screenWidth * 0.8
        return location.x >= canvasStart && location.x <= canvasEnd
    }
    
    func convertToCanvasPosition(from globalPosition: CGPoint, screenWidth: CGFloat) -> CGPoint {
        let canvasStart = screenWidth * 0.2
        let canvasX = globalPosition.x - canvasStart
        let canvasY = globalPosition.y - 100 // Adjust for navigation
        return CGPoint(x: canvasX, y: canvasY)
    }
}