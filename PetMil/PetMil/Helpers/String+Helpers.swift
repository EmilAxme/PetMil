//
//  String+Helpers.swift
//  PetMil
//
//  Created by Emil on 05.03.2026.
//

import Foundation

extension String {
    func localizedPlural(_ arg: Int) -> String {
        let formatString = NSLocalizedString(self, comment: "\(self) could not be found in Localizable.stringdict")
        return Self.localizedStringWithFormat(formatString, arg)
    }

    var localized: String {
        NSLocalizedString(self, comment: "\(self) could not be found in Localizable.strings")
    }
}
