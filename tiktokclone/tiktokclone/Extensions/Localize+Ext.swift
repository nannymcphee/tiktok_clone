//
//  Localize+Ext.swift
//  42Events
//
//  Created by Nguyên Duy on 21/05/2021.
//

import Localize_Swift

extension String {
    var localized: String {
        return localized()
    }
    
    func localizedFormat(_ arguments: CVarArg...) -> String {
        return String(format: localized, arguments: arguments)
    }
    
    func localizedPlural(_ argument: CVarArg) -> String {
        if Localize.currentLanguage() == "en" {
            let format = NSLocalizedString(self, comment: "")
            return String.localizedStringWithFormat(format, argument)
        } else {
            return localizedFormat(argument)
        }
    }
}
