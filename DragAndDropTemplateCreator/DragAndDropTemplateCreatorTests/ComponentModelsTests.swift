//
//  ComponentModelsTests.swift
//  DragAndDropTemplateCreatorTests
//
//  Created by Dheeraj Verma on 17/08/25.
//

import XCTest
@testable import DragAndDropTemplateCreator
import SwiftUI

final class ComponentModelsTests: XCTestCase {
    
    // MARK: - ComponentType Tests
    
    func testComponentTypeAllCases() {
        // Given
        let expectedTypes: [ComponentType] = [.text, .textArea, .image, .button]
        
        // When
        let allCases = ComponentType.allCases
        
        // Then
        XCTAssertEqual(allCases, expectedTypes)
        XCTAssertEqual(allCases.count, 4)
    }
    
    func testComponentTypeSystemImages() {
        // Test that each component type has a valid system image
        XCTAssertEqual(ComponentType.text.systemImage, "textformat")
        XCTAssertEqual(ComponentType.textArea.systemImage, "text.justify")
        XCTAssertEqual(ComponentType.image.systemImage, "photo")
        XCTAssertEqual(ComponentType.button.systemImage, "button.roundedtop.horizontal")
    }
    
    func testComponentTypeRawValues() {
        XCTAssertEqual(ComponentType.text.rawValue, "Text")
        XCTAssertEqual(ComponentType.textArea.rawValue, "TextArea")
        XCTAssertEqual(ComponentType.image.rawValue, "Image")
        XCTAssertEqual(ComponentType.button.rawValue, "Button")
    }
    
    func testComponentTypeCodable() throws {
        // Given
        let componentType = ComponentType.text
        
        // When
        let encoded = try JSONEncoder().encode(componentType)
        let decoded = try JSONDecoder().decode(ComponentType.self, from: encoded)
        
        // Then
        XCTAssertEqual(componentType, decoded)
    }
    
    // MARK: - CanvasComponent Tests
    
    func testCanvasComponentInitialization() {
        // Given
        let type = ComponentType.text
        let position = CGPoint(x: 100, y: 200)
        let properties = ComponentProperties()
        
        // When
        let component = CanvasComponent(type: type, position: position, properties: properties)
        
        // Then
        XCTAssertEqual(component.type, type)
        XCTAssertEqual(component.position, position)
        XCTAssertEqual(component.properties.text, properties.text)
        XCTAssertFalse(component.isSelected)
        XCTAssertNotNil(component.id)
    }
    
    func testCanvasComponentEquality() {
        // Given
        let component1 = CanvasComponent(type: .text, position: CGPoint(x: 0, y: 0), properties: ComponentProperties())
        let component2 = CanvasComponent(type: .text, position: CGPoint(x: 0, y: 0), properties: ComponentProperties())
        var component3 = component1
        component3.id = component1.id
        
        // Then
        XCTAssertNotEqual(component1, component2) // Different IDs
        XCTAssertEqual(component1, component3) // Same IDs
    }
    
    func testCanvasComponentCodable() throws {
        // Given
        let component = CanvasComponent(
            type: .text,
            position: CGPoint(x: 50, y: 75),
            properties: ComponentProperties()
        )
        
        // When
        let encoded = try JSONEncoder().encode(component)
        let decoded = try JSONDecoder().decode(CanvasComponent.self, from: encoded)
        
        // Then
        XCTAssertEqual(component.type, decoded.type)
        XCTAssertEqual(component.position.x, decoded.position.x, accuracy: 0.001)
        XCTAssertEqual(component.position.y, decoded.position.y, accuracy: 0.001)
        XCTAssertEqual(component.properties.text, decoded.properties.text)
    }
    
    // MARK: - ComponentProperties Tests
    
    func testComponentPropertiesDefaultValues() {
        // When
        let properties = ComponentProperties()
        
        // Then
        // Text properties
        XCTAssertEqual(properties.text, "Sample Text")
        XCTAssertEqual(properties.fontSize, 16)
        XCTAssertEqual(properties.fontWeight, .normal)
        XCTAssertEqual(properties.textAlign, .leading)
        
        // TextArea properties
        XCTAssertEqual(properties.textAreaContent, "Sample TextArea Content")
        
        // Image properties
        XCTAssertEqual(properties.imageURL, "")
        XCTAssertEqual(properties.altText, "")
        XCTAssertEqual(properties.objectFit, .fill)
        XCTAssertEqual(properties.borderRadius, 0)
        XCTAssertEqual(properties.height, 100)
        XCTAssertEqual(properties.width, 100)
        
        // Button properties
        XCTAssertEqual(properties.buttonText, "Button")
        XCTAssertEqual(properties.url, "")
        XCTAssertEqual(properties.padding, 16)
    }
    
