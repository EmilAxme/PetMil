//
//  UIView+Helpers.swift
//  PetMil
//
//  Created by Emil on 04.03.2026.
//

import UIKit

extension UIView {
    //MARK: - Functions
    func addToView(_ subView: UIView) {
        addSubview(subView)
        subView.translatesAutoresizingMaskIntoConstraints = false
    }
}
