//
//  RootViewController.swift
//  Rick&Morty
//
//  Created by Konrad Cureau on 04/05/2022.
//

import UIKit

final class RootNavigator: UIViewController {
    private var rootViewController: UIViewController?
    private let factory: ViewControllerFactory

    init(factory: ViewControllerFactory) {
        self.factory = factory

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setRootViewController(_ newValue: UIViewController?,
                                       isAnimated: Bool,
                                       completion: ((Bool) -> Void)? = nil) {
        let oldValue = rootViewController

        rootViewController = newValue

        _updateRootViewController(oldValue: oldValue,
                                  newValue: newValue,
                                  isAnimated: isAnimated,
                                  completion: completion)
    }

    private func _addChild(viewController: UIViewController) {
        self.addChild(viewController)
        viewController.view.frame = self.view.bounds
        self.view.addSubview(viewController.view)
        viewController.didMove(toParent: self)
    }

    private func _removeChild(viewController: UIViewController) {
        viewController.willMove(toParent: nil)
        viewController.view.removeFromSuperview()
        viewController.removeFromParent()
    }

    private func _updateRootViewController(oldValue: UIViewController?,
                                           newValue: UIViewController?,
                                           isAnimated: Bool,
                                           completion: ((Bool) -> Void)?) {
        guard isViewLoaded else {
            completion?(false)
            return
        }

        switch (oldValue, newValue) {
        case (.none, .none): // screw you
            completion?(false)

        case (.some(let oldValue), .some(let newValue)):
            guard oldValue != newValue else { // aborting due to nothign being replaced
                completion?(false)
                return
            }

            guard newValue.parent != self else { // already our child
                completion?(false)
                return
            }

            guard let oldViewSnapshotView = oldValue.topMostViewController.view.snapshotView(afterScreenUpdates: false) else {
                completion?(false)
                return
            }

            let work: () -> Void = {
                self._addChild(viewController: newValue)
                self.view.addSubview(oldViewSnapshotView)
                self._removeChild(viewController: oldValue)

                let animationBlock = {
                    oldViewSnapshotView.alpha = 0
                }

                let completionBlock: (Bool) -> Void = {
                    oldViewSnapshotView.removeFromSuperview()
                    completion?($0)
                }

                if isAnimated {
                    UIView.animate(withDuration: 0.2,
                                   animations: animationBlock,
                                   completion: completionBlock)
                } else {
                    UIView.performWithoutAnimation(animationBlock)
                    completionBlock(true)
                }
            }

            if let presentedViewController = oldValue.presentedViewController {
                presentedViewController.dismiss(animated: false, completion: work)
            } else {
                work()
            }

        case (.none, .some(let newValue)):
            guard newValue.parent != self else { // already our child
                completion?(false)
                return
            }

            self._addChild(viewController: newValue)
            completion?(true)

        case (.some(let oldValue), .none):
            _removeChild(viewController: oldValue)
            completion?(true)
        }
    }
}

extension RootNavigator: Navigator {
    enum Destination {
        case home
    }

    func navigate(to destination: Destination) {
        switch destination {
        case .home:
            setRootViewController(factory.tabBarController(), isAnimated: true)
        }
    }
}


extension UIViewController {
    var topMostViewController: UIViewController {
        guard let presentedViewController = presentedViewController else {
            return self
        }

        return presentedViewController.topMostViewController
    }
}

