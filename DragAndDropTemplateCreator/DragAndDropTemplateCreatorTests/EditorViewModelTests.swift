//
//  EditorViewModelTests.swift
//  DragAndDropTemplateCreatorTests
//
//  Created by Dheeraj Verma on 17/08/25.
//

import XCTest
import Combine
@testable import DragAndDropTemplateCreator
import SwiftUI

final class EditorViewModelTests: XCTestCase {
    
    var editorViewModel: EditorViewModel!
    var cancellables: Set<AnyCancellable>!
    
    override func setUpWithError() throws {
        super.setUp()
        editorViewModel = EditorViewModel()
        cancellables = Set<AnyCancellable>()
        
        // Clear UserDefaults for clean test state
        UserDefaults.standard.removeObject(forKey: "editorComponents")
    }
    
    override func tearDownWithError() throws {
        cancellables = nil
        editorViewModel = nil
        UserDefaults.standard.removeObject(forKey: "editorComponents")
        super.tearDown()
    }
    
    // MARK: - Initialization Tests
    
    func testInitialState() {
        XCTAssertTrue(editorViewModel.components.isEmpty)
        XCTAssertNil(editorViewModel.selectedComponentId)
        XCTAssertFalse(editorViewModel.isPreviewMode)
        XCTAssertEqual(editorViewModel.previewDevice, .mobile)
        XCTAssertFalse(editorViewModel.canUndo)
        XCTAssertFalse(editorViewModel.canRedo)
        XCTAssertEqual(editorViewModel.componentCount, 0)
        XCTAssertNil(editorViewModel.selectedComponent)
    }
    
    // MARK: - Component Management Tests
    
    func testAddComponent() {
        // Given
        let position = CGPoint(x: 100, y: 200)
        let initialCount = editorViewModel.components.count
        
        // When
        editorViewModel.addComponent(.text, at: position)
        
        // Then
        XCTAssertEqual(editorViewModel.components.count, initialCount + 1)
        XCTAssertEqual(editorViewModel.componentCount, 1)
        
        let addedComponent = editorViewModel.components.last!
        XCTAssertEqual(addedComponent.type, .text)
        XCTAssertEqual(addedComponent.position, position)
        XCTAssertEqual(editorViewModel.selectedComponentId, addedComponent.id)
        XCTAssertEqual(editorViewModel.selectedComponent?.id, addedComponent.id)
    }
    
    func testAddMultipleComponents() {
        // When
        editorViewModel.addComponent(.text, at: CGPoint(x: 0, y: 0))
        editorViewModel.addComponent(.button, at: CGPoint(x: 100, y: 100))
        editorViewModel.addComponent(.image, at: CGPoint(x: 200, y: 200))
        
        // Then
        XCTAssertEqual(editorViewModel.components.count, 3)
        XCTAssertEqual(editorViewModel.componentCount, 3)
        
        // Check types
        XCTAssertEqual(editorViewModel.components[0].type, .text)
        XCTAssertEqual(editorViewModel.components[1].type, .button)
        XCTAssertEqual(editorViewModel.components[2].type, .image)
        
        // Last added should be selected
        XCTAssertEqual(editorViewModel.selectedComponentId, editorViewModel.components[2].id)
    }
    
    func testSelectComponent() {
        // Given
        editorViewModel.addComponent(.text, at: CGPoint(x: 0, y: 0))
        editorViewModel.addComponent(.button, at: CGPoint(x: 100, y: 100))
        let firstComponent = editorViewModel.components[0]
        
        // When
        editorViewModel.selectComponent(firstComponent)
        
        // Then
        XCTAssertEqual(editorViewModel.selectedComponentId, firstComponent.id)
        XCTAssertEqual(editorViewModel.selectedComponent?.id, firstComponent.id)
    }
    
    func testDeselectComponent() {
        // Given
        editorViewModel.addComponent(.text, at: CGPoint(x: 0, y: 0))
        XCTAssertNotNil(editorViewModel.selectedComponentId)
        
        // When
        editorViewModel.deselectComponent()
        
        // Then
        XCTAssertNil(editorViewModel.selectedComponentId)
        XCTAssertNil(editorViewModel.selectedComponent)
    }
    
