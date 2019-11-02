//
//  Divider.swift
//  
//
//  Created by Zach Eriksen on 11/2/19.
//

import UIKit

@available(iOS 9.0, *)
public class Divider: UIView {
    public init(backgroundColor: UIColor? = .black,
                axis: NSLayoutConstraint.Axis = .horizontal) {
        super.init(frame: .zero)
        
        self.backgroundColor = backgroundColor
        
        if axis == .horizontal {
            frame(height: 1)
        } else {
            frame(width: 1)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

