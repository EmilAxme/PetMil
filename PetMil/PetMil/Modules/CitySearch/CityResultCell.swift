//
//  CityResultCell.swift
//  PetMil
//
//  Created by Emil on 08.04.2026.
//

import UIKit

final class CityResultCell: UITableViewCell {

    static let reuseIdentifier = "CityResultCell"

    private lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .tertiarySystemBackground
        view.layer.cornerRadius = 18
        view.layer.cornerCurve = .continuous
        return view
    }()

    private lazy var cityLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 19, weight: .semibold)
        label.textColor = .label
        return label
    }()

    private lazy var countryLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .regular)
        label.textColor = .secondaryLabel
        return label
    }()

    private lazy var locationBadge: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "location.fill")
        imageView.tintColor = .systemBlue
        imageView.contentMode = .scaleAspectFit
        imageView.preferredSymbolConfiguration = UIImage.SymbolConfiguration(pointSize: 16, weight: .semibold)
        imageView.isHidden = true
        return imageView
    }()

    private lazy var labelsStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [cityLabel, countryLabel])
        stack.axis = .vertical
        stack.spacing = 4
        stack.alignment = .leading
        return stack
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupAppearance()
        setupLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with city: CitySearchModels.City) {
        cityLabel.text = city.name
        if let state = city.state, !state.isEmpty {
            countryLabel.text = "\(state), \(city.country)"
        } else {
            countryLabel.text = city.country
        }
        countryLabel.isHidden = (countryLabel.text ?? "").isEmpty
        locationBadge.isHidden = true
    }

    func configure(with row: CitySearchModels.SavedRow) {
        cityLabel.text = row.name
        countryLabel.text = row.countryOrLocation
        countryLabel.isHidden = row.countryOrLocation.isEmpty
        locationBadge.isHidden = !row.isCurrentLocation
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        
        let animations = {
            self.containerView.transform = highlighted
                ? CGAffineTransform(scaleX: 0.97, y: 0.97)
                : .identity
            self.containerView.alpha = highlighted ? 0.88 : 1
        }
        
        if animated {
            UIView.animate(
                withDuration: highlighted ? 0.22 : 0.28,
                delay: 0,
                options: [.curveEaseOut, .allowUserInteraction, .beginFromCurrentState],
                animations: animations
            )
        } else {
            animations()
        }
    }
}

private extension CityResultCell {
    func setupAppearance() {
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        selectionStyle = .none
    }
    
    func setupLayout() {
        contentView.addToView(containerView)
        containerView.addToView(labelsStackView)
        containerView.addToView(locationBadge)

        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6),

            labelsStackView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
            labelsStackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            labelsStackView.trailingAnchor.constraint(lessThanOrEqualTo: locationBadge.leadingAnchor, constant: -12),
            labelsStackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -16),

            locationBadge.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            locationBadge.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            locationBadge.widthAnchor.constraint(equalToConstant: 22),
            locationBadge.heightAnchor.constraint(equalToConstant: 22)
        ])
    }
}
