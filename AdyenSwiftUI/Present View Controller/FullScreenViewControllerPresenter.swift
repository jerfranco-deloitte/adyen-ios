//
// Copyright (c) 2023 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import SwiftUI

#if canImport(SwiftUI) && canImport(Combine)
    @available(iOS 13.0, *)
    public extension View {

        /// Present a `ViewController` modally.
        ///
        /// - Parameter viewController: A `Binding<UIViewController?>` instance,
        /// set the `wrappedValue` to a view controller instance to dismiss the previous view controller if it had previously a value
        /// and presents the new one,
        /// set it to `nil` to dismiss the previous view Controller if any.
        func present(viewController: Binding<UIViewController?>) -> some View {
            modifier(FullScreenViewControllerPresenter(viewController: viewController))
        }
    }

    @available(iOS 13.0, *)
    internal struct FullScreenViewControllerPresenter: ViewModifier {

        @Binding internal var viewController: UIViewController?

        internal func body(content: Content) -> some View {
            ZStack {
                FullScreenView(viewController: $viewController)
                content
            }
        }
    }

    @available(iOS 13.0, *)
    internal struct FullScreenView: UIViewControllerRepresentable {

        @Binding internal var viewController: UIViewController?

        internal init(viewController: Binding<UIViewController?>) {
            self._viewController = viewController
        }

        internal final class Coordinator {

            fileprivate var currentlyPresentedViewController: UIViewController?
        }

        internal func makeUIViewController(context: UIViewControllerRepresentableContext<FullScreenView>) -> UIViewController {
            StickyViewController()
        }

        internal func makeCoordinator() -> Coordinator {
            Coordinator()
        }

        internal func updateUIViewController(_ uiViewController: UIViewController, context: UIViewControllerRepresentableContext<FullScreenView>) {
            if let viewController, viewController !== context.coordinator.currentlyPresentedViewController {
                dismissIfNeededThenPresent(viewController: viewController, presenter: uiViewController, context: context)
            } else if context.coordinator.currentlyPresentedViewController != nil, viewController == nil {
                dismiss(presenter: uiViewController, context: context, completion: nil)
            }
        }

        private func dismissIfNeededThenPresent(viewController: UIViewController,
                                                presenter: UIViewController,
                                                context: UIViewControllerRepresentableContext<FullScreenView>) {
            if context.coordinator.currentlyPresentedViewController != nil {
                dismiss(presenter: presenter, context: context) {
                    Self.present(viewController: viewController, presenter: presenter, context: context)
                }
            } else {
                Self.present(viewController: viewController, presenter: presenter, context: context)
            }
        }

        private static func present(viewController: UIViewController,
                                    presenter: UIViewController,
                                    context: UIViewControllerRepresentableContext<FullScreenView>) {
            guard !viewController.isBeingPresented, !viewController.isBeingDismissed else { return }
            presenter.present(viewController, animated: true) {
                context.coordinator.currentlyPresentedViewController = viewController
            }
        }

        private func dismiss(presenter: UIViewController,
                             context: UIViewControllerRepresentableContext<FullScreenView>,
                             completion: (() -> Void)?) {
            guard let viewController = context.coordinator.currentlyPresentedViewController else { return }
            guard !viewController.isBeingPresented, !viewController.isBeingDismissed else { return }

            presenter.dismiss(animated: true) {
                context.coordinator.currentlyPresentedViewController = nil
                completion?()
            }
        }
    }

    /// This view controller only dismisses the view controller that is presented by this view controller.
    /// It resists being dismissed if the `dismiss` method is called on the view controller itself with no presented controllers.
    /// It could still be dismissed by a parent view controller
    private class StickyViewController: UIViewController, UIViewControllerTransitioningDelegate {

        init() {
            super.init(nibName: nil, bundle: Bundle(for: StickyViewController.self))
        }

        @available(*, unavailable)
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
            if presentedViewController != nil {
                super.dismiss(animated: flag, completion: completion)
            } else {
                completion?()
            }
        }

    }

#endif
