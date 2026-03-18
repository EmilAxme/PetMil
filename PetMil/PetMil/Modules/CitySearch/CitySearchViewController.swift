//
//  CitySearchViewController.swift
//  PetMil
//
//  Created by Emil on 11.03.2026.
//

import UIKit

protocol CitySearchViewProtocol: AnyObject {
    func displayTitle(_ title: String)
}

final class CitySearchViewController: UIViewController {
    
    var presenter: CitySearchPresenterProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupAppearance()
        presenter?.viewDidLoad()
    }
    
    private func setupAppearance() {
        view.backgroundColor = .systemBackground
    }
}

extension CitySearchViewController: CitySearchViewProtocol {
    
    func displayTitle(_ title: String) {
        self.title = title
    }
}