    func testUpdateComponentPosition() {
        // Given
        editorViewModel.addComponent(.text, at: CGPoint(x: 0, y: 0))
        let component = editorViewModel.components[0]
        let newPosition = CGPoint(x: 150, y: 250)
        
        // When
        editorViewModel.updateComponentPosition(component.id, to: newPosition)
        
        // Then
        let updatedComponent = editorViewModel.components.first { $0.id == component.id }
        XCTAssertEqual(updatedComponent?.position, newPosition)
    }
    
    func testUpdateComponentProperties() {
        // Given
        editorViewModel.addComponent(.text, at: CGPoint(x: 0, y: 0))
        let component = editorViewModel.components[0]
        var newProperties = ComponentProperties()
        newProperties.text = "Updated Text"
        newProperties.fontSize = 24
        
        // When
        editorViewModel.updateComponentProperties(component.id, properties: newProperties)
        
        // Then
        let updatedComponent = editorViewModel.components.first { $0.id == component.id }
        XCTAssertEqual(updatedComponent?.properties.text, "Updated Text")
        XCTAssertEqual(updatedComponent?.properties.fontSize, 24)
    }
    
    func testDeleteSelectedComponent() {
        // Given
        editorViewModel.addComponent(.text, at: CGPoint(x: 0, y: 0))
        editorViewModel.addComponent(.button, at: CGPoint(x: 100, y: 100))
        let initialCount = editorViewModel.components.count
        let selectedId = editorViewModel.selectedComponentId
        
        // When
        editorViewModel.deleteSelectedComponent()
        
        // Then
        XCTAssertEqual(editorViewModel.components.count, initialCount - 1)
        XCTAssertNil(editorViewModel.selectedComponentId)
        XCTAssertFalse(editorViewModel.components.contains { $0.id == selectedId })
    }
    
    func testDeleteSelectedComponentWhenNoneSelected() {
        // Given
        editorViewModel.addComponent(.text, at: CGPoint(x: 0, y: 0))
        editorViewModel.deselectComponent()
        let initialCount = editorViewModel.components.count
        
        // When
        editorViewModel.deleteSelectedComponent()
        
        // Then
        XCTAssertEqual(editorViewModel.components.count, initialCount) // No change
    }
    
    func testClearAllComponents() {
        // Given
        editorViewModel.addComponent(.text, at: CGPoint(x: 0, y: 0))
        editorViewModel.addComponent(.button, at: CGPoint(x: 100, y: 100))
        XCTAssertFalse(editorViewModel.components.isEmpty)
        
        // When
        editorViewModel.clearAllComponents()
        
        // Then
        XCTAssertTrue(editorViewModel.components.isEmpty)
        XCTAssertNil(editorViewModel.selectedComponentId)
        XCTAssertEqual(editorViewModel.componentCount, 0)
    }
    
    // MARK: - Undo/Redo Tests
    
    func testUndoRedoFunctionality() {
        // Initially no undo/redo available
        XCTAssertFalse(editorViewModel.canUndo)
        XCTAssertFalse(editorViewModel.canRedo)
        
        // Add first component
        editorViewModel.addComponent(.text, at: CGPoint(x: 0, y: 0))
        XCTAssertTrue(editorViewModel.canUndo)
        XCTAssertFalse(editorViewModel.canRedo)
        XCTAssertEqual(editorViewModel.components.count, 1)
        
        // Add second component
        editorViewModel.addComponent(.button, at: CGPoint(x: 100, y: 100))
        XCTAssertTrue(editorViewModel.canUndo)
        XCTAssertFalse(editorViewModel.canRedo)
        XCTAssertEqual(editorViewModel.components.count, 2)
        
        // Undo last action
        editorViewModel.undo()
        XCTAssertTrue(editorViewModel.canUndo)
        XCTAssertTrue(editorViewModel.canRedo)
        XCTAssertEqual(editorViewModel.components.count, 1)
        XCTAssertEqual(editorViewModel.components[0].type, .text)
        
        // Undo again
        editorViewModel.undo()
        XCTAssertFalse(editorViewModel.canUndo)
        XCTAssertTrue(editorViewModel.canRedo)
        XCTAssertEqual(editorViewModel.components.count, 0)
        
        // Redo
        editorViewModel.redo()
        XCTAssertTrue(editorViewModel.canUndo)
        XCTAssertTrue(editorViewModel.canRedo)
        XCTAssertEqual(editorViewModel.components.count, 1)
        XCTAssertEqual(editorViewModel.components[0].type, .text)
        
        // Redo again
        editorViewModel.redo()
        XCTAssertTrue(editorViewModel.canUndo)
        XCTAssertFalse(editorViewModel.canRedo)
        XCTAssertEqual(editorViewModel.components.count, 2)
    }
    
