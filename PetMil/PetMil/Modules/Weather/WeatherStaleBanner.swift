//
//  WeatherStaleBanner.swift
//  PetMil
//
//  Created by Emil on 29.05.2026.
//

import UIKit

final class WeatherStaleBanner: UIView {

    private lazy var iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "wifi.slash")
        imageView.tintColor = .label
        imageView.contentMode = .scaleAspectFit
        imageView.preferredSymbolConfiguration = UIImage.SymbolConfiguration(pointSize: 13, weight: .semibold)
        return imageView
    }()

    private lazy var label: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .medium)
        label.textColor = .label
        label.numberOfLines = 1
        return label
    }()

    private lazy var stackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [iconImageView, label])
        stack.axis = .horizontal
        stack.alignment = .center
        stack.spacing = 6
        return stack
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupAppearance()
        setupLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(fetchedAt: Date) {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.dateFormat = "HH:mm"
        let time = formatter.string(from: fetchedAt)
        label.text = "Нет сети · обновлено в \(time)"
    }
}

private extension WeatherStaleBanner {
    func setupAppearance() {
        backgroundColor = UIColor.systemBackground.withAlphaComponent(0.85)
        layer.cornerRadius = 14
        layer.cornerCurve = .continuous
    }

    func setupLayout() {
        addToView(stackView)

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 14),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -14),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8),

            iconImageView.widthAnchor.constraint(equalToConstant: 14),
            iconImageView.heightAnchor.constraint(equalToConstant: 14)
        ])
    }
}
