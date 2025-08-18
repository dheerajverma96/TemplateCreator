# 📁 Project Structure

## 🏗️ Overview

The **DragAndDropTemplateCreator** is an iOS application built using **SwiftUI** and follows the **MVVM (Model-View-ViewModel)** architectural pattern. This document provides a comprehensive overview of the project structure, explaining the purpose and responsibility of each folder, file, and module.

## 📂 Root Directory Structure

```
DragAndDropTemplateCreator/
├── DragAndDropTemplateCreator.xcodeproj/     # Xcode project configuration
├── DragAndDropTemplateCreator/               # Main application source code
├── DragAndDropTemplateCreatorTests/          # Unit tests
├── DragAndDropTemplateCreatorUITests/        # UI/Integration tests
├── README.md                                 # Project documentation
└── PROJECT_STRUCTURE.md                     # This file
```

---

## 🎯 Main Application Directory

### `DragAndDropTemplateCreator/`

The core application directory containing all source code, organized following MVVM architecture principles.

```
DragAndDropTemplateCreator/
├── Models/                          # Data layer
│   └── ComponentModels.swift        # Core data models
├── ViewModels/                      # Business logic layer
│   ├── EditorViewModel.swift        # Main editor state management
│   ├── ComponentPaletteViewModel.swift  # Component selection logic
│   ├── PropertiesViewModel.swift    # Property editing logic
│   └── PreviewViewModel.swift       # Preview functionality
├── Views/                           # Presentation layer
│   ├── CanvasView.swift            # Main canvas interface
│   ├── ComponentPaletteView.swift   # Component selection UI
│   ├── PropertiesView.swift        # Property editing panels
│   ├── ComponentViews.swift        # Individual component renderers
│   └── EnhancedPreviewView.swift   # Preview system
├── ContentView.swift                # Root view coordinator
├── DragAndDropTemplateCreatorApp.swift  # App entry point
└── Assets.xcassets/                 # Images, icons, and color assets
```

---

## 📦 Models Layer (`Models/`)

The Models layer contains pure data structures without business logic, representing the core entities of the application.

### `ComponentModels.swift`

**Purpose**: Defines all data models used throughout the application.

**Key Components**:

#### **ComponentType** (Enum)
- Defines available component types: `text`, `textArea`, `image`, `button`
- Provides system icons for each component type
- Used for component palette and type identification

#### **CanvasComponent** (Struct)
- Represents individual components on the canvas
- Contains: `id`, `type`, `position`, `properties`, `isSelected`
- Implements `Identifiable`, `Codable`, `Equatable` for SwiftUI integration

#### **ComponentProperties** (Struct)
- Unified property container for all component types
- Contains all configurable properties (text, font, colors, dimensions, etc.)
- Includes nested enums for type-safe property values

#### **EditorSnapshot** (Struct)
- Immutable state capture for undo/redo functionality
- Contains component array and timestamp
- Used by history management system

#### **ColorData** (Struct)
- Codable wrapper for SwiftUI Color
- Enables color persistence and serialization
- Provides conversion between Color and RGB values

#### **PreviewDevice** (Enum)
- Defines available preview modes (mobile-only after desktop removal)
- Used for preview system configuration

**Dependencies**: None (pure data layer)

---

## 🧠 ViewModels Layer (`ViewModels/`)

The ViewModels layer contains business logic and state management, acting as intermediaries between Models and Views.

### `EditorViewModel.swift`

**Purpose**: Central state manager and primary business logic coordinator.

**Responsibilities**:
- **Component Management**: Add, update, delete, move components
- **Selection State**: Track selected component
- **History Management**: Undo/redo with 50-step history
- **Persistence**: Save/load state using UserDefaults
- **HTML Generation**: Export functionality
- **Preview Mode**: Toggle between edit and preview states

**Key Methods**:
- `addComponent(_:at:)` - Add new component to canvas
- `updateComponentPosition(_:to:)` - Handle component movement
- `updateComponentProperties(_:properties:)` - Property modifications
- `undo()` / `redo()` - History navigation
- `generateHTML()` - Export to HTML

**Published Properties**:
- `@Published var components: [CanvasComponent]`
- `@Published var selectedComponentId: UUID?`
- `@Published var isPreviewMode: Bool`
- `@Published var previewDevice: PreviewDevice`

**Dependencies**: ComponentModels

### `ComponentPaletteViewModel.swift`

**Purpose**: Manages component palette behavior and drag-and-drop validation.

**Responsibilities**:
- **Available Components**: Provide list of draggable components
- **Drag State**: Track dragging operations
- **Drop Validation**: Determine valid drop zones
- **Position Conversion**: Convert screen coordinates to canvas coordinates

