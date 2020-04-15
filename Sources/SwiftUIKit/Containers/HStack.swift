//
//  HStack.swift
//  SwiftUIKit
//
//  Created by Zach Eriksen on 10/29/19.
//

import UIKit

/// Horizontal StackView
public class HStack: UIView {
    /// The views that the HStack contains
    public var views: [UIView] = []
    
    /// Create a HStack
    /// - Parameters:
    ///     - withSpacing: The amount of spacing between each child view
    ///     - padding: The amount of space between this view and its parent view
    ///     - alignment: The layout of arranged views perpendicular to the stack view’s axis (source: UIStackView.Alignment)
    ///     - distribution: The layout that defines the size and position of the arranged views along the stack view’s axis (source: UIStackView.Distribution)
    ///     - closure: A trailing closure that accepts an array of views
    public init(withSpacing spacing: Float = 0,
                padding: Float = 0,
                alignment: UIStackView.Alignment = .fill,
                distribution: UIStackView.Distribution = .fill,
                _ closure: () -> [UIView]) {
        views = closure()
        super.init(frame: .zero)
        
        hstack(withSpacing: spacing,
               padding: padding,
               alignment: alignment,
               distribution: distribution,
               closure)
    }
    
    /// Create a HStack that accepts an array of UIView?
    /// - Parameters:
    ///     - withSpacing: The amount of spacing between each child view
    ///     - padding: The amount of space between this view and its parent view
    ///     - alignment: The layout of arranged views perpendicular to the stack view’s axis (source: UIStackView.Alignment)
    ///     - distribution: The layout that defines the size and position of the arranged views along the stack view’s axis (source: UIStackView.Distribution)
    ///     - closure: A trailing closure that accepts an array of optional views
    public init(withSpacing spacing: Float = 0,
                padding: Float = 0,
                alignment: UIStackView.Alignment = .fill,
                distribution: UIStackView.Distribution = .fill,
                _ closure: () -> [UIView?]) {
        views = closure()
            .compactMap { $0 }
        super.init(frame: .zero)
        
        hstack(withSpacing: spacing,
               padding: padding,
               alignment: alignment,
               distribution: distribution)
        { views }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
