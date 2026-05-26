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

extension UISearchBar {
    func setRightView(_ view: UIView) {
        if let searchField = value(forKey: "searchField") as? UITextField {
            searchField.rightView = view
            searchField.rightViewMode = .always
        }
    }
}
