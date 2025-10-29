//
//  PersistenceManager.swift
//  NextGoal
//
//  Created by Олександр Чижик on 26.10.2025.
//

import Foundation

//клас збереження цілей
class PersistenceManager {
	
	static let shared = PersistenceManager()
	
	//адреса файлу збереження
	private var fileURL: URL {
		let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
		return urls[0].appendingPathComponent("goals.json")
	}
	
	private init() {}
	
	//завантаженя цілі з файлу
	func loadGoals() -> [Goal] {
		//отримання даних з файлу
		guard let data = try? Data(contentsOf: fileURL) else {
			print("Не вдалося завантажити дані, повертаю порожній масив.")
			return [] // Якщо файлу немає (перший запуск), повертаємо порожній масив
		}
		do {
			let decoder = JSONDecoder()
			let goals = try decoder.decode([Goal].self, from: data)
			return goals
		} catch {
			print("Помилка розшифровки цілей: \(error)")
			return [] // Якщо файл пошкоджений, теж повертаємо порожній масив)
		}
	}
	
	func saveGoals(_ goals: [Goal]) {
		do {
			let encoder = JSONEncoder()
			encoder.outputFormatting = .prettyPrinted //красивий JSON
			let data = try encoder.encode(goals)
			
			//запис шифрованих даних
			try data.write(to: fileURL, options: .atomicWrite)
			print("Цілі успішно збережено у: \(fileURL.path)")
		} catch {
			print("Помилка шифрування або збереження цілей: \(error)")
		}
	}
}
