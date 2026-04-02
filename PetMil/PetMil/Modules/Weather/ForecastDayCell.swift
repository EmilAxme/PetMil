//
//  ForecastDayCell.swift
//  PetMil
//
//  Created by Emil on 01.04.2026.
//

import UIKit

final class ForecastDayCell: UITableViewCell {
    
    static let reuseIdentifier = "ForecastDayCell"

    private lazy var dayLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .semibold)
        label.textColor = .label
        return label
    }()
    
    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .regular)
        label.textColor = .secondaryLabel
        return label
    }()
    
    private lazy var temperatureLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .bold)
        label.textColor = .label
        label.textAlignment = .right
        return label
    }()
    
    private lazy var leftStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [dayLabel, descriptionLabel])
        stack.axis = .vertical
        stack.spacing = 4
        stack.alignment = .leading
        return stack
    }()
    
    private lazy var containerStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [leftStackView, temperatureLabel])
        stack.axis = .horizontal
        stack.alignment = .center
        stack.spacing = 12
        return stack
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with model: WeatherModels.ForecastRow) {
        dayLabel.text = model.dayText
        descriptionLabel.text = model.descriptionText
        temperatureLabel.text = model.temperatureText
    }
}

private extension ForecastDayCell {
    func setupView() {
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear
    }
    
    func setupLayout() {
        contentView.addSubview(containerStackView)
        containerStackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            containerStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            containerStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            containerStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            containerStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
            
            temperatureLabel.widthAnchor.constraint(equalToConstant: 60)
        ])
    }
}
