//
//  TimeAxisView.swift
//  PetMil
//
//  Created by Emil on 10.04.2026.
//

import UIKit

final class TimeAxisView: UIView {
    
    private var timeTexts: [String] = []
    private var selectedIndex: Int = 0
    
    func configure(timeTexts: [String], selectedIndex: Int) {
        self.timeTexts = timeTexts
        self.selectedIndex = selectedIndex
        
        subviews.forEach { $0.removeFromSuperview() }
        setupLabels()
    }
}

private extension TimeAxisView {
    func setupLabels() {
        guard !timeTexts.isEmpty else { return }
        
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .fillEqually
        stackView.spacing = 0
        
        addToView(stackView)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 4),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -4),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        for (index, timeText) in timeTexts.enumerated() {
            let label = UILabel()
            label.font = .systemFont(ofSize: 10, weight: index == selectedIndex ? .semibold : .regular)
            label.textColor = index == selectedIndex ? .systemBlue : .secondaryLabel
            label.textAlignment = .center
            label.text = timeText
            label.numberOfLines = 1
            label.adjustsFontSizeToFitWidth = true
            label.minimumScaleFactor = 0.75
            stackView.addArrangedSubview(label)
        }
    }
}