    func testUndoWithoutAvailableHistory() {
        // Given
        XCTAssertFalse(editorViewModel.canUndo)
        
        // When
        editorViewModel.undo()
        
        // Then
        XCTAssertEqual(editorViewModel.components.count, 0)
        XCTAssertFalse(editorViewModel.canUndo)
    }
    
    func testRedoWithoutAvailableHistory() {
        // Given
        XCTAssertFalse(editorViewModel.canRedo)
        
        // When
        editorViewModel.redo()
        
        // Then
        XCTAssertEqual(editorViewModel.components.count, 0)
        XCTAssertFalse(editorViewModel.canRedo)
    }
    
    func testHistoryLimitEnforcement() {
        // Test that history is limited to 50 steps
        // Add more than 50 components
        for i in 0..<55 {
            editorViewModel.addComponent(.text, at: CGPoint(x: Double(i * 10), y: 0))
        }
        
        // Check that we can only undo a limited number of times
        var undoCount = 0
        while editorViewModel.canUndo {
            editorViewModel.undo()
            undoCount += 1
            if undoCount > 60 { // Safety check to prevent infinite loop
                break
            }
        }
        
        XCTAssertLessThanOrEqual(undoCount, 50)
    }
    
    func testHistoryClearedOnNewAction() {
        // Given
        editorViewModel.addComponent(.text, at: CGPoint(x: 0, y: 0))
        editorViewModel.addComponent(.button, at: CGPoint(x: 100, y: 100))
        
        // Undo one action
        editorViewModel.undo()
        XCTAssertTrue(editorViewModel.canRedo)
        
        // When - perform new action
        editorViewModel.addComponent(.image, at: CGPoint(x: 200, y: 200))
        
        // Then - redo should no longer be available
        XCTAssertFalse(editorViewModel.canRedo)
        XCTAssertTrue(editorViewModel.canUndo)
    }
    
    // MARK: - Preview Mode Tests
    
    func testTogglePreviewMode() {
        // Initially not in preview mode
        XCTAssertFalse(editorViewModel.isPreviewMode)
        
        // Toggle to preview mode
        editorViewModel.togglePreviewMode()
        XCTAssertTrue(editorViewModel.isPreviewMode)
        
        // Toggle back
        editorViewModel.togglePreviewMode()
        XCTAssertFalse(editorViewModel.isPreviewMode)
    }
    
    func testSetPreviewDevice() {
        // Given
        XCTAssertEqual(editorViewModel.previewDevice, .mobile)
        
        // When
        editorViewModel.setPreviewDevice(.mobile)
        
        // Then
        XCTAssertEqual(editorViewModel.previewDevice, .mobile)
    }
    
    // MARK: - HTML Generation Tests
    
    func testGenerateHTMLWithEmptyComponents() {
        // When
        let html = editorViewModel.generateHTML()
        
        // Then
        XCTAssertTrue(html.contains("<!DOCTYPE html>"))
        XCTAssertTrue(html.contains("<html"))
        XCTAssertTrue(html.contains("</html>"))
        XCTAssertTrue(html.contains("<div class=\"canvas\">"))
        XCTAssertTrue(html.contains("Generated Template"))
    }
    
    func testGenerateHTMLWithComponents() {
        // Given
        editorViewModel.addComponent(.text, at: CGPoint(x: 100, y: 200))
        
        var properties = ComponentProperties()
        properties.text = "Test Text"
        properties.fontSize = 18
        
        let component = editorViewModel.components[0]
        editorViewModel.updateComponentProperties(component.id, properties: properties)
        
        // When
        let html = editorViewModel.generateHTML()
        
        // Then
        XCTAssertTrue(html.contains("Test Text"))
        XCTAssertTrue(html.contains("font-size: 18px"))
        XCTAssertTrue(html.contains("left: 100px"))
        XCTAssertTrue(html.contains("top: 200px"))
    }
    
