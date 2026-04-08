//
//  DayDetailViewController.swift
//  PetMil
//
//  Created by Emil on 07.04.2026.
//

import UIKit

protocol DayDetailsViewProtocol: AnyObject {
    func displayDayDetails(viewModel: DayDetailsModels.ViewModel)
}

final class DayDetailsViewController: UIViewController {
    
    var presenter: DayDetailsPresenterProtocol?
    
    private lazy var dayLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 30, weight: .bold)
        label.textColor = .label
        label.textAlignment = .center
        return label
    }()
    
    private lazy var temperatureLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 72, weight: .bold)
        label.textColor = .label
        label.textAlignment = .center
        return label
    }()
    
    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 22, weight: .medium)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var detailsContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .secondarySystemBackground
        view.layer.cornerRadius = 24
        view.layer.cornerCurve = .continuous
        return view
    }()
    
    private lazy var feelsLikeRow = makeDetailRow(title: "Feels like")
    private lazy var humidityRow = makeDetailRow(title: "Humidity")
    private lazy var windRow = makeDetailRow(title: "Wind")
    private lazy var pressureRow = makeDetailRow(title: "Pressure")
    
    private lazy var detailsStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [
            feelsLikeRow,
            makeSeparatorView(),
            humidityRow,
            makeSeparatorView(),
            windRow,
            makeSeparatorView(),
            pressureRow
        ])
        stack.axis = .vertical
        stack.spacing = 0
        return stack
    }()
    
    private lazy var contentStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [
            dayLabel,
            temperatureLabel,
            descriptionLabel,
            detailsContainerView
        ])
        stack.axis = .vertical
        stack.spacing = 24
        return stack
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupAppearance()
        setupLayout()
        presenter?.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
}

private extension DayDetailsViewController {
    func setupAppearance() {
        view.backgroundColor = .systemBackground
        title = "Details"
    }
    
    func setupLayout() {
        view.addToView(contentStackView)
        detailsContainerView.addToView(detailsStackView)
        
        NSLayoutConstraint.activate([
            contentStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            contentStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            contentStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            detailsStackView.topAnchor.constraint(equalTo: detailsContainerView.topAnchor, constant: 8),
            detailsStackView.leadingAnchor.constraint(equalTo: detailsContainerView.leadingAnchor, constant: 16),
            detailsStackView.trailingAnchor.constraint(equalTo: detailsContainerView.trailingAnchor, constant: -16),
            detailsStackView.bottomAnchor.constraint(equalTo: detailsContainerView.bottomAnchor, constant: -8)
        ])
    }
    
    func makeDetailRow(title: String) -> DetailRowView {
        DetailRowView(title: title)
    }
    
    func makeSeparatorView() -> UIView {
        let view = UIView()
        view.backgroundColor = .separator
        NSLayoutConstraint.activate([
            view.heightAnchor.constraint(equalToConstant: 1)
        ])
        return view
    }
}

extension DayDetailsViewController: DayDetailsViewProtocol {
    func displayDayDetails(viewModel: DayDetailsModels.ViewModel) {
        dayLabel.text = viewModel.dayText
        temperatureLabel.text = viewModel.temperatureText
        descriptionLabel.text = viewModel.descriptionText
        
        feelsLikeRow.configure(value: viewModel.feelsLikeText)
        humidityRow.configure(value: viewModel.humidityText)
        windRow.configure(value: viewModel.windText)
        pressureRow.configure(value: viewModel.pressureText)
    }
}