**Key Methods**:
- `startDragging(_:)` / `endDragging()` - Drag state management
- `canDropComponent(at:screenWidth:)` - Drop validation
- `addComponentToCanvas(_:at:)` - Component creation

**Dependencies**: EditorViewModel, ComponentModels

### `PropertiesViewModel.swift`

**Purpose**: Handles property editing logic with reactive updates.

**Responsibilities**:
- **Property Binding**: Connect UI controls to component properties
- **Real-time Updates**: Immediate reflection of property changes
- **Type Safety**: Strongly-typed property modifications
- **Component Synchronization**: Keep properties in sync with selected component

**Key Features**:
- **Reactive Programming**: Uses Combine for automatic updates
- **Generic Property Updates**: Type-safe property modification system
- **Specialized Methods**: Individual methods for each property type

**Key Methods**:
- `updateProperty(_:value:)` - Generic property update
- `updateText(_:)`, `updateFontSize(_:)`, etc. - Specific property updates

**Dependencies**: EditorViewModel, ComponentModels, Combine

### `PreviewViewModel.swift`

**Purpose**: Manages preview functionality and export operations.

**Responsibilities**:
- **Device Selection**: Handle iPhone/iPad preview modes
- **Preview States**: Manage inline vs. modal preview
- **Export Operations**: HTML generation and sharing
- **Full-Screen Mode**: Toggle immersive preview experience

**Key Methods**:
- `presentPreview()` / `dismissPreview()` - Modal management
- `selectDevice(_:)` - Device switching
- `copyHTMLToClipboard()` - Quick export
- `shareHTML()` - Full export functionality

**Dependencies**: EditorViewModel, ComponentModels

---

## 🎨 Views Layer (`Views/`)

The Views layer contains SwiftUI views responsible for user interface presentation, with no business logic.

### `CanvasView.swift`

**Purpose**: Main interactive canvas where components are displayed and manipulated.

**Responsibilities**:
- **Component Rendering**: Display all canvas components
- **Edit vs Preview**: Switch between editing and preview modes
- **Gesture Handling**: Component selection and movement
- **Inline Preview**: Quick preview functionality

**Key Components**:
- `EditingCanvasView` - Interactive editing mode
- `InlinePreviewView` - Quick preview with controls
- `CanvasComponentView` - Individual component wrapper with gestures

**Dependencies**: EditorViewModel, PreviewViewModel

### `ComponentPaletteView.swift`

**Purpose**: Component selection interface with drag-and-drop functionality.

**Responsibilities**:
- **Component Display**: Show available component types
- **Drag Gestures**: Handle component dragging
- **Visual Feedback**: Provide drag state feedback
- **Grid Layout**: Organize components in accessible grid

**Key Components**:
- `ComponentPaletteItemView` - Individual draggable component

**Dependencies**: ComponentPaletteViewModel

### `PropertiesView.swift`

**Purpose**: Dynamic property editing interface that adapts to selected component.

**Responsibilities**:
- **Context-Aware UI**: Show relevant properties for selected component
- **Property Controls**: Sliders, pickers, text fields, color pickers
- **Real-time Updates**: Immediate visual feedback
- **Organized Layout**: Group related properties logically

**Key Components**:
- `TextPropertiesView` - Text-specific properties
- `TextAreaPropertiesView` - TextArea-specific properties
- `ImagePropertiesView` - Image-specific properties
- `ButtonPropertiesView` - Button-specific properties
- `PropertySection` - Reusable property group container
- `ColorPickerView` - Custom color selection

**Dependencies**: PropertiesViewModel

### `ComponentViews.swift`

**Purpose**: Individual component rendering and editing interfaces.

**Responsibilities**:
- **Component Rendering**: Visual representation of each component type
- **Inline Editing**: Double-tap text editing functionality
- **Preview Rendering**: Static preview representations
- **Interactive Elements**: Functional buttons in preview mode

**Key Components**:
- `EditableTextView` - Text with inline editing
- `EditableTextAreaView` - Multi-line text editing
- `ImageComponentView` - Image display with async loading
- `ButtonComponentView` - Button rendering
- `InteractivePreviewComponentView` - Preview-specific rendering

**Dependencies**: EditorViewModel, ComponentModels

### `EnhancedPreviewView.swift`

**Purpose**: Comprehensive preview system with device simulation and export options.

**Responsibilities**:
- **Device Simulation**: iPhone and iPad frames
- **Full-Screen Mode**: Immersive preview experience
- **Export Interface**: Comprehensive sharing options
- **Interactive Preview**: Functional component behavior

**Key Components**:
- `ExportOptionsView` - Export and sharing interface
- `ExportOptionRow` - Individual export option
- `ShareSheet` - Native iOS sharing

**Dependencies**: PreviewViewModel

---

