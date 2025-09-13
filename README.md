# TabBarStateKit

TabBarStateKit is a Swift package that observes the bounds of the tab bar to determine whether it is in a `regular` or `compact` state. It uses Combine and SwiftUI APIs.

## Usage

Attach the model to your `UITabBarController` instance and observe the `appearance` property.

```swift
let model = TabBarStateModel()
model.attach(to: tabBarController)
```

## _setTabBarMinimized (Experimental / Private API)

This package provides an extension to toggle the internal `_minimized` state of `UITabBar`.

- Summary: Uses the Objective‑C runtime to call `setMinimized:animated:` or `setMinimized:` on the tab bar’s internal `_visualProvider` to minimize/restore the tab bar.
- Signature: `@discardableResult public func _setTabBarMinimized(_ newValue: Bool, animated: Bool = false) -> Bool`
- Return: `true` on success, `false` on failure.
- Source: See `Sources/TabBarStateKit/UITabBar+Extension.swift`.

Examples:

```swift
// Minimize (collapse)
tabBarController.tabBar._setTabBarMinimized(true, animated: true)

// Restore to regular size
tabBarController.tabBar._setTabBarMinimized(false, animated: true)
```

Caveats:

- Uses private API.
- Depends on iOS internals and may break with OS updates. Always check the return value.
- Intended for main-thread usage (it triggers `setNeedsLayout` / `layoutIfNeeded`).
- There is no public API to directly toggle the tab bar’s minimized state; treat this as a best-effort helper.

## License

This project is released under the MIT License. See [LICENSE](LICENSE) for details.
