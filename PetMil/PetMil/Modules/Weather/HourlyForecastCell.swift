//
//  HourlyForecastCell.swift
//  PetMil
//
//  Created by Emil on 29.05.2026.
//

import UIKit

final class HourlyForecastCell: UICollectionViewCell {

    static let reuseIdentifier = "HourlyForecastCell"

    lazy var iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private lazy var timeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .semibold)
        label.textColor = .label
        label.textAlignment = .center
        return label
    }()

    private lazy var temperatureLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .bold)
        label.textColor = .label
        label.textAlignment = .center
        return label
    }()

    private lazy var precipitationLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .semibold)
        label.textColor = .systemBlue
        label.textAlignment = .center
        return label
    }()

    private lazy var stackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [
            timeLabel,
            iconImageView,
            precipitationLabel,
            temperatureLabel
        ])
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 4
        return stack
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with row: WeatherModels.HourlyRow) {
        timeLabel.text = row.timeText
        temperatureLabel.text = row.temperatureText

        if let precipitation = row.precipitationText {
            precipitationLabel.text = precipitation
            precipitationLabel.isHidden = false
        } else {
            precipitationLabel.text = nil
            precipitationLabel.isHidden = true
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        iconImageView.image = nil
        timeLabel.text = nil
        temperatureLabel.text = nil
        precipitationLabel.text = nil
        precipitationLabel.isHidden = true
    }
}

private extension HourlyForecastCell {
    func setupLayout() {
        contentView.addToView(stackView)

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 4),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -4),

            iconImageView.widthAnchor.constraint(equalToConstant: 32),
            iconImageView.heightAnchor.constraint(equalToConstant: 32)
        ])
    }
}
