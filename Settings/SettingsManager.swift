//
//  SettingsManager.swift
//  NextGoal
//
//  Created by Олександр Чижик on 24.10.2025.
//

import Foundation

// "Завгосп", який відповідає за всі налаштування в додатку
class SettingsManager {
	
	// 1. Створюємо єдиний екземпляр для всього додатка.
	// Звертатися будемо так: SettingsManager.shared.isDarkMode
	static let shared = SettingsManager()
	
	// 2. Створюємо "ключі" для доступу до сховища.
	// Це захищає нас від описок.
	private enum Keys {
		static let isDarkMode = "isDarkMode"
		static let defaultCurrency = "defaultCurrency"
		// Додавайте нові ключі сюди...
	}
	
	// 3. Отримуємо доступ до самого сховища
	private let defaults = UserDefaults.standard
	
	// 4. Приватний конструктор, щоб ніхто не міг створити другого "завгоспа"
	private init() {}
	
	// ----------------------------------------------
	// MARK: - Наші налаштування
	// ----------------------------------------------
	
	/// Чи увімкнена темна тема?
	var isDarkMode: Bool {
		get {
			// Коли хтось питає 'SettingsManager.shared.isDarkMode',
			// ми беремо значення зі сховища.
			return defaults.bool(forKey: Keys.isDarkMode)
		}
		set {
			// Коли хтось пише 'SettingsManager.shared.isDarkMode = true',
			// ми зберігаємо нове значення 'newValue' у сховище.
			defaults.set(newValue, forKey: Keys.isDarkMode)
		}
	}
	
	/// Яка валюта обрана за замовчуванням (наприклад, "UAH", "USD")
	var defaultCurrency: String {
		get {
			// .string(forKey:) повертає nil, якщо нічого не знайдено.
			// Тому ми ставимо значення за замовчуванням "UAH".
			return defaults.string(forKey: Keys.defaultCurrency) ?? "UAH"
		}
		set {
			defaults.set(newValue, forKey: Keys.defaultCurrency)
		}
	}
	
	// ----------------------------------------------
	// MARK: - Початкове налаштування
	// ----------------------------------------------
	
	// Встановлює початкові значення при першому запуску
	func setDefaultValues() {
		// Перевіряємо, чи це перший запуск (чи є вже щось за цим ключем?)
		if defaults.object(forKey: Keys.isDarkMode) == nil {
			// Якщо ні, ставимо світлу тему за замовчуванням
			defaults.set(false, forKey: Keys.isDarkMode)
		}
		
		if defaults.object(forKey: Keys.defaultCurrency) == nil {
			// Ставимо гривню за замовчуванням
			defaults.set("UAH", forKey: Keys.defaultCurrency)
		}
		// ... і так далі для всіх нових налаштувань
	}
}