    func testGenerateHTMLWithMultipleComponentTypes() {
        // Given
        editorViewModel.addComponent(.text, at: CGPoint(x: 0, y: 0))
        editorViewModel.addComponent(.button, at: CGPoint(x: 100, y: 100))
        editorViewModel.addComponent(.image, at: CGPoint(x: 200, y: 200))
        
        // When
        let html = editorViewModel.generateHTML()
        
        // Then
        XCTAssertTrue(html.contains("<span")) // Text component
        XCTAssertTrue(html.contains("<a")) // Button component
        XCTAssertTrue(html.contains("<img")) // Image component
    }
    
    // MARK: - Persistence Tests
    
    func testPersistenceIntegration() {
        // Given
        editorViewModel.addComponent(.text, at: CGPoint(x: 50, y: 75))
        let component = editorViewModel.components[0]
        
        var properties = ComponentProperties()
        properties.text = "Persistent Text"
        editorViewModel.updateComponentProperties(component.id, properties: properties)
        
        // Create new editor instance (simulates app restart)
        let newEditorViewModel = EditorViewModel()
        
        // Then - check if data was loaded
        XCTAssertEqual(newEditorViewModel.components.count, 1)
        XCTAssertEqual(newEditorViewModel.components[0].properties.text, "Persistent Text")
        XCTAssertEqual(newEditorViewModel.components[0].position.x, 50, accuracy: 0.001)
        XCTAssertEqual(newEditorViewModel.components[0].position.y, 75, accuracy: 0.001)
    }
    
    // MARK: - Reactive Property Tests
    
    func testPublishedPropertiesEmitUpdates() {
        let expectation = XCTestExpectation(description: "Components updated")
        
        // Subscribe to components changes
        editorViewModel.$components
            .dropFirst() // Skip initial empty value
            .sink { components in
                if !components.isEmpty {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        // When
        editorViewModel.addComponent(.text, at: CGPoint(x: 0, y: 0))
        
        // Then
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testSelectedComponentIdUpdates() {
        let expectation = XCTestExpectation(description: "Selected component updated")
        
        // Subscribe to selection changes
        editorViewModel.$selectedComponentId
            .dropFirst() // Skip initial nil value
            .sink { selectedId in
                if selectedId != nil {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        // When
        editorViewModel.addComponent(.text, at: CGPoint(x: 0, y: 0))
        
        // Then
        wait(for: [expectation], timeout: 1.0)
    }
    
    // MARK: - Edge Cases Tests
    
    func testUpdateNonexistentComponent() {
        // Given
        let nonexistentId = UUID()
        let newProperties = ComponentProperties()
        
        // When
        editorViewModel.updateComponentProperties(nonexistentId, properties: newProperties)
        
        // Then
        // Should not crash, no changes should occur
        XCTAssertEqual(editorViewModel.components.count, 0)
    }
    
    func testUpdatePositionOfNonexistentComponent() {
        // Given
        let nonexistentId = UUID()
        let newPosition = CGPoint(x: 100, y: 200)
        
        // When
        editorViewModel.updateComponentPosition(nonexistentId, to: newPosition)
        
        // Then
        // Should not crash, no changes should occur
        XCTAssertEqual(editorViewModel.components.count, 0)
    }
    
    // MARK: - Performance Tests
    
    func testPerformanceOfAddingManyComponents() {
        measure {
            for i in 0..<100 {
                editorViewModel.addComponent(.text, at: CGPoint(x: Double(i), y: Double(i)))
            }
        }
    }
    
    func testPerformanceOfHTMLGeneration() {
        // Setup
        for i in 0..<50 {
            editorViewModel.addComponent(.text, at: CGPoint(x: Double(i * 10), y: Double(i * 10)))
        }
        
        measure {
            _ = editorViewModel.generateHTML()
        }
    }
    
    func testPerformanceOfUndoRedo() {
        // Setup
        for i in 0..<20 {
            editorViewModel.addComponent(.text, at: CGPoint(x: Double(i), y: Double(i)))
        }
        
        measure {
            // Undo all
            while editorViewModel.canUndo {
                editorViewModel.undo()
            }
            
            // Redo all
            while editorViewModel.canRedo {
                editorViewModel.redo()
            }
        }
    }
}