//
//  ComponentPaletteViewModelTests.swift
//  DragAndDropTemplateCreatorTests
//
//  Created by Dheeraj Verma on 17/08/25.
//

import XCTest
import Combine
@testable import DragAndDropTemplateCreator
import SwiftUI

final class ComponentPaletteViewModelTests: XCTestCase {
    
    var editorViewModel: EditorViewModel!
    var paletteViewModel: ComponentPaletteViewModel!
    var cancellables: Set<AnyCancellable>!
    
    override func setUpWithError() throws {
        super.setUp()
        editorViewModel = EditorViewModel()
        paletteViewModel = ComponentPaletteViewModel(editorViewModel: editorViewModel)
        cancellables = Set<AnyCancellable>()
        
        // Clear UserDefaults for clean test state
        UserDefaults.standard.removeObject(forKey: "editorComponents")
    }
    
    override func tearDownWithError() throws {
        cancellables = nil
        paletteViewModel = nil
        editorViewModel = nil
        UserDefaults.standard.removeObject(forKey: "editorComponents")
        super.tearDown()
    }
    
    // MARK: - Initialization Tests
    
    func testInitialState() {
        XCTAssertEqual(paletteViewModel.availableComponents.count, 4)
        XCTAssertTrue(paletteViewModel.availableComponents.contains(.text))
        XCTAssertTrue(paletteViewModel.availableComponents.contains(.textArea))
        XCTAssertTrue(paletteViewModel.availableComponents.contains(.image))
        XCTAssertTrue(paletteViewModel.availableComponents.contains(.button))
        XCTAssertNil(paletteViewModel.draggedComponent)
    }
    
    func testInitializationWithEditorViewModel() {
        XCTAssertNotNil(paletteViewModel)
    }
    
    // MARK: - Available Components Tests
    
    func testAvailableComponentsContent() {
        // Then
        XCTAssertEqual(paletteViewModel.availableComponents, ComponentType.allCases)
    }
    
    func testAvailableComponentsOrder() {
        // Given
        let expectedOrder: [ComponentType] = [.text, .textArea, .image, .button]
        
        // Then
        XCTAssertEqual(paletteViewModel.availableComponents, expectedOrder)
    }
    
    // MARK: - Drag State Management Tests
    
    func testStartDragging() {
        // Given
        let componentType = ComponentType.text
        XCTAssertNil(paletteViewModel.draggedComponent)
        
        // When
        paletteViewModel.startDragging(componentType)
        
        // Then
        XCTAssertEqual(paletteViewModel.draggedComponent, componentType)
    }
    
    func testEndDragging() {
        // Given
        paletteViewModel.startDragging(.button)
        XCTAssertNotNil(paletteViewModel.draggedComponent)
        
        // When
        paletteViewModel.endDragging()
        
        // Then
        XCTAssertNil(paletteViewModel.draggedComponent)
    }
    
    func testMultipleDragOperations() {
        // Test starting and ending multiple drag operations
        for componentType in ComponentType.allCases {
            // Start dragging
            paletteViewModel.startDragging(componentType)
            XCTAssertEqual(paletteViewModel.draggedComponent, componentType)
            
            // End dragging
            paletteViewModel.endDragging()
            XCTAssertNil(paletteViewModel.draggedComponent)
        }
    }
    
    func testDragStateOverwrite() {
        // Given
        paletteViewModel.startDragging(.text)
        XCTAssertEqual(paletteViewModel.draggedComponent, .text)
        
        // When - start dragging a different component
        paletteViewModel.startDragging(.button)
        
        // Then - should overwrite previous drag state
        XCTAssertEqual(paletteViewModel.draggedComponent, .button)
    }
    
    // MARK: - Component Addition Tests
    
