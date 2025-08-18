//
//  EditorViewModel.swift
//  DragAndDropTemplateCreator
//
//  Created by Dheeraj Verma on 17/08/25.
//

import SwiftUI
import Combine

// MARK: - Editor ViewModel
class EditorViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var components: [CanvasComponent] = []
    @Published var selectedComponentId: UUID?
    @Published var isPreviewMode: Bool = false
    @Published var previewDevice: PreviewDevice = .mobile
    
    // MARK: - Private Properties
    private var history: [EditorSnapshot] = []
    private var currentHistoryIndex: Int = -1
    private let maxHistorySize = 50
    private let persistenceService = PersistenceService()
    
    // MARK: - Computed Properties
    var selectedComponent: CanvasComponent? {
        components.first { $0.id == selectedComponentId }
    }
    
    var canUndo: Bool {
        currentHistoryIndex > 0
    }
    
    var canRedo: Bool {
        currentHistoryIndex < history.count - 1
    }
    
    var componentCount: Int {
        components.count
    }
    
    // MARK: - Initialization
    init() {
        loadFromPersistence()
    }
    
    // MARK: - Component Management
    func selectComponent(_ component: CanvasComponent) {
        selectedComponentId = component.id
    }
    
    func deselectComponent() {
        selectedComponentId = nil
    }
    
    func addComponent(_ type: ComponentType, at position: CGPoint) {
        let newComponent = CanvasComponent(
            type: type,
            position: position,
            properties: ComponentProperties()
        )
        components.append(newComponent)
        selectedComponentId = newComponent.id
        saveSnapshot()
    }
    
    func updateComponentPosition(_ componentId: UUID, to position: CGPoint) {
        if let index = components.firstIndex(where: { $0.id == componentId }) {
            components[index].position = position
            saveSnapshot()
        }
    }
    
    func updateComponentProperties(_ componentId: UUID, properties: ComponentProperties) {
        if let index = components.firstIndex(where: { $0.id == componentId }) {
            components[index].properties = properties
            saveSnapshot()
        }
    }
    
    func deleteSelectedComponent() {
        if let selectedId = selectedComponentId {
            components.removeAll { $0.id == selectedId }
            selectedComponentId = nil
            saveSnapshot()
        }
    }
    
    func clearAllComponents() {
        components.removeAll()
        selectedComponentId = nil
        saveSnapshot()
    }
    
    // MARK: - History Management
    func undo() {
        guard canUndo else { return }
        currentHistoryIndex -= 1
        loadSnapshot(history[currentHistoryIndex])
    }
    
    func redo() {
        guard canRedo else { return }
        currentHistoryIndex += 1
        loadSnapshot(history[currentHistoryIndex])
    }
    
    private func saveSnapshot() {
        let snapshot = EditorSnapshot(components: components)
        
        // Remove any history beyond current index
        if currentHistoryIndex < history.count - 1 {
            history.removeSubrange((currentHistoryIndex + 1)...)
        }
        
        history.append(snapshot)
        currentHistoryIndex += 1
        
        // Limit history to maxHistorySize
        if history.count > maxHistorySize {
            history.removeFirst()
            currentHistoryIndex = min(currentHistoryIndex, maxHistorySize - 1)
        }
        
        saveToPersistence()
    }
    
    private func loadSnapshot(_ snapshot: EditorSnapshot) {
        components = snapshot.components
        selectedComponentId = nil
    }
    
    // MARK: - Preview Management
    func togglePreviewMode() {
        isPreviewMode.toggle()
    }
    
    func setPreviewDevice(_ device: PreviewDevice) {
        previewDevice = device
    }
    
    // MARK: - Persistence
    private func saveToPersistence() {
        persistenceService.saveComponents(components)
    }
    
    private func loadFromPersistence() {
        components = persistenceService.loadComponents()
    }
    
    // MARK: - Export
    func generateHTML() -> String {
        HTMLGenerator.generateHTML(from: components)
    }
}

// MARK: - Persistence Service
class PersistenceService {
    private let componentsKey = "editorComponents"
    
    func saveComponents(_ components: [CanvasComponent]) {
        if let data = try? JSONEncoder().encode(components) {
            UserDefaults.standard.set(data, forKey: componentsKey)
        }
    }
    
    func loadComponents() -> [CanvasComponent] {
        guard let data = UserDefaults.standard.data(forKey: componentsKey),
              let savedComponents = try? JSONDecoder().decode([CanvasComponent].self, from: data) else {
            return []
        }
        return savedComponents
    }
}

// MARK: - HTML Generator
struct HTMLGenerator {
    static func generateHTML(from components: [CanvasComponent]) -> String {
        var html = """
        <!DOCTYPE html>
        <html lang="en">
        <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <title>Generated Template</title>
            <style>
                body { margin: 0; padding: 20px; font-family: Arial, sans-serif; }
                .canvas { position: relative; width: 100%; min-height: 600px; background: #f5f5f5; }
                .component { position: absolute; }
            </style>
        </head>
        <body>
            <div class="canvas">
        """
        
        for component in components {
            html += generateComponentHTML(component)
        }
        
        html += """
            </div>
        </body>
        </html>
        """
        
        return html
    }
    
    private static func generateComponentHTML(_ component: CanvasComponent) -> String {
        let props = component.properties
        let position = "left: \(Int(component.position.x))px; top: \(Int(component.position.y))px;"
        
        switch component.type {
        case .text:
            return """
            <div class="component" style="\(position)">
                <span style="font-size: \(props.fontSize)px; font-weight: \(props.fontWeight == .bold ? "700" : "400"); color: rgba(\(Int(props.textColor.red * 255)), \(Int(props.textColor.green * 255)), \(Int(props.textColor.blue * 255)), \(props.textColor.alpha));">\(props.text)</span>
            </div>
            """
        case .textArea:
            return """
            <div class="component" style="\(position)">
                <div style="font-size: \(props.fontSize)px; color: rgba(\(Int(props.textColor.red * 255)), \(Int(props.textColor.green * 255)), \(Int(props.textColor.blue * 255)), \(props.textColor.alpha)); text-align: \(props.textAlign.rawValue.lowercased());">\(props.textAreaContent)</div>
            </div>
            """
        case .image:
            return """
            <div class="component" style="\(position)">
                <img src="\(props.imageURL)" alt="\(props.altText)" style="width: \(props.width)px; height: \(props.height)px; border-radius: \(props.borderRadius)px; object-fit: \(props.objectFit.rawValue.lowercased());" />
            </div>
            """
        case .button:
            return """
            <div class="component" style="\(position)">
                <a href="\(props.url)" style="display: inline-block; padding: \(props.padding)px; background-color: rgba(\(Int(props.backgroundColor.red * 255)), \(Int(props.backgroundColor.green * 255)), \(Int(props.backgroundColor.blue * 255)), \(props.backgroundColor.alpha)); color: rgba(\(Int(props.textColor.red * 255)), \(Int(props.textColor.green * 255)), \(Int(props.textColor.blue * 255)), \(props.textColor.alpha)); text-decoration: none; border-radius: \(props.borderRadius)px; font-size: \(props.fontSize)px;">\(props.buttonText)</a>
            </div>
            """
        }
    }
}