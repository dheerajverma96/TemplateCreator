//
//  PropertiesViewModel.swift
//  DragAndDropTemplateCreator
//
//  Created by Dheeraj Verma on 17/08/25.
//

import SwiftUI
import Combine

// MARK: - Properties ViewModel
class PropertiesViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var selectedComponent: CanvasComponent?
    @Published var editingProperties: ComponentProperties = ComponentProperties()
    
    // MARK: - Private Properties
    private weak var editorViewModel: EditorViewModel?
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    init(editorViewModel: EditorViewModel) {
        self.editorViewModel = editorViewModel
        setupBindings()
    }
    
    // MARK: - Private Methods
    private func setupBindings() {
        // Listen to selected component changes
        guard let editorViewModel = editorViewModel else { return }
        
        editorViewModel.$selectedComponentId
            .combineLatest(editorViewModel.$components)
            .map { selectedId, components in
                components.first { $0.id == selectedId }
            }
            .sink { [weak self] component in
                self?.selectedComponent = component
                if let component = component {
                    self?.editingProperties = component.properties
                }
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Public Methods
    func updateProperty<T>(_ keyPath: WritableKeyPath<ComponentProperties, T>, value: T) {
        editingProperties[keyPath: keyPath] = value
        
        guard let componentId = selectedComponent?.id else { return }
        editorViewModel?.updateComponentProperties(componentId, properties: editingProperties)
    }
    
    func deleteSelectedComponent() {
        editorViewModel?.deleteSelectedComponent()
    }
    
    // MARK: - Text Properties
    func updateText(_ text: String) {
        updateProperty(\.text, value: text)
    }
    
    func updateFontSize(_ size: Double) {
        updateProperty(\.fontSize, value: size)
    }
    
    func updateFontWeight(_ weight: ComponentProperties.FontWeight) {
        updateProperty(\.fontWeight, value: weight)
    }
    
    func updateTextColor(_ color: ColorData) {
        updateProperty(\.textColor, value: color)
    }
    
    func updateTextAlignment(_ alignment: ComponentProperties.TextAlignment) {
        updateProperty(\.textAlign, value: alignment)
    }
    
    // MARK: - TextArea Properties
    func updateTextAreaContent(_ content: String) {
        updateProperty(\.textAreaContent, value: content)
    }
    
    // MARK: - Image Properties
    func updateImageURL(_ url: String) {
        updateProperty(\.imageURL, value: url)
    }
    
    func updateAltText(_ altText: String) {
        updateProperty(\.altText, value: altText)
    }
    
    func updateObjectFit(_ objectFit: ComponentProperties.ObjectFit) {
        updateProperty(\.objectFit, value: objectFit)
    }
    
    func updateBorderRadius(_ radius: Double) {
        updateProperty(\.borderRadius, value: radius)
    }
    
    func updateWidth(_ width: Double) {
        updateProperty(\.width, value: width)
    }
    
    func updateHeight(_ height: Double) {
        updateProperty(\.height, value: height)
    }
    
    // MARK: - Button Properties
    func updateButtonText(_ text: String) {
        updateProperty(\.buttonText, value: text)
    }
    
    func updateURL(_ url: String) {
        updateProperty(\.url, value: url)
    }
    
    func updatePadding(_ padding: Double) {
        updateProperty(\.padding, value: padding)
    }
    
    func updateBackgroundColor(_ color: ColorData) {
        updateProperty(\.backgroundColor, value: color)
    }
}