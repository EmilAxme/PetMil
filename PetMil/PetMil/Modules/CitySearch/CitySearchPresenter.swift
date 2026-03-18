//
//  CitySearchPresenter.swift
//  PetMil
//
//  Created by Emil on 11.03.2026.
//

import Foundation

protocol CitySearchPresenterProtocol: AnyObject {
    func viewDidLoad()
}

final class CitySearchPresenter {
    weak var view: CitySearchViewProtocol?
}

extension CitySearchPresenter: CitySearchPresenterProtocol {
    func viewDidLoad() {
        view?.displayTitle("Search City")
    }
}
