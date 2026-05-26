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
    func showLoadingIndicator(_ indicator: UIActivityIndicatorView) {
        searchTextField.rightView = indicator
        searchTextField.rightViewMode = .always
        indicator.startAnimating()
    }

    func hideLoadingIndicator(_ indicator: UIActivityIndicatorView) {
        indicator.stopAnimating()
        searchTextField.rightView = nil
        searchTextField.rightViewMode = .never
    }
}
