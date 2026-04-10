//
//  WeatherHeaderView.swift
//  PetMil
//
//  Created by Emil on 01.04.2026.
//

import UIKit

final class WeatherHeaderView: UIView {
    private lazy var cityLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 24, weight: .semibold)
        label.textColor = .label
        label.textAlignment = .center
        return label
    }()
    
    private lazy var temperatureLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 64, weight: .bold)
        label.textColor = .label
        label.textAlignment = .center
        return label
    }()
    
    private lazy var summaryLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .medium)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        return label
    }()
    
    lazy var iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private lazy var stackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [
            cityLabel,
            iconImageView,
            temperatureLabel,
            summaryLabel
        ])
        stack.axis = .vertical
        stack.alignment = .fill
        stack.spacing = 8
        return stack
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(city: String, temperature: String, summary: String) {
        cityLabel.text = city
        temperatureLabel.text = temperature
        summaryLabel.text = summary
    }
}

private extension WeatherHeaderView {
    func setupView() {
        backgroundColor = .clear
    }
    
    func setupLayout() {
        addToView(stackView)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor, constant: 24),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -24),
            
            iconImageView.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
}
