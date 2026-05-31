//
//  ConditionGridView.swift
//  PetMil
//
//  Created by Emil on 29.05.2026.
//

import UIKit

final class ConditionGridView: UIView {

    private lazy var rootStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 10
        return stack
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with tiles: [WeatherModels.ConditionTile]) {
        rootStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

        for pair in tiles.chunked(into: 2) {
            let row = makeRowStack()
            for tile in pair {
                let tileView = ConditionTileView()
                tileView.configure(
                    symbolName: tile.symbolName,
                    title: tile.title,
                    value: tile.value,
                    subtitle: tile.subtitle
                )
                row.addArrangedSubview(tileView)
            }
            if pair.count == 1 {
                row.addArrangedSubview(makeSpacerView())
            }
            rootStackView.addArrangedSubview(row)
        }
    }
}

private extension ConditionGridView {
    func setupLayout() {
        addToView(rootStackView)
        NSLayoutConstraint.activate([
            rootStackView.topAnchor.constraint(equalTo: topAnchor),
            rootStackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            rootStackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            rootStackView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    func makeRowStack() -> UIStackView {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.spacing = 10
        return stack
    }

    func makeSpacerView() -> UIView {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }
}

private extension Array {
    func chunked(into size: Int) -> [[Element]] {
        guard size > 0 else { return [] }
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0..<Swift.min($0 + size, count)])
        }
    }
}