## 🏠 Root Level Files

### `ContentView.swift`

**Purpose**: Root view coordinator and dependency injection container.

**Responsibilities**:
- **MVVM Coordination**: Create and inject ViewModels into Views
- **Layout Management**: Three-panel layout (20%-60%-20%)
- **Navigation**: Root NavigationView container
- **Toolbar**: Top-level action buttons
- **Modal Presentation**: Sheet presentations

**Key Features**:
- **Dependency Injection**: Proper ViewModel instantiation and injection
- **Navigation Structure**: NavigationView with toolbar
- **Modal Management**: Sheet presentation for enhanced preview

### `DragAndDropTemplateCreatorApp.swift`

**Purpose**: Application entry point and configuration.

**Responsibilities**:
- **App Lifecycle**: Main app structure
- **Root View**: Present ContentView
- **App Configuration**: Set up app-wide settings

---

## 🧪 Testing Directories

### `DragAndDropTemplateCreatorTests/`

**Purpose**: Unit tests for business logic and ViewModels.

**Structure**:
```
DragAndDropTemplateCreatorTests/
└── DragAndDropTemplateCreatorTests.swift
```

**Recommended Tests**:
- ViewModel business logic
- Model data integrity
- History management
- Property updates
- HTML generation

### `DragAndDropTemplateCreatorUITests/`

**Purpose**: UI and integration tests for user interactions.

**Structure**:
```
DragAndDropTemplateCreatorUITests/
├── DragAndDropTemplateCreatorUITests.swift
└── DragAndDropTemplateCreatorUITestsLaunchTests.swift
```

**Recommended Tests**:
- Drag and drop functionality
- Component selection
- Property editing workflows
- Preview mode switching
- Export functionality

---

## 🎨 Assets Directory

### `Assets.xcassets/`

**Purpose**: Application visual assets and resources.

**Contents**:
- **AppIcon.appiconset/** - Application icons for different sizes
- **AccentColor.colorset/** - App-wide accent color
- **Contents.json** - Asset catalog metadata

---

## 🔄 Data Flow Architecture

### MVVM Data Flow

```
┌─────────────┐    ┌──────────────┐    ┌─────────────┐
│    Views    │ ←→ │  ViewModels  │ ←→ │   Models    │
└─────────────┘    └──────────────┘    └─────────────┘
      ↑                     ↑                   ↑
   UI Events          Business Logic        Data State
  User Input          State Management     Persistence
```

### Component Interaction Flow

```
User Interaction (View)
         ↓
ViewModel (Business Logic)
         ↓
Model Update (Data)
         ↓
Published Property Change
         ↓
View Update (UI Refresh)
```

---

## 🎯 Key Design Patterns

### 1. **MVVM (Model-View-ViewModel)**
- **Separation of Concerns**: Clear responsibility boundaries
- **Testability**: Business logic isolated in ViewModels
- **Reactive Programming**: Combine framework for data binding

### 2. **Dependency Injection**
- **Constructor Injection**: ViewModels injected via initializers
- **Single Source of Truth**: EditorViewModel as primary state manager
- **Loose Coupling**: Easy to swap implementations

### 3. **Command Pattern**
- **Undo/Redo**: Command-based history management
- **State Snapshots**: Immutable state capture
- **Action Tracking**: User action history

### 4. **Observer Pattern**
- **@Published Properties**: Automatic UI updates
- **Combine Subscriptions**: Reactive data flow
- **State Synchronization**: Cross-component updates

---

## 🚀 Development Guidelines

### Adding New Components

1. **Model**: Add component type to `ComponentType` enum
2. **Properties**: Extend `ComponentProperties` with new properties
3. **ViewModel**: Add business logic if needed
4. **View**: Create component view in `ComponentViews.swift`
5. **Properties UI**: Add property panel in `PropertiesView.swift`

### Adding New Features

1. **Models**: Define data structures
2. **ViewModels**: Implement business logic
3. **Views**: Create UI components
4. **Integration**: Wire up in `ContentView.swift`
5. **Tests**: Add unit and UI tests

### Code Organization Principles

- **Single Responsibility**: Each file has one clear purpose
- **Dependency Direction**: Views depend on ViewModels, ViewModels depend on Models
- **No Business Logic in Views**: All logic in ViewModels
- **Immutable Models**: Data structures are value types when possible

---

## 🔧 Build Configuration

### Xcode Project Structure
- **Minimum iOS Version**: 18.5
- **Swift Version**: 5.0
- **Framework**: SwiftUI
- **Architecture**: MVVM

### External Dependencies
- **SwiftUI**: UI framework
- **Combine**: Reactive programming
- **Foundation**: Core functionality

---

This project structure promotes maintainability, testability, and scalability while following iOS development best practices and design patterns.