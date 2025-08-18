//
//  PreviewViewModelTests.swift
//  DragAndDropTemplateCreatorTests
//
//  Created by Dheeraj Verma on 17/08/25.
//

import XCTest
import Combine
@testable import DragAndDropTemplateCreator
import SwiftUI

final class PreviewViewModelTests: XCTestCase {
    
    var editorViewModel: EditorViewModel!
    var previewViewModel: PreviewViewModel!
    var cancellables: Set<AnyCancellable>!
    
    override func setUpWithError() throws {
        super.setUp()
        editorViewModel = EditorViewModel()
        previewViewModel = PreviewViewModel(editorViewModel: editorViewModel)
        cancellables = Set<AnyCancellable>()
        
        // Clear UserDefaults for clean test state
        UserDefaults.standard.removeObject(forKey: "editorComponents")
    }
    
    override func tearDownWithError() throws {
        cancellables = nil
        previewViewModel = nil
        editorViewModel = nil
        UserDefaults.standard.removeObject(forKey: "editorComponents")
        super.tearDown()
    }
    
    // MARK: - Initialization Tests
    
    func testInitialState() {
        XCTAssertEqual(previewViewModel.selectedDevice, .mobile)
        XCTAssertFalse(previewViewModel.showExportOptions)
        XCTAssertEqual(previewViewModel.previewWidth, 375)
        XCTAssertEqual(previewViewModel.previewHeight, 812)
    }
    
    func testInitializationWithEditorViewModel() {
        XCTAssertNotNil(previewViewModel)
    }
    
    // MARK: - EnhancedPreviewDevice Tests
    
    func testEnhancedPreviewDeviceAllCases() {
        let allCases = EnhancedPreviewDevice.allCases
        XCTAssertEqual(allCases.count, 2)
        XCTAssertTrue(allCases.contains(.mobile))
        XCTAssertTrue(allCases.contains(.tablet))
    }
    
    func testEnhancedPreviewDeviceRawValues() {
        XCTAssertEqual(EnhancedPreviewDevice.mobile.rawValue, "iPhone")
        XCTAssertEqual(EnhancedPreviewDevice.tablet.rawValue, "iPad")
    }
    
    func testEnhancedPreviewDeviceDimensions() {
        XCTAssertEqual(EnhancedPreviewDevice.mobile.dimensions, CGSize(width: 375, height: 812))
        XCTAssertEqual(EnhancedPreviewDevice.tablet.dimensions, CGSize(width: 768, height: 1024))
    }
    
    func testEnhancedPreviewDeviceSystemImages() {
        XCTAssertEqual(EnhancedPreviewDevice.mobile.systemImage, "iphone")
        XCTAssertEqual(EnhancedPreviewDevice.tablet.systemImage, "ipad")
    }
    
    // MARK: - Device Selection Tests
    
    func testSelectDevice() {
        // Given
        XCTAssertEqual(previewViewModel.selectedDevice, .mobile)
        
        // When
        previewViewModel.selectDevice(.tablet)
        
        // Then
        XCTAssertEqual(previewViewModel.selectedDevice, .tablet)
        XCTAssertEqual(previewViewModel.previewWidth, 768)
        XCTAssertEqual(previewViewModel.previewHeight, 1024)
    }
    
    func testSelectSameDevice() {
        // Given
        previewViewModel.selectDevice(.mobile)
        XCTAssertEqual(previewViewModel.selectedDevice, .mobile)
        
        // When
        previewViewModel.selectDevice(.mobile)
        
        // Then
        XCTAssertEqual(previewViewModel.selectedDevice, .mobile)
    }
    
    // MARK: - Preview Dimensions Tests
    
    func testPreviewDimensionsMobile() {
        // When
        previewViewModel.selectDevice(.mobile)
        
        // Then
        XCTAssertEqual(previewViewModel.previewWidth, 375)
        XCTAssertEqual(previewViewModel.previewHeight, 812)
    }
    
    func testPreviewDimensionsTablet() {
        // When
        previewViewModel.selectDevice(.tablet)
        
        // Then
        XCTAssertEqual(previewViewModel.previewWidth, 768)
        XCTAssertEqual(previewViewModel.previewHeight, 1024)
    }
    
    // MARK: - HTML Generation Tests
    
    func testGenerateHTMLEmptyComponents() {
        // When
        let html = previewViewModel.shareHTML()
        
        // Then
        XCTAssertTrue(html.contains("<!DOCTYPE html>"))
        XCTAssertTrue(html.contains("<html"))
        XCTAssertTrue(html.contains("</html>"))
        XCTAssertTrue(html.contains("<body>"))
        XCTAssertTrue(html.contains("</body>"))
    }
    
