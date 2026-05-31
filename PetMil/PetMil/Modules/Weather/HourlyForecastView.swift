//
//  HourlyForecastView.swift
//  PetMil
//
//  Created by Emil on 29.05.2026.
//

import UIKit

final class HourlyForecastView: UIView {

    var weatherIconService: WeatherIconServiceProtocol?

    private var rows: [WeatherModels.HourlyRow] = []

    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 4
        layout.minimumInteritemSpacing = 0
        layout.itemSize = CGSize(width: 60, height: 110)
        layout.sectionInset = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 12)

        let collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collection.backgroundColor = .clear
        collection.showsHorizontalScrollIndicator = false
        collection.dataSource = self
        collection.register(
            HourlyForecastCell.self,
            forCellWithReuseIdentifier: HourlyForecastCell.reuseIdentifier
        )
        return collection
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupAppearance()
        setupLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with rows: [WeatherModels.HourlyRow]) {
        self.rows = rows
        collectionView.reloadData()
    }
}

private extension HourlyForecastView {
    func setupAppearance() {
        backgroundColor = .secondarySystemBackground
        layer.cornerRadius = 24
        layer.cornerCurve = .continuous
        clipsToBounds = true
    }

    func setupLayout() {
        addToView(collectionView)

        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: bottomAnchor),
            collectionView.heightAnchor.constraint(equalToConstant: 110)
        ])
    }
}

extension HourlyForecastView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        rows.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: HourlyForecastCell.reuseIdentifier,
            for: indexPath
        ) as? HourlyForecastCell else {
            return UICollectionViewCell()
        }

        let row = rows[indexPath.item]
        cell.configure(with: row)
        weatherIconService?.loadIcon(into: cell.iconImageView, iconCode: row.iconCode)
        return cell
    }
}
