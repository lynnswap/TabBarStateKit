# TabBarStateKit

TabBarStateKit is a Swift package that observes the bounds of the tab bar to determine whether it is in a `regular` or `compact` state. It uses Combine and SwiftUI APIs.

## Usage

Attach the model to your `UITabBarController` instance and observe the `appearance` property.

```swift
let model = TabBarStateModel()
model.attach(to: tabBarController)
```

## License

This project is released under the MIT License. See [LICENSE](LICENSE) for details.
