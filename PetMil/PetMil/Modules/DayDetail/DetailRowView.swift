//
//  DetailRowView.swift
//  PetMil
//
//  Created by Emil on 07.04.2026.
//

import UIKit

final class DetailRowView: UIView {
    
    private let title: String
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .medium)
        label.textColor = .secondaryLabel
        label.text = title
        return label
    }()
    
    private lazy var valueLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .semibold)
        label.textColor = .label
        label.textAlignment = .right
        return label
    }()
    
    private lazy var stackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [titleLabel, valueLabel])
        stack.axis = .horizontal
        stack.alignment = .center
        stack.spacing = 12
        return stack
    }()
    
    init(title: String) {
        self.title = title
        super.init(frame: .zero)
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(value: String) {
        valueLabel.text = value
    }
}

private extension DetailRowView {
    func setupLayout() {
        addToView(stackView)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16)
        ])
    }
}