    func testGenerateHTMLWithComponents() {
        // Given
        editorViewModel.addComponent(.text, at: CGPoint(x: 100, y: 200))
        var properties = ComponentProperties()
        properties.text = "Preview Test"
        properties.fontSize = 20
        
        let component = editorViewModel.components[0]
        editorViewModel.updateComponentProperties(component.id, properties: properties)
        
        // When
        let html = previewViewModel.shareHTML()
        
        // Then
        XCTAssertTrue(html.contains("Preview Test"))
        XCTAssertTrue(html.contains("font-size: 20px"))
        XCTAssertTrue(html.contains("position: absolute"))
        XCTAssertTrue(html.contains("left: 100px"))
        XCTAssertTrue(html.contains("top: 200px"))
    }
    
    func testGenerateHTMLWithTextComponent() {
        // Given
        editorViewModel.addComponent(.text, at: CGPoint(x: 50, y: 75))
        var properties = ComponentProperties()
        properties.text = "Text Component"
        properties.fontSize = 18
        properties.fontWeight = .bold
        properties.textColor = ColorData(red: 1.0, green: 0.0, blue: 0.0)
        
        let component = editorViewModel.components[0]
        editorViewModel.updateComponentProperties(component.id, properties: properties)
        
        // When
        let html = previewViewModel.shareHTML()
        
        // Then
        XCTAssertTrue(html.contains("<span"))
        XCTAssertTrue(html.contains("Text Component"))
        XCTAssertTrue(html.contains("font-size: 18px"))
        XCTAssertTrue(html.contains("font-weight: bold"))
        XCTAssertTrue(html.contains("color: rgb(255, 0, 0)"))
    }
    
    func testGenerateHTMLWithButtonComponent() {
        // Given
        editorViewModel.addComponent(.button, at: CGPoint(x: 100, y: 150))
        var properties = ComponentProperties()
        properties.buttonText = "Click Me"
        properties.url = "https://example.com"
        properties.fontSize = 16
        properties.backgroundColor = ColorData(red: 0.0, green: 1.0, blue: 0.0)
        properties.padding = 20
        properties.borderRadius = 8
        
        let component = editorViewModel.components[0]
        editorViewModel.updateComponentProperties(component.id, properties: properties)
        
        // When
        let html = previewViewModel.shareHTML()
        
        // Then
        XCTAssertTrue(html.contains("<a"))
        XCTAssertTrue(html.contains("href=\"https://example.com\""))
        XCTAssertTrue(html.contains("Click Me"))
        XCTAssertTrue(html.contains("background-color: rgb(0, 255, 0)"))
        XCTAssertTrue(html.contains("padding: 20px"))
        XCTAssertTrue(html.contains("border-radius: 8px"))
    }
    
    func testGenerateHTMLWithImageComponent() {
        // Given
        editorViewModel.addComponent(.image, at: CGPoint(x: 200, y: 250))
        var properties = ComponentProperties()
        properties.imageURL = "https://example.com/image.jpg"
        properties.altText = "Test Image"
        properties.width = 150
        properties.height = 100
        properties.borderRadius = 5
        
        let component = editorViewModel.components[0]
        editorViewModel.updateComponentProperties(component.id, properties: properties)
        
        // When
        let html = previewViewModel.shareHTML()
        
        // Then
        XCTAssertTrue(html.contains("<img"))
        XCTAssertTrue(html.contains("src=\"https://example.com/image.jpg\""))
        XCTAssertTrue(html.contains("alt=\"Test Image\""))
        XCTAssertTrue(html.contains("width: 150px"))
        XCTAssertTrue(html.contains("height: 100px"))
        XCTAssertTrue(html.contains("border-radius: 5px"))
    }
    
    func testGenerateHTMLWithTextAreaComponent() {
        // Given
        editorViewModel.addComponent(.textArea, at: CGPoint(x: 75, y: 125))
        var properties = ComponentProperties()
        properties.textAreaContent = "Multi-line\ntext content"
        properties.fontSize = 14
        properties.textAlign = .center
        properties.textColor = ColorData(red: 0.5, green: 0.5, blue: 0.5)
        
        let component = editorViewModel.components[0]
        editorViewModel.updateComponentProperties(component.id, properties: properties)
        
        // When
        let html = previewViewModel.shareHTML()
        
        // Then
        XCTAssertTrue(html.contains("<div"))
        XCTAssertTrue(html.contains("Multi-line<br>text content"))
        XCTAssertTrue(html.contains("font-size: 14px"))
        XCTAssertTrue(html.contains("text-align: center"))
        XCTAssertTrue(html.contains("color: rgb(128, 128, 128)"))
    }
    
