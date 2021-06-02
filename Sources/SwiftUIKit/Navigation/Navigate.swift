//
//  Navigate.swift
//  
//
//  Created by Zach Eriksen on 11/4/19.
//

import UIKit

/**
 An object to help with navigation.
 */
public class Navigate {
    /// Different types of Navigation Style
    public enum NavigationStyle {
        case push
        case modal
    }
    
    /// Different types of Toast Style
    public enum ToastStyle {
        case error
        case warning
        case success
        case info
        case debug
        case custom
        
        /// The color chosen for the Toast Style
        public var color: UIColor {
            switch self {
            case .error:
                return .systemRed
            case .warning:
                return .systemYellow
            case .success:
                return .systemGreen
            case .info:
                return .systemBlue
            case .debug:
                return .systemGray
            case .custom:
                return .clear
            }
        }
    }
    
    /// The navigation controller used to navigate
    private var navigationController: UINavigationController?
    /// The single view used to display toasts
    private var toast: UIView?
    /// The tap handler for when the user taps on the toast
    private var didTapToastHandler: ((UIView) -> Void)?
    
    /// The statically shared instance of Navigate
    public static var shared: Navigate = Navigate()
    
    /// Create a Navigate object to manage navigation
    /// - Parameter controller: An optional UINavigationController to handle navigation (Default: nil)
    public init(controller: UINavigationController? = nil) {
        configure(controller: controller)
    }
    
    // MARK: Configure NavigationController
    
    /// Configure the Navigate Singleton with the Root Navigation Controller
    @discardableResult
    public func configure(controller: UINavigationController?) -> Self {
        self.navigationController = controller
        
        return self
    }
    
    /// Set the visibleViewController's title
    /// - Parameters:
    ///     - title: The title of the currentViewController
    @discardableResult
    public func set(title: String) -> Self {
        navigationController?.visibleViewController?.title = title
        
        return self
    }
    
    /// Set the left barButton
    /// - Parameters:
    ///     - barButton: The UIBarButtonItem to be set
    ///     - animated: Should animate setting the left UIBarButtonItem (Default: true)
    @discardableResult
    public func setLeft(barButton: UIBarButtonItem?, animated: Bool = true) -> Self {
        navigationController?.visibleViewController?.navigationItem.setLeftBarButton(barButton, animated: animated)
        
        return self
    }
    
    /// Set the right barButton
    /// - Parameters:
    ///     - barButton: The UIBarButtonItem to be set
    ///     - animated: Should animate setting the right UIBarButtonItem (Default: true)
    @discardableResult
    public func setRight(barButton: UIBarButtonItem?, animated: Bool = true) -> Self {
        navigationController?.visibleViewController?.navigationItem.setRightBarButton(barButton, animated: animated)
        
        return self
    }
    
    /// Set the left barButtons
    /// - Parameters:
    ///     - barButton: The [UIBarButtonItem] to be set
    ///     - animated: Should animate setting the left [UIBarButtonItem] (Default: true)
    @discardableResult
    public func setLeft(barButtons: [UIBarButtonItem]?, animated: Bool = true) -> Self {
        navigationController?.visibleViewController?.navigationItem.setLeftBarButtonItems(barButtons, animated: animated)
        
        return self
    }
    
    /// Set the right barButtons
    /// - Parameters:
    ///     - barButton: The [UIBarButtonItem] to be set
    ///     - animated: Should animate setting the right [UIBarButtonItem] (Default: true)
    @discardableResult
    public func setRight(barButtons: [UIBarButtonItem]?, animated: Bool = true) -> Self {
        navigationController?.visibleViewController?.navigationItem.setRightBarButtonItems(barButtons, animated: animated)
        
        return self
    }
    
    // MARK: Navigation
    
    /// Go to a viewController by using the configured NavigationController
    /// - Parameters:
    ///     - viewController: UIViewController to navigate to
    ///     - style: Style of navigation (Default: nil)
    public func go(
        _ viewController: UIViewController,
        style: NavigationStyle,
        completion: (() -> Void)? = nil
    ) {
        
        guard let controller = navigationController else {
            log(level: .error("Navigate \(#function) Error! Issue trying to navigate to \(viewController). (Could not unwrap navigationController)", nil))
            return
        }
        
        switch style {
        case .push:
            controller.show(viewController, sender: self)
        case .modal:
            controller.present(viewController, animated: true, completion: completion)
        }
    }
    
    /// Go to a viewController by using another viewController
    /// - Parameters:
    ///     - from: The UIViewController that is handling the navigation
    ///     - viewController: UIViewController to navigate to
    ///     - style: Style of navigation (Default: nil)
    public func go(
        from: UIViewController,
        to: UIViewController,
        style: NavigationStyle,
        completion: (() -> Void)? = nil
    ) {
        
        
        switch style {
        case .push:
            from.show(to, sender: self)
        case .modal:
            from.present(to, animated: true, completion: completion)
        }
    }
    
    /// Navigate back and dismiss the visibleViewController
    /// - Parameters:
    ///     - toRoot: Should navigate back to the rootViewController (Default: false)
    public func back(toRoot: Bool = false) {
        guard let controller = navigationController else {
            log(level: .error("Navigate \(#function) Error! Issue trying to navigate back. (Could not unwrap navigationController)", nil))
            return
        }
        
        dismiss()
        
        if toRoot {
            controller.popToRootViewController(animated: true)
        }
        
        controller.popViewController(animated: true)
    }
    
    /// Dismiss the visibleViewController
    public func dismiss() {
        guard let controller = navigationController else {
            log(level: .error("Navigate \(#function) Error! Issue trying to dismiss presentingViewController. (Could not unwrap navigationController)", nil))
            return
        }
        
        if let presentingVC = controller.visibleViewController {
            presentingVC.dismiss(animated: true)
        }
    }
    
