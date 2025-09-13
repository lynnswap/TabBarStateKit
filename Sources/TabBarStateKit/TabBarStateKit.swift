// The Swift Programming Language
// https://docs.swift.org/swift-book
import SwiftUI
import Combine

/// Represents the visual size state of the TabBar.
public enum TabBarAppearance:String,CaseIterable {
    case regular
    case compact
}

/// ViewModel responsible for observing the TabBar platter view bounds.
@Observable
@MainActor
public final class TabBarStateModel {
    /// Latest bounds for the platter view.
    public init() {}
    public private(set) var platterBounds: CGRect? = nil {
        didSet {
            if oldValue != self.platterBounds {
                updateAppearance(oldValue: oldValue)
            }
        }
    }

    public private(set) var appearance: TabBarAppearance = .regular
    public private(set) var platterBottomPadding: CGFloat = 0

    /// Attach KVO observer to the tab bar controller.
    /// Calling this more than once is ignored.
    public func attach(to tbc: UITabBarController) {
        guard attachedTBC != tbc else { return }
        attachedTBC = tbc

        let platters = tbc.tabBar.subviews.filter {
            String(describing: type(of: $0)).contains("_UITabBarPlatterView")
        }

        if platterBounds == nil {
            let initialPlatter = platters
                .filter { !$0.isHidden }
                .max(by: { $0.bounds.width < $1.bounds.width })
            platterBounds = initialPlatter?.bounds
            if let initialPlatter{
                recomputePlatterBottomPadding(using: initialPlatter)
            }
        }
        platters.forEach { platter in
            guard let content = platter.subviews.first(where: {
                String(describing: type(of: $0)).hasSuffix("ContentView")
            }) else {
                observe(view: platter, on: platter)
                return
            }
            observe(view: content, on: platter)
        }
    }
    public func detach(){
        cancellables.removeAll()
        attachedTBC = nil
    }

    // MARK: - Private

    private func observe(view target: UIView, on platter: UIView) {
        platter
            .publisher(for: \.isHidden, options: [.new])
            .filter { !$0 }
            .receive(on: DispatchQueue.main)
            .sink { [weak self, weak platter] _ in
                guard let self, let platter else { return }
                self.platterBounds = platter.bounds
                self.recomputePlatterBottomPadding(using: platter)
            }
            .store(in :&cancellables)
    }

    private func recomputePlatterBottomPadding(using platter: UIView) {
        guard let tabBar = attachedTBC?.tabBar else { return }
        tabBar.layoutIfNeeded()

        // TabBar 座標系に変換
        let frameInTabBar = platter.convert(platter.bounds, to: tabBar)
        let raw = tabBar.bounds.maxY - frameInTabBar.maxY
        let scale = UIScreen.main.scale
        let clamped = max(0, raw)
        platterBottomPadding = (clamped * scale).rounded() / scale
    }

    private func updateAppearance(oldValue: CGRect?) {
        guard let bounds = platterBounds else { return }
        guard let old = oldValue else {
            appearance = .regular
            return
        }
        guard old != .zero, bounds != old else { return }
        if bounds.width > old.width {
            appearance = .regular
        } else if bounds.width < old.width {
            appearance = .compact
        }
    }
    @ObservationIgnored private var cancellables = Set<AnyCancellable>()
    private weak var attachedTBC: UITabBarController?
}