    // MARK: - Export Functionality Tests
    
    func testExportHTML() {
        // Given
        editorViewModel.addComponent(.text, at: CGPoint(x: 0, y: 0))
        
        // When
        previewViewModel.showExportSheet()
        
        // Then
        XCTAssertTrue(previewViewModel.showExportOptions)
        
        // Wait for export to complete
        let expectation = XCTestExpectation(description: "Export completed")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
        
        XCTAssertFalse(previewViewModel.showExportOptions)
    }
    
    func testExportHTMLSetsIsExportingFlag() {
        // Given
        XCTAssertFalse(previewViewModel.showExportOptions)
        
        // When
        previewViewModel.showExportSheet()
        
        // Then
        XCTAssertTrue(previewViewModel.showExportOptions)
    }
    
    // MARK: - Reactive Updates Tests
    
    func testSelectedDevicePublishedUpdates() {
        let expectation = XCTestExpectation(description: "Selected device updated")
        
        // Subscribe to selected device changes
        previewViewModel.$selectedDevice
            .dropFirst() // Skip initial value
            .sink { device in
                if device == .tablet {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        // When
        previewViewModel.selectDevice(.tablet)
        
        // Then
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testIsExportingPublishedUpdates() {
        let expectation = XCTestExpectation(description: "Export state updated")
        
        // Subscribe to export state changes
        previewViewModel.$showExportOptions
            .dropFirst() // Skip initial value
            .sink { isExporting in
                if isExporting {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        // When
        previewViewModel.showExportSheet()
        
        // Then
        wait(for: [expectation], timeout: 1.0)
    }
    
    // MARK: - HTML Generation Edge Cases
    
    func testGenerateHTMLWithSpecialCharacters() {
        // Given
        editorViewModel.addComponent(.text, at: CGPoint(x: 0, y: 0))
        var properties = ComponentProperties()
        properties.text = "<script>alert('test')</script> & \"quotes\""
        
        let component = editorViewModel.components[0]
        editorViewModel.updateComponentProperties(component.id, properties: properties)
        
        // When
        let html = previewViewModel.shareHTML()
        
        // Then
        // Should escape HTML special characters
        XCTAssertTrue(html.contains("&lt;script&gt;"))
        XCTAssertTrue(html.contains("&amp;"))
        XCTAssertTrue(html.contains("&quot;"))
    }
    
    func testGenerateHTMLWithEmptyImageURL() {
        // Given
        editorViewModel.addComponent(.image, at: CGPoint(x: 0, y: 0))
        var properties = ComponentProperties()
        properties.imageURL = ""
        properties.altText = "Empty URL"
        
        let component = editorViewModel.components[0]
        editorViewModel.updateComponentProperties(component.id, properties: properties)
        
        // When
        let html = previewViewModel.shareHTML()
        
        // Then
        XCTAssertTrue(html.contains("src=\"\""))
        XCTAssertTrue(html.contains("alt=\"Empty URL\""))
    }
    
    func testGenerateHTMLWithEmptyButtonURL() {
        // Given
        editorViewModel.addComponent(.button, at: CGPoint(x: 0, y: 0))
        var properties = ComponentProperties()
        properties.url = ""
        properties.buttonText = "No URL"
        
        let component = editorViewModel.components[0]
        editorViewModel.updateComponentProperties(component.id, properties: properties)
        
        // When
        let html = previewViewModel.shareHTML()
        
        // Then
        XCTAssertTrue(html.contains("href=\"#\"")) // Should default to #
        XCTAssertTrue(html.contains("No URL"))
    }
    
    // MARK: - Multiple Components HTML Generation
    
    func testGenerateHTMLWithMultipleComponents() {
        // Given
        editorViewModel.addComponent(.text, at: CGPoint(x: 0, y: 0))
        editorViewModel.addComponent(.button, at: CGPoint(x: 100, y: 100))
        editorViewModel.addComponent(.image, at: CGPoint(x: 200, y: 200))
        editorViewModel.addComponent(.textArea, at: CGPoint(x: 300, y: 300))
        
        // When
        let html = previewViewModel.shareHTML()
        
        // Then
        XCTAssertTrue(html.contains("<span")) // Text component
        XCTAssertTrue(html.contains("<a")) // Button component
        XCTAssertTrue(html.contains("<img")) // Image component
        XCTAssertTrue(html.contains("<div")) // TextArea component
        
        // Check positioning
        XCTAssertTrue(html.contains("left: 0px"))
        XCTAssertTrue(html.contains("left: 100px"))
        XCTAssertTrue(html.contains("left: 200px"))
        XCTAssertTrue(html.contains("left: 300px"))
    }
    
    // MARK: - Color Formatting Tests
    
    func testColorFormattingInHTML() {
        // Given
        editorViewModel.addComponent(.text, at: CGPoint(x: 0, y: 0))
        var properties = ComponentProperties()
        properties.textColor = ColorData(red: 0.5, green: 0.75, blue: 1.0, alpha: 0.8)
        
        let component = editorViewModel.components[0]
        editorViewModel.updateComponentProperties(component.id, properties: properties)
        
        // When
        let html = previewViewModel.shareHTML()
        
        // Then
        // Color should be formatted as rgb(128, 191, 255) (0.5*255, 0.75*255, 1.0*255)
        XCTAssertTrue(html.contains("rgb(128, 191, 255)"))
    }
    
    // MARK: - Integration Tests
    
    func testCompletePreviewWorkflow() {
        // Given - Create a complete template
        editorViewModel.addComponent(.text, at: CGPoint(x: 50, y: 50))
        var textProperties = ComponentProperties()
        textProperties.text = "Header Text"
        textProperties.fontSize = 24
        textProperties.fontWeight = .bold
        editorViewModel.updateComponentProperties(editorViewModel.components[0].id, properties: textProperties)
        
        editorViewModel.addComponent(.button, at: CGPoint(x: 50, y: 150))
        var buttonProperties = ComponentProperties()
        buttonProperties.buttonText = "Action Button"
        buttonProperties.url = "https://example.com"
        buttonProperties.backgroundColor = ColorData(red: 0.0, green: 0.5, blue: 1.0)
        editorViewModel.updateComponentProperties(editorViewModel.components[1].id, properties: buttonProperties)
        
        // Test different device previews
        previewViewModel.selectDevice(.mobile)
        let mobileHTML = previewViewModel.shareHTML()
        XCTAssertTrue(mobileHTML.contains("Header Text"))
        XCTAssertTrue(mobileHTML.contains("Action Button"))
        
        previewViewModel.selectDevice(.tablet)
        let tabletHTML = previewViewModel.shareHTML()
        XCTAssertTrue(tabletHTML.contains("Header Text"))
        XCTAssertTrue(tabletHTML.contains("Action Button"))
        
        // Test export functionality
        previewViewModel.showExportSheet()
        XCTAssertTrue(previewViewModel.showExportOptions)
    }
    
    // MARK: - Memory Management Tests
    
    func testMemoryCleanup() {
        // Given
        weak var weakPreviewViewModel = previewViewModel
        weak var weakEditorViewModel = editorViewModel
        
        // When
        previewViewModel = nil
        editorViewModel = nil
        
        // Then - should be deallocated
        XCTAssertNil(weakPreviewViewModel)
        XCTAssertNil(weakEditorViewModel)
    }
    
    // MARK: - Performance Tests
    
    func testPerformanceOfHTMLGeneration() {
        // Setup - create multiple components
        for i in 0..<20 {
            editorViewModel.addComponent(.text, at: CGPoint(x: Double(i * 50), y: Double(i * 25)))
        }
        
        measure {
            _ = previewViewModel.shareHTML()
        }
    }
    
    func testPerformanceOfDeviceSwitching() {
        measure {
            for _ in 0..<100 {
                previewViewModel.selectDevice(.mobile)
                previewViewModel.selectDevice(.tablet)
            }
        }
    }
    
    // MARK: - CSS Generation Tests
    
    func testCSSStyleGeneration() {
        // Given
        editorViewModel.addComponent(.text, at: CGPoint(x: 100, y: 200))
        var properties = ComponentProperties()
        properties.fontSize = 18
        properties.fontWeight = .bold
        properties.textColor = ColorData(red: 1.0, green: 0.0, blue: 0.0)
        
        let component = editorViewModel.components[0]
        editorViewModel.updateComponentProperties(component.id, properties: properties)
        
        // When
        let html = previewViewModel.shareHTML()
        
        // Then - check for proper CSS formatting
        XCTAssertTrue(html.contains("position: absolute;"))
        XCTAssertTrue(html.contains("left: 100px;"))
        XCTAssertTrue(html.contains("top: 200px;"))
        XCTAssertTrue(html.contains("font-size: 18px;"))
        XCTAssertTrue(html.contains("font-weight: bold;"))
        XCTAssertTrue(html.contains("color: rgb(255, 0, 0);"))
    }
}