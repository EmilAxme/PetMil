//
//  ForecastDayCell.swift
//  PetMil
//
//  Created by Emil on 01.04.2026.
//

import UIKit

final class ForecastDayCell: UITableViewCell {
    
    static let reuseIdentifier = "ForecastDayCell"
    
    private lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .tertiarySystemBackground
        view.layer.cornerRadius = 18
        view.layer.cornerCurve = .continuous
        return view
    }()
    
    lazy var iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private lazy var dayLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .semibold)
        label.textColor = .label
        return label
    }()
    
    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .regular)
        label.textColor = .secondaryLabel
        return label
    }()
    
    private lazy var temperatureContainerView: UIView = {
        let view = UIView()
        return view
    }()
    
    private lazy var temperatureLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .right
        label.numberOfLines = 1
        label.setContentCompressionResistancePriority(.required, for: .horizontal)
        label.setContentHuggingPriority(.required, for: .horizontal)
        return label
    }()
    
    private lazy var textStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [dayLabel, descriptionLabel])
        stack.axis = .vertical
        stack.spacing = 6
        stack.alignment = .leading
        return stack
    }()

    private lazy var leftStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [iconImageView, textStackView])
        stack.axis = .horizontal
        stack.spacing = 10
        stack.alignment = .center
        return stack
    }()
    
    private lazy var contentRowStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [leftStackView, temperatureContainerView])
        stack.axis = .horizontal
        stack.alignment = .center
        stack.spacing = 12
        stack.distribution = .equalSpacing
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
    
    func configure(with model: WeatherModels.ForecastRow) {
        dayLabel.text = model.dayText
        descriptionLabel.text = model.descriptionText
        temperatureLabel.attributedText = makeTemperatureText(
            maxText: model.maxTemperatureText,
            minText: model.minTemperatureText
        )
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        
        let animator = UIViewPropertyAnimator(
            duration: highlighted ? 0.25 : 0.3,
            dampingRatio: 0.9
        ) {
            self.containerView.transform = highlighted
                ? CGAffineTransform(scaleX: 0.97, y: 0.97)
                : .identity
            
            self.containerView.alpha = highlighted ? 0.9 : 1
        }
        
        animator.startAnimation()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        iconImageView.image = nil
        dayLabel.text = nil
        descriptionLabel.text = nil
        temperatureLabel.attributedText = nil
    }
}

private extension ForecastDayCell {
    func setupAppearance() {
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        selectionStyle = .none
    }
    
    func setupLayout() {
        contentView.addToView(containerView)
        containerView.addToView(contentRowStackView)
        temperatureContainerView.addToView(temperatureLabel)

        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6),
            
            contentRowStackView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 18),
            contentRowStackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            contentRowStackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            contentRowStackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -18),
            
            temperatureLabel.topAnchor.constraint(equalTo: temperatureContainerView.topAnchor),
            temperatureLabel.leadingAnchor.constraint(equalTo: temperatureContainerView.leadingAnchor),
            temperatureLabel.trailingAnchor.constraint(equalTo: temperatureContainerView.trailingAnchor, constant: -6),
            temperatureLabel.bottomAnchor.constraint(equalTo: temperatureContainerView.bottomAnchor),
            
            temperatureContainerView.widthAnchor.constraint(greaterThanOrEqualToConstant: 72),
            
            iconImageView.widthAnchor.constraint(equalToConstant: 28),
            iconImageView.heightAnchor.constraint(equalToConstant: 28),
        ])
    }
    
    func makeTemperatureText(maxText: String, minText: String) -> NSAttributedString {
        let result = NSMutableAttributedString(
            string: maxText,
            attributes: [
                .font: UIFont.systemFont(ofSize: 22, weight: .bold),
                .foregroundColor: UIColor.label
            ]
        )
        
        let minPart = NSAttributedString(
            string: minText,
            attributes: [
                .font: UIFont.systemFont(ofSize: 14, weight: .medium),
                .foregroundColor: UIColor.secondaryLabel,
                .baselineOffset: -1,
                .kern: -1.5
            ]
        )
        
        result.append(minPart)
        return result
    }
}