    func testAddComponentToEditor() {
        // Given
        let componentType = ComponentType.text
        let position = CGPoint(x: 100, y: 200)
        let initialCount = editorViewModel.components.count
        
        // When
        paletteViewModel.addComponentToCanvas(componentType, at: position)
        
        // Then
        XCTAssertEqual(editorViewModel.components.count, initialCount + 1)
        
        let addedComponent = editorViewModel.components.last!
        XCTAssertEqual(addedComponent.type, componentType)
        XCTAssertEqual(addedComponent.position, position)
        XCTAssertEqual(editorViewModel.selectedComponentId, addedComponent.id)
    }
    
    func testAddMultipleComponentsToEditor() {
        // Given
        let components: [(ComponentType, CGPoint)] = [
            (.text, CGPoint(x: 0, y: 0)),
            (.button, CGPoint(x: 100, y: 100)),
            (.image, CGPoint(x: 200, y: 200)),
            (.textArea, CGPoint(x: 300, y: 300))
        ]
        
        // When
        for (type, position) in components {
            paletteViewModel.addComponentToCanvas(type, at: position)
        }
        
        // Then
        XCTAssertEqual(editorViewModel.components.count, 4)
        
        for (index, (expectedType, expectedPosition)) in components.enumerated() {
            let component = editorViewModel.components[index]
            XCTAssertEqual(component.type, expectedType)
            XCTAssertEqual(component.position, expectedPosition)
        }
        
        // Last added component should be selected
        XCTAssertEqual(editorViewModel.selectedComponentId, editorViewModel.components.last?.id)
    }
    
    func testAddComponentAtDifferentPositions() {
        // Test adding the same component type at different positions
        let positions = [
            CGPoint(x: 0, y: 0),
            CGPoint(x: 50.5, y: 75.3),
            CGPoint(x: -10, y: -20),
            CGPoint(x: 1000, y: 2000)
        ]
        
        for (index, position) in positions.enumerated() {
            // When
            paletteViewModel.addComponentToCanvas(.text, at: position)
            
            // Then
            let component = editorViewModel.components[index]
            XCTAssertEqual(component.position.x, position.x, accuracy: 0.001)
            XCTAssertEqual(component.position.y, position.y, accuracy: 0.001)
        }
    }
    
    // MARK: - Drag and Drop Integration Tests
    
    func testCompleteDragAndDropWorkflow() {
        // Given
        let componentType = ComponentType.image
        let dropPosition = CGPoint(x: 150, y: 250)
        let initialCount = editorViewModel.components.count
        
        // When - simulate complete drag and drop
        paletteViewModel.startDragging(componentType)
        XCTAssertEqual(paletteViewModel.draggedComponent, componentType)
        
        paletteViewModel.addComponentToCanvas(componentType, at: dropPosition)
        paletteViewModel.endDragging()
        
        // Then
        XCTAssertNil(paletteViewModel.draggedComponent)
        XCTAssertEqual(editorViewModel.components.count, initialCount + 1)
        
        let addedComponent = editorViewModel.components.last!
        XCTAssertEqual(addedComponent.type, componentType)
        XCTAssertEqual(addedComponent.position, dropPosition)
    }
    
    func testDragWithoutDrop() {
        // Given
        let componentType = ComponentType.button
        let initialCount = editorViewModel.components.count
        
        // When - start dragging but don't drop
        paletteViewModel.startDragging(componentType)
        paletteViewModel.endDragging()
        
        // Then - no component should be added
        XCTAssertEqual(editorViewModel.components.count, initialCount)
        XCTAssertNil(paletteViewModel.draggedComponent)
    }
    
    // MARK: - Reactive Property Tests
    
