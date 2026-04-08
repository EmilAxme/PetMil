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
    
    private lazy var temperatureLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.textColor = .label
        label.textAlignment = .right
        return label
    }()
    
    private lazy var leftStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [dayLabel, descriptionLabel])
        stack.axis = .vertical
        stack.spacing = 6
        stack.alignment = .leading
        return stack
    }()
    
    private lazy var contentRowStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [leftStackView, temperatureLabel])
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
        temperatureLabel.text = model.temperatureText
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
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6),
            
            contentRowStackView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 18),
            contentRowStackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            contentRowStackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            contentRowStackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -18),
            
            temperatureLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 44)
        ])
    }
}