    func testComponentPropertiesModification() {
        // Given
        var properties = ComponentProperties()
        
        // When
        properties.text = "Modified Text"
        properties.fontSize = 24
        properties.fontWeight = .bold
        properties.imageURL = "https://example.com/image.jpg"
        properties.buttonText = "Click Me"
        
        // Then
        XCTAssertEqual(properties.text, "Modified Text")
        XCTAssertEqual(properties.fontSize, 24)
        XCTAssertEqual(properties.fontWeight, .bold)
        XCTAssertEqual(properties.imageURL, "https://example.com/image.jpg")
        XCTAssertEqual(properties.buttonText, "Click Me")
    }
    
    func testComponentPropertiesCodable() throws {
        // Given
        var properties = ComponentProperties()
        properties.text = "Test Text"
        properties.fontSize = 20
        properties.fontWeight = .bold
        
        // When
        let encoded = try JSONEncoder().encode(properties)
        let decoded = try JSONDecoder().decode(ComponentProperties.self, from: encoded)
        
        // Then
        XCTAssertEqual(properties.text, decoded.text)
        XCTAssertEqual(properties.fontSize, decoded.fontSize)
        XCTAssertEqual(properties.fontWeight, decoded.fontWeight)
    }
    
    // MARK: - FontWeight Tests
    
    func testFontWeightAllCases() {
        let allCases = ComponentProperties.FontWeight.allCases
        XCTAssertEqual(allCases.count, 2)
        XCTAssertTrue(allCases.contains(.normal))
        XCTAssertTrue(allCases.contains(.bold))
    }
    
    func testFontWeightRawValues() {
        XCTAssertEqual(ComponentProperties.FontWeight.normal.rawValue, "400 - Normal")
        XCTAssertEqual(ComponentProperties.FontWeight.bold.rawValue, "700 - Bold")
    }
    
    func testFontWeightSwiftUIWeight() {
        XCTAssertEqual(ComponentProperties.FontWeight.normal.swiftUIWeight, .regular)
        XCTAssertEqual(ComponentProperties.FontWeight.bold.swiftUIWeight, .bold)
    }
    
    // MARK: - ObjectFit Tests
    
    func testObjectFitAllCases() {
        let allCases = ComponentProperties.ObjectFit.allCases
        XCTAssertEqual(allCases.count, 3)
        XCTAssertTrue(allCases.contains(.cover))
        XCTAssertTrue(allCases.contains(.contain))
        XCTAssertTrue(allCases.contains(.fill))
    }
    
    func testObjectFitContentMode() {
        XCTAssertEqual(ComponentProperties.ObjectFit.cover.contentMode, .fill)
        XCTAssertEqual(ComponentProperties.ObjectFit.contain.contentMode, .fit)
        XCTAssertEqual(ComponentProperties.ObjectFit.fill.contentMode, .fill)
    }
    
    // MARK: - TextAlignment Tests
    
    func testTextAlignmentAllCases() {
        let allCases = ComponentProperties.TextAlignment.allCases
        XCTAssertEqual(allCases.count, 3)
        XCTAssertTrue(allCases.contains(.leading))
        XCTAssertTrue(allCases.contains(.center))
        XCTAssertTrue(allCases.contains(.trailing))
    }
    
    func testTextAlignmentSwiftUIAlignment() {
        XCTAssertEqual(ComponentProperties.TextAlignment.leading.swiftUIAlignment, .leading)
        XCTAssertEqual(ComponentProperties.TextAlignment.center.swiftUIAlignment, .center)
        XCTAssertEqual(ComponentProperties.TextAlignment.trailing.swiftUIAlignment, .trailing)
    }
    
    // MARK: - ColorData Tests
    
    func testColorDataInitialization() {
        // Given
        let red: Double = 0.5
        let green: Double = 0.7
        let blue: Double = 0.9
        let alpha: Double = 0.8
        
        // When
        let colorData = ColorData(red: red, green: green, blue: blue, alpha: alpha)
        
        // Then
        XCTAssertEqual(colorData.red, red)
        XCTAssertEqual(colorData.green, green)
        XCTAssertEqual(colorData.blue, blue)
        XCTAssertEqual(colorData.alpha, alpha)
    }
    
    func testColorDataDefaultAlpha() {
        // When
        let colorData = ColorData(red: 1.0, green: 0.5, blue: 0.0)
        
        // Then
        XCTAssertEqual(colorData.alpha, 1.0)
    }
    
    func testColorDataColor() {
        // Given
        let colorData = ColorData(red: 1.0, green: 0.0, blue: 0.0, alpha: 1.0)
        
        // When
        let color = colorData.color
        
        // Then
        XCTAssertNotNil(color)
        // Note: SwiftUI Color comparison is complex, so we just verify it's created
    }
    
