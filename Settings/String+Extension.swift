//
//  String+Extension.swift
//  NextGoal
//
//  Created by Олександр Чижик on 24.10.2025.
//

import Foundation

extension String {
	// Ця функція буде брати рядок (наш ключ)
	// і шукати його у файлі Localizable.strings
	func localized() -> String {
		return NSLocalizedString(self, comment: "")
	}
}
