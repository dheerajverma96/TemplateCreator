//
//  PropertiesViewModelTests.swift
//  DragAndDropTemplateCreatorTests
//
//  Created by Dheeraj Verma on 17/08/25.
//

import XCTest
import Combine
@testable import DragAndDropTemplateCreator
import SwiftUI

final class PropertiesViewModelTests: XCTestCase {
    
    var editorViewModel: EditorViewModel!
    var propertiesViewModel: PropertiesViewModel!
    var cancellables: Set<AnyCancellable>!
    
    override func setUpWithError() throws {
        super.setUp()
        editorViewModel = EditorViewModel()
        propertiesViewModel = PropertiesViewModel(editorViewModel: editorViewModel)
        cancellables = Set<AnyCancellable>()
        
        // Clear UserDefaults for clean test state
        UserDefaults.standard.removeObject(forKey: "editorComponents")
    }
    
    override func tearDownWithError() throws {
        cancellables = nil
        propertiesViewModel = nil
        editorViewModel = nil
        UserDefaults.standard.removeObject(forKey: "editorComponents")
        super.tearDown()
    }
    
    // MARK: - Initialization Tests
    
    func testInitialState() {
        XCTAssertNil(propertiesViewModel.selectedComponent)
        XCTAssertEqual(propertiesViewModel.editingProperties.text, "Sample Text")
        XCTAssertEqual(propertiesViewModel.editingProperties.fontSize, 16)
    }
    
    func testInitializationWithEditorViewModel() {
        // Test that the properties view model correctly references the editor view model
        XCTAssertNotNil(propertiesViewModel)
    }
    
    // MARK: - Component Selection Binding Tests
    
