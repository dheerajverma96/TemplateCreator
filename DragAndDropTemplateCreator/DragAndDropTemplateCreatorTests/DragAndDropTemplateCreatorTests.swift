//
//  DragAndDropTemplateCreatorTests.swift
//  DragAndDropTemplateCreatorTests
//
//  Created by Dheeraj Verma on 17/08/25.
//

import XCTest
import Combine
@testable import DragAndDropTemplateCreator
import SwiftUI

final class DragAndDropTemplateCreatorTests: XCTestCase {
    
    var editorViewModel: EditorViewModel!
    var propertiesViewModel: PropertiesViewModel!
    var paletteViewModel: ComponentPaletteViewModel!
    var previewViewModel: PreviewViewModel!
    var cancellables: Set<AnyCancellable>!

    override func setUpWithError() throws {
        super.setUp()
        editorViewModel = EditorViewModel()
        propertiesViewModel = PropertiesViewModel(editorViewModel: editorViewModel)
        paletteViewModel = ComponentPaletteViewModel(editorViewModel: editorViewModel)
        previewViewModel = PreviewViewModel(editorViewModel: editorViewModel)
        cancellables = Set<AnyCancellable>()
        
        // Clear UserDefaults for clean test state
        UserDefaults.standard.removeObject(forKey: "editorComponents")
    }

    override func tearDownWithError() throws {
        cancellables = nil
        previewViewModel = nil
        paletteViewModel = nil
        propertiesViewModel = nil
        editorViewModel = nil
        UserDefaults.standard.removeObject(forKey: "editorComponents")
        super.tearDown()
    }

    // MARK: - Integration Tests
    