    func testDraggedComponentPublishedUpdates() {
        let expectation = XCTestExpectation(description: "Dragged component updated")
        
        // Subscribe to dragged component changes
        paletteViewModel.$draggedComponent
            .dropFirst() // Skip initial nil value
            .sink { component in
                if component == .text {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        // When
        paletteViewModel.startDragging(.text)
        
        // Then
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testDraggedComponentPublishedUpdatesMultiple() {
        let expectation = XCTestExpectation(description: "Dragged component state updated")
        expectation.expectedFulfillmentCount = 2
        
        // Subscribe to dragged component changes
        paletteViewModel.$draggedComponent
            .dropFirst() // Skip initial nil value
            .sink { component in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        // When
        paletteViewModel.startDragging(.button)
        paletteViewModel.endDragging()
        
        // Then
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testMultiplePublishedUpdatesInSequence() {
        var updateCount = 0
        let expectation = XCTestExpectation(description: "Multiple updates received")
        expectation.expectedFulfillmentCount = 4
        
        // Subscribe to dragged component changes
        paletteViewModel.$draggedComponent
            .dropFirst() // Skip initial value
            .sink { _ in
                updateCount += 1
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        // When - perform multiple operations
        paletteViewModel.startDragging(.text)
        paletteViewModel.endDragging()
        paletteViewModel.startDragging(.button)
        paletteViewModel.endDragging()
        
        // Then
        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(updateCount, 4)
    }
    
    // MARK: - Component Type Information Tests
    
    func testGetComponentInfo() {
        // Test that we can get information about each component type
        for componentType in ComponentType.allCases {
            XCTAssertFalse(componentType.systemImage.isEmpty)
            XCTAssertFalse(componentType.rawValue.isEmpty)
        }
    }
    
    func testComponentTypeSystemImages() {
        // Verify system images for UI consistency
        XCTAssertEqual(ComponentType.text.systemImage, "textformat")
        XCTAssertEqual(ComponentType.textArea.systemImage, "text.justify")
        XCTAssertEqual(ComponentType.image.systemImage, "photo")
        XCTAssertEqual(ComponentType.button.systemImage, "button.roundedtop.horizontal")
    }
    
    // MARK: - Edge Cases Tests
    
    func testAddComponentWithZeroPosition() {
        // When
        paletteViewModel.addComponentToCanvas(.text, at: CGPoint.zero)
        
        // Then
        let component = editorViewModel.components.last!
        XCTAssertEqual(component.position, CGPoint.zero)
    }
    
    func testAddComponentWithNegativePosition() {
        // When
        paletteViewModel.addComponentToCanvas(.text, at: CGPoint(x: -50, y: -100))
        
        // Then
        let component = editorViewModel.components.last!
        XCTAssertEqual(component.position.x, -50)
        XCTAssertEqual(component.position.y, -100)
    }
    
    func testAddComponentWithLargePosition() {
        // When
        paletteViewModel.addComponentToCanvas(.text, at: CGPoint(x: 10000, y: 20000))
        
        // Then
        let component = editorViewModel.components.last!
        XCTAssertEqual(component.position.x, 10000)
        XCTAssertEqual(component.position.y, 20000)
    }
    
    func testMultipleEndDragCalls() {
        // Given
        paletteViewModel.startDragging(.text)
        XCTAssertNotNil(paletteViewModel.draggedComponent)
        
        // When - call endDragging multiple times
        paletteViewModel.endDragging()
        paletteViewModel.endDragging()
        paletteViewModel.endDragging()
        
        // Then - should remain in ended state
        XCTAssertNil(paletteViewModel.draggedComponent)
    }
    
    // MARK: - State Consistency Tests
    
    func testDragStateConsistency() {
        // Test that draggedComponent is managed consistently
        
        // Initially should be nil
        XCTAssertNil(paletteViewModel.draggedComponent)
        
        // When dragging starts, component should be set
        paletteViewModel.startDragging(.text)
        XCTAssertEqual(paletteViewModel.draggedComponent, .text)
        
        // When dragging ends, component should be cleared
        paletteViewModel.endDragging()
        XCTAssertNil(paletteViewModel.draggedComponent)
    }
    
    func testDragStateAfterComponentAddition() {
        // Given
        paletteViewModel.startDragging(.button)
        XCTAssertNotNil(paletteViewModel.draggedComponent)
        
        // When - add component (simulating drop)
        paletteViewModel.addComponentToCanvas(.button, at: CGPoint(x: 100, y: 100))
        
        // Then - drag state should remain until explicitly ended
        XCTAssertNotNil(paletteViewModel.draggedComponent)
        
        // When - explicitly end dragging
        paletteViewModel.endDragging()
        
        // Then - drag state should be cleared
        XCTAssertNil(paletteViewModel.draggedComponent)
    }
    
    // MARK: - Integration with Editor Tests
    
    func testEditorViewModelIntegration() {
        // Test that changes made through palette view model are reflected in editor view model
        
        // Initially no components
        XCTAssertEqual(editorViewModel.components.count, 0)
        XCTAssertNil(editorViewModel.selectedComponentId)
        
        // Add component through palette
        paletteViewModel.addComponentToCanvas(.text, at: CGPoint(x: 50, y: 75))
        
        // Verify editor state
        XCTAssertEqual(editorViewModel.components.count, 1)
        XCTAssertNotNil(editorViewModel.selectedComponentId)
        XCTAssertEqual(editorViewModel.components[0].type, .text)
        XCTAssertEqual(editorViewModel.components[0].position, CGPoint(x: 50, y: 75))
    }
    
    func testUndoRedoIntegrationAfterComponentAddition() {
        // Test that component addition through palette is included in undo/redo history
        
        // Initially no undo available
        XCTAssertFalse(editorViewModel.canUndo)
        
        // Add component through palette
        paletteViewModel.addComponentToCanvas(.image, at: CGPoint(x: 100, y: 200))
        
        // Should now be able to undo
        XCTAssertTrue(editorViewModel.canUndo)
        XCTAssertEqual(editorViewModel.components.count, 1)
        
        // Undo the addition
        editorViewModel.undo()
        XCTAssertEqual(editorViewModel.components.count, 0)
        
        // Should now be able to redo
        XCTAssertTrue(editorViewModel.canRedo)
        
        // Redo the addition
        editorViewModel.redo()
        XCTAssertEqual(editorViewModel.components.count, 1)
        XCTAssertEqual(editorViewModel.components[0].type, .image)
    }
    
    // MARK: - Memory Management Tests
    
    func testMemoryCleanup() {
        // Given
        weak var weakPaletteViewModel = paletteViewModel
        weak var weakEditorViewModel = editorViewModel
        
        // When
        paletteViewModel = nil
        editorViewModel = nil
        
        // Then - should be deallocated
        XCTAssertNil(weakPaletteViewModel)
        XCTAssertNil(weakEditorViewModel)
    }
    
    func testNoCyclicReferences() {
        // Test that palette view model doesn't create retain cycles with editor view model
        
        // Create a new editor and palette in a local scope
        var localEditorViewModel: EditorViewModel? = EditorViewModel()
        var localPaletteViewModel: ComponentPaletteViewModel? = ComponentPaletteViewModel(editorViewModel: localEditorViewModel!)
        
        weak var weakEditor = localEditorViewModel
        weak var weakPalette = localPaletteViewModel
        
        // Clear strong references
        localEditorViewModel = nil
        localPaletteViewModel = nil
        
        // Both should be deallocated
        XCTAssertNil(weakEditor)
        XCTAssertNil(weakPalette)
    }
    
    // MARK: - Performance Tests
    
    func testPerformanceOfComponentAddition() {
        measure {
            for i in 0..<100 {
                paletteViewModel.addComponentToCanvas(.text, at: CGPoint(x: Double(i), y: Double(i)))
            }
        }
    }
    
    func testPerformanceOfDragOperations() {
        measure {
            for componentType in ComponentType.allCases {
                for _ in 0..<25 {
                    paletteViewModel.startDragging(componentType)
                    paletteViewModel.endDragging()
                }
            }
        }
    }
    
    func testPerformanceOfReactiveUpdates() {
        // Setup subscription
        var updateCount = 0
        paletteViewModel.$draggedComponent
            .sink { _ in updateCount += 1 }
            .store(in: &cancellables)
        
        measure {
            for _ in 0..<50 {
                paletteViewModel.startDragging(.text)
                paletteViewModel.endDragging()
            }
        }
        
        // Verify updates occurred
        XCTAssertGreaterThan(updateCount, 100) // Start + end for each iteration
    }
}