    func testSelectedComponentUpdatesWhenComponentSelected() {
        let expectation = XCTestExpectation(description: "Selected component updated")
        
        // Subscribe to selected component changes
        propertiesViewModel.$selectedComponent
            .dropFirst() // Skip initial nil value
            .sink { component in
                if component != nil {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        // When
        editorViewModel.addComponent(.text, at: CGPoint(x: 0, y: 0))
        
        // Then
        wait(for: [expectation], timeout: 1.0)
        XCTAssertNotNil(propertiesViewModel.selectedComponent)
        XCTAssertEqual(propertiesViewModel.selectedComponent?.type, .text)
    }
    
    func testEditingPropertiesUpdatesWhenComponentSelected() {
        // Given
        editorViewModel.addComponent(.text, at: CGPoint(x: 0, y: 0))
        let component = editorViewModel.components[0]
        
        var customProperties = ComponentProperties()
        customProperties.text = "Custom Text"
        customProperties.fontSize = 24
        editorViewModel.updateComponentProperties(component.id, properties: customProperties)
        
        // Allow time for reactive updates
        let expectation = XCTestExpectation(description: "Properties updated")
        DispatchQueue.main.async {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
        
        // Then
        XCTAssertEqual(propertiesViewModel.editingProperties.text, "Custom Text")
        XCTAssertEqual(propertiesViewModel.editingProperties.fontSize, 24)
    }
    
//    func testSelectedComponentClearsWhenComponentDeselected() {
//        // Given
//        editorViewModel.addComponent(.text, at: CGPoint(x: 0, y: 0))
//        
//        // Allow time for reactive updates
//        let setupExpectation = XCTestExpectation(description: "Component selected")
//        DispatchQueue.main.async {
//            setupExpectation.fulfill()
//        }
//        wait(for: [setupExpectation], timeout: 1.0)
//        
//        XCTAssertNotNil(propertiesViewModel.selectedComponent)
//        
//        // When
//        editorViewModel.deselectComponent()
//        
//        // Allow time for reactive updates
//        let clearExpectation = XCTestExpectation(description: "Component deselected")
//        DispatchQueue.main.async {
//            clearExpectation.fulfill()
//        }
//        wait(for: [clearExpectation], timeout: 1.0)
//        
//        // Then
//        XCTAssertNil(propertiesViewModel.selectedComponent)
//    }
    
    // MARK: - Property Update Tests
    
    func testUpdateText() {
        // Given
        editorViewModel.addComponent(.text, at: CGPoint(x: 0, y: 0))
        let component = editorViewModel.components[0]
        
        // When
        propertiesViewModel.updateText("New Text")
        
        // Then
        XCTAssertEqual(propertiesViewModel.editingProperties.text, "New Text")
        
        // Verify it updates the editor view model
        let updatedComponent = editorViewModel.components.first { $0.id == component.id }
        XCTAssertEqual(updatedComponent?.properties.text, "New Text")
    }
    
    func testUpdateFontSize() {
        // Given
        editorViewModel.addComponent(.text, at: CGPoint(x: 0, y: 0))
        
        // When
        propertiesViewModel.updateFontSize(20)
        
        // Then
        XCTAssertEqual(propertiesViewModel.editingProperties.fontSize, 20)
    }
    
    func testUpdateFontWeight() {
        // Given
        editorViewModel.addComponent(.text, at: CGPoint(x: 0, y: 0))
        
        // When
        propertiesViewModel.updateFontWeight(.bold)
        
        // Then
        XCTAssertEqual(propertiesViewModel.editingProperties.fontWeight, .bold)
    }
    
    func testUpdateTextColor() {
        // Given
        editorViewModel.addComponent(.text, at: CGPoint(x: 0, y: 0))
        let newColor = ColorData(red: 1.0, green: 0.0, blue: 0.0)
        
        // When
        propertiesViewModel.updateTextColor(newColor)
        
        // Then
        XCTAssertEqual(propertiesViewModel.editingProperties.textColor, newColor)
    }
    
    func testUpdateTextAlignment() {
        // Given
        editorViewModel.addComponent(.textArea, at: CGPoint(x: 0, y: 0))
        
        // When
        propertiesViewModel.updateTextAlignment(.center)
        
        // Then
        XCTAssertEqual(propertiesViewModel.editingProperties.textAlign, .center)
    }
    
    // MARK: - TextArea Property Tests
    
    func testUpdateTextAreaContent() {
        // Given
        editorViewModel.addComponent(.textArea, at: CGPoint(x: 0, y: 0))
        
        // When
        propertiesViewModel.updateTextAreaContent("New TextArea Content")
        
        // Then
        XCTAssertEqual(propertiesViewModel.editingProperties.textAreaContent, "New TextArea Content")
    }
    
    // MARK: - Image Property Tests
    
    func testUpdateImageURL() {
        // Given
        editorViewModel.addComponent(.image, at: CGPoint(x: 0, y: 0))
        
        // When
        propertiesViewModel.updateImageURL("https://example.com/image.jpg")
        
        // Then
        XCTAssertEqual(propertiesViewModel.editingProperties.imageURL, "https://example.com/image.jpg")
    }
    
    func testUpdateAltText() {
        // Given
        editorViewModel.addComponent(.image, at: CGPoint(x: 0, y: 0))
        
        // When
        propertiesViewModel.updateAltText("Alternative text")
        
        // Then
        XCTAssertEqual(propertiesViewModel.editingProperties.altText, "Alternative text")
    }
    
    func testUpdateObjectFit() {
        // Given
        editorViewModel.addComponent(.image, at: CGPoint(x: 0, y: 0))
        
        // When
        propertiesViewModel.updateObjectFit(.contain)
        
        // Then
        XCTAssertEqual(propertiesViewModel.editingProperties.objectFit, .contain)
    }
    
    func testUpdateBorderRadius() {
        // Given
        editorViewModel.addComponent(.image, at: CGPoint(x: 0, y: 0))
        
        // When
        propertiesViewModel.updateBorderRadius(10)
        
        // Then
        XCTAssertEqual(propertiesViewModel.editingProperties.borderRadius, 10)
    }
    
    func testUpdateWidth() {
        // Given
        editorViewModel.addComponent(.image, at: CGPoint(x: 0, y: 0))
        
        // When
        propertiesViewModel.updateWidth(200)
        
        // Then
        XCTAssertEqual(propertiesViewModel.editingProperties.width, 200)
    }
    
    func testUpdateHeight() {
        // Given
        editorViewModel.addComponent(.image, at: CGPoint(x: 0, y: 0))
        
        // When
        propertiesViewModel.updateHeight(150)
        
        // Then
        XCTAssertEqual(propertiesViewModel.editingProperties.height, 150)
    }
    
    // MARK: - Button Property Tests
    
    func testUpdateButtonText() {
        // Given
        editorViewModel.addComponent(.button, at: CGPoint(x: 0, y: 0))
        
        // When
        propertiesViewModel.updateButtonText("Click Me")
        
        // Then
        XCTAssertEqual(propertiesViewModel.editingProperties.buttonText, "Click Me")
    }
    
    func testUpdateURL() {
        // Given
        editorViewModel.addComponent(.button, at: CGPoint(x: 0, y: 0))
        
        // When
        propertiesViewModel.updateURL("https://example.com")
        
        // Then
        XCTAssertEqual(propertiesViewModel.editingProperties.url, "https://example.com")
    }
    
    func testUpdatePadding() {
        // Given
        editorViewModel.addComponent(.button, at: CGPoint(x: 0, y: 0))
        
        // When
        propertiesViewModel.updatePadding(20)
        
        // Then
        XCTAssertEqual(propertiesViewModel.editingProperties.padding, 20)
    }
    
    func testUpdateBackgroundColor() {
        // Given
        editorViewModel.addComponent(.button, at: CGPoint(x: 0, y: 0))
        let newColor = ColorData(red: 0.0, green: 1.0, blue: 0.0)
        
        // When
        propertiesViewModel.updateBackgroundColor(newColor)
        
        // Then
        XCTAssertEqual(propertiesViewModel.editingProperties.backgroundColor, newColor)
    }
    
    // MARK: - Generic Property Update Tests
    
    func testGenericPropertyUpdate() {
        // Given
        editorViewModel.addComponent(.text, at: CGPoint(x: 0, y: 0))
        
        // When
        propertiesViewModel.updateProperty(\.fontSize, value: 30)
        
        // Then
        XCTAssertEqual(propertiesViewModel.editingProperties.fontSize, 30)
    }
    
    func testGenericPropertyUpdateWithString() {
        // Given
        editorViewModel.addComponent(.text, at: CGPoint(x: 0, y: 0))
        
        // When
        propertiesViewModel.updateProperty(\.text, value: "Generic Update")
        
        // Then
        XCTAssertEqual(propertiesViewModel.editingProperties.text, "Generic Update")
    }
    
    // MARK: - Delete Component Tests
    
    func testDeleteSelectedComponent() {
        // Given
        editorViewModel.addComponent(.text, at: CGPoint(x: 0, y: 0))
        editorViewModel.addComponent(.button, at: CGPoint(x: 100, y: 100))
        let initialCount = editorViewModel.components.count
        
        // When
        propertiesViewModel.deleteSelectedComponent()
        
        // Then
        XCTAssertEqual(editorViewModel.components.count, initialCount - 1)
        XCTAssertNil(editorViewModel.selectedComponentId)
    }
    
    // MARK: - Multiple Component Selection Tests
    
//    func testSwitchingBetweenComponents() {
//        // Given
//        editorViewModel.addComponent(.text, at: CGPoint(x: 0, y: 0))
//        let textComponent = editorViewModel.components[0]
//        
//        var textProperties = ComponentProperties()
//        textProperties.text = "Text Component"
//        editorViewModel.updateComponentProperties(textComponent.id, properties: textProperties)
//        
//        editorViewModel.addComponent(.button, at: CGPoint(x: 100, y: 100))
//        let buttonComponent = editorViewModel.components[1]
//        
//        var buttonProperties = ComponentProperties()
//        buttonProperties.buttonText = "Button Component"
//        editorViewModel.updateComponentProperties(buttonComponent.id, properties: buttonProperties)
//        
//        // When selecting text component
//        editorViewModel.selectComponent(textComponent)
//        
//        // Allow reactive updates
//        let textExpectation = XCTestExpectation(description: "Text component selected")
//        DispatchQueue.main.async {
//            textExpectation.fulfill()
//        }
//        wait(for: [textExpectation], timeout: 1.0)
//        
//        // Then
//        XCTAssertEqual(propertiesViewModel.selectedComponent?.type, .text)
//        XCTAssertEqual(propertiesViewModel.editingProperties.text, "Text Component")
//        
//        // When selecting button component
//        editorViewModel.selectComponent(buttonComponent)
//        
//        // Allow reactive updates
//        let buttonExpectation = XCTestExpectation(description: "Button component selected")
//        DispatchQueue.main.async {
//            buttonExpectation.fulfill()
//        }
//        wait(for: [buttonExpectation], timeout: 1.0)
//        
//        // Then
//        XCTAssertEqual(propertiesViewModel.selectedComponent?.type, .button)
//        XCTAssertEqual(propertiesViewModel.editingProperties.buttonText, "Button Component")
//    }
    
    // MARK: - Edge Cases Tests
    
    func testPropertyUpdateWithoutSelectedComponent() {
        // Given - no component selected
        XCTAssertNil(propertiesViewModel.selectedComponent)
        
        // When
        propertiesViewModel.updateText("No Component Text")
        
        // Then - should not crash
        XCTAssertEqual(propertiesViewModel.editingProperties.text, "No Component Text")
    }
    
    func testDeleteWithoutSelectedComponent() {
        // Given - no component selected
        XCTAssertNil(propertiesViewModel.selectedComponent)
        let initialCount = editorViewModel.components.count
        
        // When
        propertiesViewModel.deleteSelectedComponent()
        
        // Then - should not crash, no change in component count
        XCTAssertEqual(editorViewModel.components.count, initialCount)
    }
    
    // MARK: - Reactive Updates Tests
    
    func testReactivePropertyUpdates() {
        let expectation = XCTestExpectation(description: "Properties updated reactively")
        
        // Given
        editorViewModel.addComponent(.text, at: CGPoint(x: 0, y: 0))
        let component = editorViewModel.components[0]
        
        // Subscribe to editing properties changes
        propertiesViewModel.$editingProperties
            .dropFirst() // Skip initial value
            .sink { properties in
                if properties.text == "Reactive Text" {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        // When - update through editor view model
        var newProperties = ComponentProperties()
        newProperties.text = "Reactive Text"
        editorViewModel.updateComponentProperties(component.id, properties: newProperties)
        
        // Allow time for reactive update
        DispatchQueue.main.async {
            // Trigger selection change to update properties
            self.editorViewModel.selectComponent(component)
        }
        
        // Then
        wait(for: [expectation], timeout: 2.0)
    }
    
    // MARK: - Memory Management Tests
    
    func testMemoryCleanup() {
        // Given
        weak var weakPropertiesViewModel = propertiesViewModel
        weak var weakEditorViewModel = editorViewModel
        
        // When
        propertiesViewModel = nil
        editorViewModel = nil
        
        // Then - should be deallocated
        XCTAssertNil(weakPropertiesViewModel)
        XCTAssertNil(weakEditorViewModel)
    }
    
    // MARK: - Integration Tests
    
    func testCompletePropertyEditingWorkflow() {
        // Given - Add a text component
        editorViewModel.addComponent(.text, at: CGPoint(x: 100, y: 200))
        
        // Allow initial setup
        let setupExpectation = XCTestExpectation(description: "Initial setup")
        DispatchQueue.main.async {
            setupExpectation.fulfill()
        }
        wait(for: [setupExpectation], timeout: 1.0)
        
        // When - Update multiple properties
        propertiesViewModel.updateText("Integration Test")
        propertiesViewModel.updateFontSize(22)
        propertiesViewModel.updateFontWeight(.bold)
        propertiesViewModel.updateTextColor(ColorData(red: 1.0, green: 0.0, blue: 0.0))
        
        // Then - Verify all properties are updated
        XCTAssertEqual(propertiesViewModel.editingProperties.text, "Integration Test")
        XCTAssertEqual(propertiesViewModel.editingProperties.fontSize, 22)
        XCTAssertEqual(propertiesViewModel.editingProperties.fontWeight, .bold)
        XCTAssertEqual(propertiesViewModel.editingProperties.textColor.red, 1.0)
        
        // Verify editor view model is also updated
        let component = editorViewModel.components[0]
        XCTAssertEqual(component.properties.text, "Integration Test")
        XCTAssertEqual(component.properties.fontSize, 22)
        XCTAssertEqual(component.properties.fontWeight, .bold)
    }
    
    // MARK: - Performance Tests
    
    func testPerformanceOfPropertyUpdates() {
        // Setup
        editorViewModel.addComponent(.text, at: CGPoint(x: 0, y: 0))
        
        measure {
            for i in 0..<100 {
                propertiesViewModel.updateText("Text \(i)")
                propertiesViewModel.updateFontSize(Double(16 + i % 20))
            }
        }
    }
    
    func testPerformanceOfComponentSwitching() {
        // Setup
        for i in 0..<10 {
            editorViewModel.addComponent(.text, at: CGPoint(x: Double(i * 50), y: 0))
        }
        
        measure {
            for component in editorViewModel.components {
                editorViewModel.selectComponent(component)
            }
        }
    }
}