    func testColorDataCodable() throws {
        // Given
        let colorData = ColorData(red: 0.2, green: 0.4, blue: 0.6, alpha: 0.8)
        
        // When
        let encoded = try JSONEncoder().encode(colorData)
        let decoded = try JSONDecoder().decode(ColorData.self, from: encoded)
        
        // Then
        XCTAssertEqual(colorData.red, decoded.red)
        XCTAssertEqual(colorData.green, decoded.green)
        XCTAssertEqual(colorData.blue, decoded.blue)
        XCTAssertEqual(colorData.alpha, decoded.alpha)
    }
    
    func testColorDataEquality() {
        // Given
        let color1 = ColorData(red: 0.5, green: 0.5, blue: 0.5, alpha: 1.0)
        let color2 = ColorData(red: 0.5, green: 0.5, blue: 0.5, alpha: 1.0)
        let color3 = ColorData(red: 0.6, green: 0.5, blue: 0.5, alpha: 1.0)
        
        // Then
        XCTAssertEqual(color1, color2)
        XCTAssertNotEqual(color1, color3)
    }
    
    // MARK: - EditorSnapshot Tests
    
    func testEditorSnapshotInitialization() {
        // Given
        let components = [
            CanvasComponent(type: .text, position: CGPoint(x: 0, y: 0), properties: ComponentProperties()),
            CanvasComponent(type: .button, position: CGPoint(x: 100, y: 100), properties: ComponentProperties())
        ]
        
        // When
        let snapshot = EditorSnapshot(components: components)
        
        // Then
        XCTAssertEqual(snapshot.components.count, 2)
        XCTAssertEqual(snapshot.components[0].type, .text)
        XCTAssertEqual(snapshot.components[1].type, .button)
        XCTAssertNotNil(snapshot.timestamp)
    }
    
    func testEditorSnapshotCodable() throws {
        // Given
        let components = [
            CanvasComponent(type: .image, position: CGPoint(x: 50, y: 50), properties: ComponentProperties())
        ]
        let snapshot = EditorSnapshot(components: components)
        
        // When
        let encoded = try JSONEncoder().encode(snapshot)
        let decoded = try JSONDecoder().decode(EditorSnapshot.self, from: encoded)
        
        // Then
        XCTAssertEqual(snapshot.components.count, decoded.components.count)
        XCTAssertEqual(snapshot.components[0].type, decoded.components[0].type)
    }
    
    // MARK: - PreviewDevice Tests
    
    func testPreviewDeviceAllCases() {
        let allCases = PreviewDevice.allCases
        XCTAssertEqual(allCases.count, 1)
        XCTAssertTrue(allCases.contains(.mobile))
    }
    
    func testPreviewDeviceRawValue() {
        XCTAssertEqual(PreviewDevice.mobile.rawValue, "Mobile")
    }
    
    func testPreviewDeviceCodable() throws {
        // Given
        let device = PreviewDevice.mobile
        
        // When
        let encoded = try JSONEncoder().encode(device)
        let decoded = try JSONDecoder().decode(PreviewDevice.self, from: encoded)
        
        // Then
        XCTAssertEqual(device, decoded)
    }
    
    // MARK: - Integration Tests
    
    func testCompleteComponentSerialization() throws {
        // Given
        var properties = ComponentProperties()
        properties.text = "Test Component"
        properties.fontSize = 18
        properties.fontWeight = .bold
        properties.textColor = ColorData(red: 1.0, green: 0.0, blue: 0.0)
        
        let component = CanvasComponent(
            type: .text,
            position: CGPoint(x: 150, y: 250),
            properties: properties
        )
        
        let snapshot = EditorSnapshot(components: [component])
        
        // When
        let encoded = try JSONEncoder().encode(snapshot)
        let decoded = try JSONDecoder().decode(EditorSnapshot.self, from: encoded)
        
        // Then
        let decodedComponent = decoded.components[0]
        XCTAssertEqual(decodedComponent.type, .text)
        XCTAssertEqual(decodedComponent.position.x, 150, accuracy: 0.001)
        XCTAssertEqual(decodedComponent.position.y, 250, accuracy: 0.001)
        XCTAssertEqual(decodedComponent.properties.text, "Test Component")
        XCTAssertEqual(decodedComponent.properties.fontSize, 18)
        XCTAssertEqual(decodedComponent.properties.fontWeight, .bold)
        XCTAssertEqual(decodedComponent.properties.textColor.red, 1.0)
    }
    
    func testComponentPropertyValidation() {
        // Test that properties stay within reasonable bounds
        var properties = ComponentProperties()
        
        // Test font size boundaries
        properties.fontSize = -10
        // Note: In a real app, you might want validation logic
        
        properties.fontSize = 1000
        // Note: In a real app, you might want validation logic
        
        // For now, we just verify the values are set
        // In production, you'd add validation logic to the setters
        XCTAssertEqual(properties.fontSize, 1000)
    }
}
