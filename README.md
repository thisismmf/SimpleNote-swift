# SimpleNote (Scaffold)

A compile-ready SwiftUI + MVVM scaffold for a notes app. No real business logic yet.

## Toolchain
- **Xcode 15+**, **iOS 17+**, **Swift 5.9+**
- **XcodeGen** installed: `brew install xcodegen`

## Build & Run
```bash
cd SimpleNote
xcodegen generate   # produces SimpleNote.xcodeproj
open SimpleNote.xcodeproj
# In Xcode: select the "SimpleNote" scheme → run on iOS 17+ simulator.
```

## Structure
See the repository tree. Feature-first folders, DI container, design system, and networking stubs.

## Add a new screen
1. Create `Features/<Feature>/<Screen>/Screen.swift`, `ViewModel.swift`, `State.swift` (optional).
2. Add a route in `Navigation/NavRoutes.swift` and wire it in `App/AppRouter.swift`.
3. Inject dependencies via `AppEnvironment` / `DI.Container`.

## Add an API
1. Create DTO & endpoint in `Core/Network/APIRoutes.swift`.
2. Add method to a Service/Repository protocol (e.g., `NotesRepository`).
3. Implement in a fake or real repository. Use `HTTPClient` for network calls. // TODO

## Theming
Design tokens live under `Core/DesignSystem/Theme` and are used by reusable components.