    // MARK: Alert
    
    /// Show an Alert
    /// - Parameters:
    ///     - title: Title of the UIAlertController
    ///     - message: Message of the UIAlertController
    ///     - withactions: Array of action objects to be added to the Alert (Default: [])
    ///     - secondsToPersist: Amount of seconds the Alert should show before dismissing itself
    ///     - content: A closure that is passed the UIAlertController before presenting it (Default: nil)
    public func alert(
        title: String,
        message: String,
        withActions actions: [UIAlertAction] = [],
        secondsToPersist: Double?,
        content: ((UIAlertController) -> Void)? = nil
    ) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        actions.forEach { alert.addAction($0) }
        
        content?(alert)
        
        if let timeToLive = secondsToPersist {
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + timeToLive) {
                if alert.isFirstResponder {
                    alert.dismiss(animated: true)
                }
            }
        }
        
        go(alert, style: .modal)
    }
    
    // MARK: ActionSheet
    
    /// Show an ActionSheet
    /// - Parameters:
    ///     - title: Title of the UIAlertController
    ///     - message: Message of the UIAlertController
    ///     - withactions: Array of action objects to be added to the ActionSheet (Default: [])
    ///     - content: A closure that is passed the UIAlertController before presenting it (Default: nil)
    public func actionSheet(
        title: String,
        message: String,
        withActions actions: [UIAlertAction] = [],
        content: ((UIAlertController) -> Void)? = nil
    ) {
        
        let actionSheet = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
        
        actions.forEach { actionSheet.addAction($0) }
        
        content?(actionSheet)
        
        go(actionSheet, style: .modal)
    }
    
    // MARK: Toasts & Messages
    
    /// Show a Toast Message
    /// - Parameters:
    ///     - style: The ToastStyle (Default: .custom)
    ///     - pinToTop: Should the Toast pin to the top or bottom (Default: true)
    ///     - secondsToPersist: Amount of seconds the Toast should show before dismissing itself (Default: nil)
    ///     - animationInDuration: The amount of seconds the Toast should fade in (Default: 0.5)
    ///     - animationOutDuration: The amount of seconds the Toast should fade out (Default: 0.5)
    ///     - padding: The amount of spacing around the Toast (Default: 8)
    ///     - tapHandler: What happens when the user taps on the Toast (Default: { $0.removeFromSuperview() })
    ///     - content: A trailing closure that accepts a view
    @available(iOS 11.0, *)
    public func toast(
        style: ToastStyle = .custom,
        pinToTop: Bool = true,
        secondsToPersist: Double? = nil,
        animationInDuration: Double = 0.5,
        animationOutDuration: Double = 0.5,
        padding: Float = 8,
        tapHandler: @escaping (UIView) -> Void = { $0.removeFromSuperview() },
        content: @escaping () -> UIView
    ) {
        
        // Don't allow more than one Toast to be present
        guard toast == nil else {
            return
        }
        didTapToastHandler = tapHandler
        
        switch style {
        case .custom:
            toast = content()
                .gesture { UITapGestureRecognizer(target: self, action: #selector(userTappedOnToast)) }
        default:
            toast = UIView(backgroundColor: .clear) {
                content()
                    .padding(8)
                    .configure {
                        $0.backgroundColor = style.color
                        $0.clipsToBounds = true
                    }
                    .layer(cornerRadius: 8)
                
            }
            .padding(padding)
            
            .gesture { UITapGestureRecognizer(target: self, action: #selector(userTappedOnToast)) }
        }
        
        toast?.translatesAutoresizingMaskIntoConstraints = false
        toast?.alpha = 0
        
        guard let controller = navigationController,
              let containerView = controller.visibleViewController?.view,
              let toast = toast else {
            destroyToast()
            log(level: .error("Navigate \(#function) Error! Issue trying to dismiss presentingViewController. (Could not unwrap navigationController)", nil))
            return
        }
        
        controller.visibleViewController?.view.addSubview(toast)
        controller.visibleViewController?.view.bringSubviewToFront(toast)
        
        let pinConstraint = pinToTop ? toast.topAnchor.constraint(equalTo: containerView.safeAreaLayoutGuide.topAnchor) : toast.bottomAnchor.constraint(equalTo: containerView.safeAreaLayoutGuide.bottomAnchor)
        
        NSLayoutConstraint.activate(
            [
                pinConstraint,
                toast.leadingAnchor.constraint(equalTo: containerView.safeAreaLayoutGuide.leadingAnchor),
                toast.trailingAnchor.constraint(equalTo: containerView.safeAreaLayoutGuide.trailingAnchor),
                toast.heightAnchor.constraint(greaterThanOrEqualToConstant: 60),
            ]
        )
        
        // Animation In
        DispatchQueue.main.async {
            toast.layoutIfNeeded()
            UIView.animate(withDuration: animationInDuration) {
                toast.alpha = 1
            }
        }
        
        // Animation Out
        if let timeToLive = secondsToPersist {
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + timeToLive) {
                UIView.animate(withDuration: animationOutDuration, animations: {
                    toast.alpha = 0
                    toast.layoutIfNeeded()
                }) { didComplete in
                    if didComplete {
                        self.destroyToast()
                    }
                }
            }
        }
    }
    
    /// Destory the toast
    public func destroyToast() {
        toast?.removeFromSuperview()
        toast = nil
        didTapToastHandler = nil
    }
    
    /// private function to handle when the user taps on the toast
    @objc private func userTappedOnToast() {
        guard let toast = toast else {
            log(level: .error("Toast \(#function) Error! Issue trying to dismiss Toast. (Could not unwrap Toast)", nil))
            return
        }
        didTapToastHandler?(toast)
        destroyToast()
    }
}
