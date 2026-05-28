//
//  SettingsViewController.swift
//  PetMil
//
//  Created by Emil on 29.05.2026.
//

import UIKit

final class SettingsViewController: UIViewController {

    private let settingsStorage: SettingsStorageProtocol
    private let l10n: L10n
    private var formatter: UnitFormatter

    private enum SettingsRow {
        case temperature, wind, pressure, clockFormat, language
    }

    private let sectionsLayout: [[SettingsRow]] = [
        [.temperature, .wind, .pressure],
        [.clockFormat],
        [.language]
    ]

    private lazy var tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .insetGrouped)
        table.dataSource = self
        table.delegate = self
        table.register(UITableViewCell.self, forCellReuseIdentifier: "SettingsCell")
        return table
    }()

    init(
        settingsStorage: SettingsStorageProtocol = SettingsStorage.shared,
        l10n: L10n = .shared
    ) {
        self.settingsStorage = settingsStorage
        self.l10n = l10n
        self.formatter = UnitFormatter(preferences: settingsStorage.preferences, l10n: l10n)
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = l10n.settingsTitle
        view.backgroundColor = .systemBackground
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: l10n.done,
            style: .done,
            target: self,
            action: #selector(handleDone)
        )

        view.addToView(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    @objc
    private func handleDone() {
        dismiss(animated: true)
    }
}

private extension SettingsViewController {
    func row(at indexPath: IndexPath) -> SettingsRow {
        sectionsLayout[indexPath.section][indexPath.row]
    }

    func title(for row: SettingsRow) -> String {
        switch row {
        case .temperature: return l10n.settingsTemperatureRow
        case .wind: return l10n.settingsWindRow
        case .pressure: return l10n.settingsPressureRow
        case .clockFormat: return l10n.settingsClockRow
        case .language: return l10n.settingsLanguageRow
        }
    }

    func currentValue(for row: SettingsRow) -> String {
        let prefs = settingsStorage.preferences
        switch row {
        case .temperature: return formatter.temperatureLabel(prefs.temperatureUnit)
        case .wind: return formatter.windLabel(prefs.windSpeedUnit)
        case .pressure: return formatter.pressureLabel(prefs.pressureUnit)
        case .clockFormat: return formatter.clockFormatLabel(prefs.clockFormat)
        case .language: return formatter.languageLabel(prefs.language)
        }
    }

    func sectionHeader(_ section: Int) -> String? {
        switch section {
        case 0: return l10n.settingsUnitsSection
        case 1: return l10n.settingsAppearanceSection
        case 2: return l10n.settingsLanguageSection
        default: return nil
        }
    }

    func handleSelection(_ row: SettingsRow) {
        let alert = UIAlertController(title: title(for: row), message: nil, preferredStyle: .actionSheet)

        switch row {
        case .temperature:
            for unit in TemperatureUnit.allCases {
                alert.addAction(UIAlertAction(title: formatter.temperatureLabel(unit), style: .default) { [weak self] _ in
                    self?.updatePreference { $0.temperatureUnit = unit }
                })
            }
        case .wind:
            for unit in WindSpeedUnit.allCases {
                alert.addAction(UIAlertAction(title: formatter.windLabel(unit), style: .default) { [weak self] _ in
                    self?.updatePreference { $0.windSpeedUnit = unit }
                })
            }
        case .pressure:
            for unit in PressureUnit.allCases {
                alert.addAction(UIAlertAction(title: formatter.pressureLabel(unit), style: .default) { [weak self] _ in
                    self?.updatePreference { $0.pressureUnit = unit }
                })
            }
        case .clockFormat:
            for format in ClockFormat.allCases {
                alert.addAction(UIAlertAction(title: formatter.clockFormatLabel(format), style: .default) { [weak self] _ in
                    self?.updatePreference { $0.clockFormat = format }
                })
            }
        case .language:
            for language in AppLanguage.allCases {
                alert.addAction(UIAlertAction(title: formatter.languageLabel(language), style: .default) { [weak self] _ in
                    self?.updatePreference { $0.language = language }
                })
            }
        }

        alert.addAction(UIAlertAction(title: l10n.cancel, style: .cancel))

        if let popover = alert.popoverPresentationController {
            popover.sourceView = view
            popover.sourceRect = CGRect(x: view.bounds.midX, y: view.bounds.midY, width: 1, height: 1)
        }

        present(alert, animated: true)
    }

    func updatePreference(_ mutate: (inout UnitPreferences) -> Void) {
        var prefs = settingsStorage.preferences
        mutate(&prefs)
        settingsStorage.preferences = prefs
        formatter = UnitFormatter(preferences: prefs, l10n: l10n)
        title = l10n.settingsTitle
        navigationItem.rightBarButtonItem?.title = l10n.done
        tableView.reloadData()
    }
}

extension SettingsViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int { sectionsLayout.count }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        sectionsLayout[section].count
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        sectionHeader(section)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .value1, reuseIdentifier: "SettingsCell")
        let row = row(at: indexPath)
        var content = cell.defaultContentConfiguration()
        content.text = title(for: row)
        content.secondaryText = currentValue(for: row)
        cell.contentConfiguration = content
        cell.accessoryType = .disclosureIndicator
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        handleSelection(row(at: indexPath))
    }
}
