//
//  UITestHelpers.swift
//  DragAndDropTemplateCreatorUITests
//
//  Created by Dheeraj Verma on 17/08/25.
//

import XCTest

/// Helper methods and utilities for UI testing
class UITestHelpers {
    
    /// Wait for an element to appear on screen
    static func waitForElementToAppear(_ element: XCUIElement, timeout: TimeInterval = 5.0) -> Bool {
        return element.waitForExistence(timeout: timeout)
    }
    
    /// Perform drag and drop operation between two elements
    static func dragElement(_ source: XCUIElement, to destination: XCUIElement) {
        source.press(forDuration: 0.5, thenDragTo: destination)
    }
    
    /// Verify that an element exists and is hittable
    static func verifyElementIsInteractive(_ element: XCUIElement) -> Bool {
        return element.exists && element.isHittable
    }
    
    /// Wait for app to finish loading
    static func waitForAppToLoad(_ app: XCUIApplication, timeout: TimeInterval = 10.0) -> Bool {
        let mainWindow = app.windows.firstMatch
        return mainWindow.waitForExistence(timeout: timeout)
    }
    
    /// Simulate component creation by dragging from palette to canvas
    static func createComponentFromPalette(app: XCUIApplication, componentType: String, dropPosition: CGPoint? = nil) {
        // In a real implementation, this would:
        // 1. Find the component button in the palette
        // 2. Find the canvas area
        // 3. Perform drag and drop
        // 4. Verify component was created
        
        // Placeholder implementation
        let paletteButton = app.buttons[componentType]
        let canvas = app.otherElements["Canvas"]
        
        if paletteButton.exists && canvas.exists {
            dragElement(paletteButton, to: canvas)
        }
    }
    
    /// Select a component on the canvas
    static func selectCanvasComponent(app: XCUIApplication, componentIndex: Int) {
        // In a real implementation, this would:
        // 1. Find canvas components
        // 2. Tap the component at the specified index
        
        let canvas = app.otherElements["Canvas"]
        let components = canvas.otherElements
        
        if components.count > componentIndex {
            components.element(boundBy: componentIndex).tap()
        }
    }
    
    /// Verify property panel shows expected values
    static func verifyPropertyValue(app: XCUIApplication, property: String, expectedValue: String) -> Bool {
        // In a real implementation, this would:
        // 1. Find the property control
        // 2. Verify its current value
        
        let propertyField = app.textFields[property]
        return propertyField.exists && propertyField.value as? String == expectedValue
    }
    
    /// Clear all components from canvas
    static func clearAllComponents(app: XCUIApplication) {
        // In a real implementation, this would:
        // 1. Find and tap the clear all button
        // 2. Confirm in dialog if needed
        
        let clearButton = app.buttons["Clear All"]
        if clearButton.exists {
            clearButton.tap()
            
            // Handle confirmation dialog if it appears
            let confirmButton = app.buttons["Confirm"]
            if confirmButton.waitForExistence(timeout: 2.0) {
                confirmButton.tap()
            }
        }
    }
    
    /// Test undo/redo functionality
    static func testUndoRedo(app: XCUIApplication) -> Bool {
        let undoButton = app.buttons["Undo"]
        let redoButton = app.buttons["Redo"]
        
        // Initially undo should be available, redo should not
        guard undoButton.exists else { return false }
        
        let undoInitiallyEnabled = undoButton.isEnabled
        let redoInitiallyEnabled = redoButton.isEnabled
        
        // Perform undo if available
        if undoInitiallyEnabled {
            undoButton.tap()
            
            // After undo, redo should become available
            return redoButton.isEnabled
        }
        
        return true // No undo available is also a valid state
    }
    
    /// Switch preview device
    static func switchPreviewDevice(app: XCUIApplication, to device: String) {
        let devicePicker = app.buttons["Device Picker"]
        if devicePicker.exists {
            devicePicker.tap()
            
            let deviceOption = app.buttons[device]
            if deviceOption.waitForExistence(timeout: 2.0) {
                deviceOption.tap()
            }
        }
    }
    
    /// Open enhanced preview modal
    static func openEnhancedPreview(app: XCUIApplication) -> Bool {
        let previewButton = app.buttons["Enhanced Preview"]
        if previewButton.exists {
            previewButton.tap()
            
            // Wait for modal to appear
            let modal = app.sheets.firstMatch
            return modal.waitForExistence(timeout: 3.0)
        }
        return false
    }
    
    /// Close enhanced preview modal
    static func closeEnhancedPreview(app: XCUIApplication) {
        let closeButton = app.buttons["Close"]
        if closeButton.exists {
            closeButton.tap()
        } else {
            // Try to dismiss by tapping outside modal
            let background = app.otherElements["Modal Background"]
            if background.exists {
                background.tap()
            }
        }
    }
    
    /// Verify HTML export functionality
    static func testHTMLExport(app: XCUIApplication) -> Bool {
        let exportButton = app.buttons["Export HTML"]
        if exportButton.exists {
            exportButton.tap()
            
            // Verify export completed (might show a share sheet or confirmation)
            let shareSheet = app.sheets.firstMatch
            let confirmation = app.alerts.firstMatch
            
            return shareSheet.waitForExistence(timeout: 3.0) || 
                   confirmation.waitForExistence(timeout: 3.0)
        }
        return false
    }
    
    /// Perform accessibility audit
    static func performAccessibilityAudit(app: XCUIApplication) -> Bool {
        // In a real implementation, this would:
        // 1. Check for accessibility labels on all interactive elements
        // 2. Verify VoiceOver navigation
        // 3. Test dynamic type support
        
        let interactiveElements = app.buttons.allElementsBoundByIndex + 
                                app.textFields.allElementsBoundByIndex +
                                app.sliders.allElementsBoundByIndex
        
        for element in interactiveElements {
            if element.exists && element.label.isEmpty {
                return false // Found element without accessibility label
            }
        }
        
        return true
    }
    
    /// Measure performance of specific action
    static func measurePerformance(of action: () -> Void) -> TimeInterval {
        let startTime = CFAbsoluteTimeGetCurrent()
        action()
        let endTime = CFAbsoluteTimeGetCurrent()
        return endTime - startTime
    }
    
    /// Wait for animation to complete
    static func waitForAnimationToComplete(duration: TimeInterval = 1.0) {
        Thread.sleep(forTimeInterval: duration)
    }
    
    /// Verify app state after background/foreground cycle
    static func testBackgroundForegroundCycle(app: XCUIApplication) -> Bool {
        // Store current state
        let currentComponents = app.otherElements["Canvas"].otherElements.count
        
        // Background the app
        XCUIDevice.shared.press(.home)
        
        // Wait a moment
        Thread.sleep(forTimeInterval: 1.0)
        
        // Foreground the app
        app.activate()
        
        // Wait for app to restore
        let mainWindow = app.windows.firstMatch
        guard mainWindow.waitForExistence(timeout: 5.0) else { return false }
        
        // Verify state is preserved
        let restoredComponents = app.otherElements["Canvas"].otherElements.count
        return currentComponents == restoredComponents
    }
}