    func testCompleteTemplateCreationWorkflow() throws {
        // Test the complete workflow from component creation to HTML export
        
        // Step 1: Add components via palette
        paletteViewModel.addComponentToCanvas(.text, at: CGPoint(x: 50, y: 50))
        paletteViewModel.addComponentToCanvas(.button, at: CGPoint(x: 50, y: 150))
        paletteViewModel.addComponentToCanvas(.image, at: CGPoint(x: 50, y: 250))
        
        XCTAssertEqual(editorViewModel.components.count, 3)
        
        // Step 2: Modify properties via properties panel
        let textComponent = editorViewModel.components[0]
        editorViewModel.selectComponent(textComponent)
        
        // Allow reactive updates
        let expectation = XCTestExpectation(description: "Properties updated")
        DispatchQueue.main.async {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
        
        propertiesViewModel.updateText("Header Text")
        propertiesViewModel.updateFontSize(24)
        propertiesViewModel.updateFontWeight(.bold)
        
        // Step 3: Test undo/redo functionality
        XCTAssertTrue(editorViewModel.canUndo)
        let componentsBeforeUndo = editorViewModel.components.count
        
        editorViewModel.undo() // Undo image addition
        XCTAssertEqual(editorViewModel.components.count, componentsBeforeUndo - 1)
        
        editorViewModel.redo() // Redo image addition
        XCTAssertEqual(editorViewModel.components.count, componentsBeforeUndo)
        
        // Step 4: Generate HTML and verify output
        let html = previewViewModel.shareHTML()
        XCTAssertTrue(html.contains("Header Text"))
        XCTAssertTrue(html.contains("font-size: 24px"))
        XCTAssertTrue(html.contains("font-weight: bold"))
        XCTAssertTrue(html.contains("<a")) // Button element
        XCTAssertTrue(html.contains("<img")) // Image element
    }
    
    func testCrossViewModelCommunication() throws {
        // Test that changes in one view model are properly reflected in others
        
        // Add component via palette
        paletteViewModel.addComponentToCanvas(.text, at: CGPoint(x: 100, y: 200))
        
        // Verify editor state
        XCTAssertEqual(editorViewModel.components.count, 1)
        XCTAssertNotNil(editorViewModel.selectedComponentId)
        
        // Allow reactive updates to properties view model
        let propertiesExpectation = XCTestExpectation(description: "Properties updated")
        DispatchQueue.main.async {
            propertiesExpectation.fulfill()
        }
        wait(for: [propertiesExpectation], timeout: 1.0)
        
        // Verify properties view model reflects selection
        XCTAssertNotNil(propertiesViewModel.selectedComponent)
        XCTAssertEqual(propertiesViewModel.selectedComponent?.type, .text)
        
        // Update properties
        propertiesViewModel.updateText("Cross-VM Test")
        
        // Verify change is reflected in editor
        let updatedComponent = editorViewModel.components[0]
        XCTAssertEqual(updatedComponent.properties.text, "Cross-VM Test")
        
        // Verify preview generates correct HTML
        let html = previewViewModel.shareHTML()
        XCTAssertTrue(html.contains("Cross-VM Test"))
    }
    
    func testPersistenceIntegration() throws {
        // Test that data persists across app restarts
        
        // Create a template
        paletteViewModel.addComponentToCanvas(.text, at: CGPoint(x: 25, y: 25))
        paletteViewModel.addComponentToCanvas(.button, at: CGPoint(x: 125, y: 125))
        
        let textComponent = editorViewModel.components[0]
        editorViewModel.selectComponent(textComponent)
        
        // Allow reactive updates
        let expectation = XCTestExpectation(description: "Setup complete")
        DispatchQueue.main.async {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
        
        propertiesViewModel.updateText("Persistent Text")
        propertiesViewModel.updateFontSize(20)
        
        // Simulate app restart by creating new view models
        let newEditorViewModel = EditorViewModel()
        let newPropertiesViewModel = PropertiesViewModel(editorViewModel: newEditorViewModel)
        let newPreviewViewModel = PreviewViewModel(editorViewModel: newEditorViewModel)
        
        // Verify data was loaded
        XCTAssertEqual(newEditorViewModel.components.count, 2)
        XCTAssertEqual(newEditorViewModel.components[0].properties.text, "Persistent Text")
        XCTAssertEqual(newEditorViewModel.components[0].properties.fontSize, 20)
        
        // Verify HTML generation works with loaded data
        let html = newPreviewViewModel.shareHTML()
        XCTAssertTrue(html.contains("Persistent Text"))
        XCTAssertTrue(html.contains("font-size: 20px"))
    }
    
    func testUndoRedoIntegration() throws {
        // Test undo/redo across different operations
        
        // Initial state
        XCTAssertFalse(editorViewModel.canUndo)
        XCTAssertFalse(editorViewModel.canRedo)
        
        // Add component
        paletteViewModel.addComponentToCanvas(.text, at: CGPoint(x: 0, y: 0))
        XCTAssertTrue(editorViewModel.canUndo)
        XCTAssertEqual(editorViewModel.components.count, 1)
        
        // Modify properties
        let component = editorViewModel.components[0]
        editorViewModel.selectComponent(component)
        
        // Allow reactive updates
        let expectation = XCTestExpectation(description: "Selection updated")
        DispatchQueue.main.async {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
        
        propertiesViewModel.updateText("Modified Text")
        
        // Move component
        editorViewModel.updateComponentPosition(component.id, to: CGPoint(x: 100, y: 100))
        
        // Add another component
        paletteViewModel.addComponentToCanvas(.button, at: CGPoint(x: 200, y: 200))
        XCTAssertEqual(editorViewModel.components.count, 2)
        
        // Undo operations
        editorViewModel.undo() // Undo button addition
        XCTAssertEqual(editorViewModel.components.count, 1)
        
        editorViewModel.undo() // Undo position change
        XCTAssertEqual(editorViewModel.components[0].position, CGPoint(x: 0, y: 0))
        
        editorViewModel.undo() // Undo text change
        // Note: Property changes create snapshots, so this should restore previous state
        
        editorViewModel.undo() // Undo component addition
        XCTAssertEqual(editorViewModel.components.count, 0)
        
        // Redo operations
        while editorViewModel.canRedo {
            editorViewModel.redo()
        }
        
        // Should be back to final state
        XCTAssertEqual(editorViewModel.components.count, 2)
    }
    
    func testPreviewDeviceIntegration() throws {
        // Test preview functionality across different devices
        
        // Add components
        paletteViewModel.addComponentToCanvas(.text, at: CGPoint(x: 50, y: 50))
        paletteViewModel.addComponentToCanvas(.button, at: CGPoint(x: 50, y: 150))
        
        // Test mobile preview
        previewViewModel.selectDevice(.mobile)
        XCTAssertEqual(previewViewModel.selectedDevice, .mobile)
        XCTAssertEqual(previewViewModel.previewWidth, 375)
        XCTAssertEqual(previewViewModel.previewHeight, 812)
        
        let mobileHTML = previewViewModel.shareHTML()
        XCTAssertTrue(mobileHTML.contains("Sample Text"))
        XCTAssertTrue(mobileHTML.contains("Button"))
        
        // Test tablet preview
        previewViewModel.selectDevice(.tablet)
        XCTAssertEqual(previewViewModel.selectedDevice, .tablet)
        XCTAssertEqual(previewViewModel.previewWidth, 768)
        XCTAssertEqual(previewViewModel.previewHeight, 1024)
        
        let tabletHTML = previewViewModel.shareHTML()
        XCTAssertTrue(tabletHTML.contains("Sample Text"))
        XCTAssertTrue(tabletHTML.contains("Button"))
        
        // HTML should be the same content, just different context
        XCTAssertTrue(mobileHTML.contains("<span"))
        XCTAssertTrue(tabletHTML.contains("<span"))
    }
    
    func testCompleteComponentLifecycle() throws {
        // Test complete lifecycle: create, select, modify, move, delete
        
        // Create
        paletteViewModel.addComponentToCanvas(.image, at: CGPoint(x: 100, y: 150))
        XCTAssertEqual(editorViewModel.components.count, 1)
        
        let component = editorViewModel.components[0]
        XCTAssertEqual(component.type, .image)
        XCTAssertEqual(component.position, CGPoint(x: 100, y: 150))
        
        // Select
        editorViewModel.selectComponent(component)
        XCTAssertEqual(editorViewModel.selectedComponentId, component.id)
        
        // Allow reactive updates
        let selectExpectation = XCTestExpectation(description: "Component selected")
        DispatchQueue.main.async {
            selectExpectation.fulfill()
        }
        wait(for: [selectExpectation], timeout: 1.0)
        
        XCTAssertEqual(propertiesViewModel.selectedComponent?.id, component.id)
        
        // Modify properties
        propertiesViewModel.updateImageURL("https://example.com/test.jpg")
        propertiesViewModel.updateAltText("Test Image")
        propertiesViewModel.updateWidth(200)
        propertiesViewModel.updateHeight(150)
        
        // Verify modifications
        let modifiedComponent = editorViewModel.components[0]
        XCTAssertEqual(modifiedComponent.properties.imageURL, "https://example.com/test.jpg")
        XCTAssertEqual(modifiedComponent.properties.altText, "Test Image")
        XCTAssertEqual(modifiedComponent.properties.width, 200)
        XCTAssertEqual(modifiedComponent.properties.height, 150)
        
        // Move
        editorViewModel.updateComponentPosition(component.id, to: CGPoint(x: 200, y: 250))
        let movedComponent = editorViewModel.components[0]
        XCTAssertEqual(movedComponent.position, CGPoint(x: 200, y: 250))
        
        // Verify HTML generation includes all changes
        let html = previewViewModel.shareHTML()
        XCTAssertTrue(html.contains("https://example.com/test.jpg"))
        XCTAssertTrue(html.contains("alt=\"Test Image\""))
        XCTAssertTrue(html.contains("width: 200px"))
        XCTAssertTrue(html.contains("height: 150px"))
        XCTAssertTrue(html.contains("left: 200px"))
        XCTAssertTrue(html.contains("top: 250px"))
        
        // Delete
        propertiesViewModel.deleteSelectedComponent()
        XCTAssertEqual(editorViewModel.components.count, 0)
        XCTAssertNil(editorViewModel.selectedComponentId)
        XCTAssertNil(propertiesViewModel.selectedComponent)
    }

    // MARK: - Performance Integration Tests
    
    func testPerformanceCompleteWorkflow() throws {
        // Test performance of complete workflow
        measure {
            // Create template
            for i in 0..<10 {
                paletteViewModel.addComponentToCanvas(.text, at: CGPoint(x: Double(i * 50), y: Double(i * 30)))
            }
            
            // Modify properties
            for component in editorViewModel.components {
                editorViewModel.selectComponent(component)
                propertiesViewModel.updateText("Text \(component.id)")
                propertiesViewModel.updateFontSize(Double(16 + (editorViewModel.components.firstIndex(of: component) ?? 0)))
            }
            
            // Generate HTML
            _ = previewViewModel.shareHTML()
            
            // Clear for next iteration
            editorViewModel.clearAllComponents()
        }
    }
    
    func testPerformanceLargeTemplate() throws {
        // Test performance with many components
        self.measure {
            // Add many components
            for i in 0..<50 {
                let componentType = ComponentType.allCases[i % ComponentType.allCases.count]
                paletteViewModel.addComponentToCanvas(componentType, at: CGPoint(x: Double(i * 20), y: Double(i * 15)))
            }
            
            // Generate HTML
            _ = previewViewModel.shareHTML()
        }
    }
    
    // MARK: - Error Handling Tests
    
    func testErrorHandlingInvalidOperations() throws {
        // Test that invalid operations don't crash the app
        
        // Try to update nonexistent component
        let nonexistentId = UUID()
        editorViewModel.updateComponentPosition(nonexistentId, to: CGPoint(x: 100, y: 100))
        // Should not crash
        
        // Try to delete when nothing is selected
        editorViewModel.deselectComponent()
        propertiesViewModel.deleteSelectedComponent()
        // Should not crash
        
        // Try to undo when no history
        let freshEditor = EditorViewModel()
        freshEditor.undo()
        // Should not crash
        
        // Try to redo when no future history
        freshEditor.redo()
        // Should not crash
    }
    
    // MARK: - Memory Management Integration
    
    func testMemoryManagementIntegration() throws {
        // Test that all view models can be properly deallocated
        
        weak var weakEditor: EditorViewModel?
        weak var weakProperties: PropertiesViewModel?
        weak var weakPalette: ComponentPaletteViewModel?
        weak var weakPreview: PreviewViewModel?
        
        // Create scope for strong references
        autoreleasepool {
            let editor = EditorViewModel()
            let properties = PropertiesViewModel(editorViewModel: editor)
            let palette = ComponentPaletteViewModel(editorViewModel: editor)
            let preview = PreviewViewModel(editorViewModel: editor)
            
            // Set weak references
            weakEditor = editor
            weakProperties = properties
            weakPalette = palette
            weakPreview = preview
            
            // Do some operations
            palette.addComponentToCanvas(.text, at: CGPoint(x: 0, y: 0))
            properties.updateText("Test")
            _ = preview.shareHTML()
            
            // Strong references go out of scope here
        }
        
        // All objects should be deallocated
        XCTAssertNil(weakEditor)
        XCTAssertNil(weakProperties)
        XCTAssertNil(weakPalette)
        XCTAssertNil(weakPreview)
    }
    
    // MARK: - Reactive System Integration
    
    func testReactiveSystemIntegration() throws {
        // Test that reactive updates work correctly across the system
        
        var componentUpdateCount = 0
        var selectionUpdateCount = 0
        
        let componentExpectation = XCTestExpectation(description: "Component updates received")
        componentExpectation.expectedFulfillmentCount = 3
        
        let selectionExpectation = XCTestExpectation(description: "Selection updates received")
        selectionExpectation.expectedFulfillmentCount = 3
        
        // Subscribe to updates
        editorViewModel.$components
            .dropFirst()
            .sink { _ in
                componentUpdateCount += 1
                componentExpectation.fulfill()
            }
            .store(in: &cancellables)
        
        editorViewModel.$selectedComponentId
            .dropFirst()
            .sink { _ in
                selectionUpdateCount += 1
                selectionExpectation.fulfill()
            }
            .store(in: &cancellables)
        
        // Trigger updates
        paletteViewModel.addComponentToCanvas(.text, at: CGPoint(x: 0, y: 0))    // Component + Selection update
        paletteViewModel.addComponentToCanvas(.button, at: CGPoint(x: 100, y: 100)) // Component + Selection update
        editorViewModel.deselectComponent()                               // Selection update
        
        // Wait for reactive updates
        wait(for: [componentExpectation, selectionExpectation], timeout: 2.0)
        
        XCTAssertEqual(componentUpdateCount, 2) // Two component additions
        XCTAssertEqual(selectionUpdateCount, 3) // Two selections + one deselection
    }

}
