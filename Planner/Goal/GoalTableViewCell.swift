//
//  GoalTableViewCell.swift
//  NextGoal
//
//  Created by Олександр Чижик on 27.10.2025.
//

import UIKit

class GoalTableViewCell: UITableViewCell {

	// MARK: - UI Elements
	
	private let cardView: UIView = {
		let view = UIView()
		view.backgroundColor = .secondarySystemGroupedBackground
		view.layer.cornerRadius = 16
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()
	
	private let titleLabel: UILabel = {
		let label = UILabel()
		label.font = .systemFont(ofSize: 20, weight: .bold) // Трохи збільшив шрифт
		label.textColor = .label
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}()
	
	// ДОДАНО: Лейбл для відсотків (справа зверху)
	private let percentageLabel: UILabel = {
		let label = UILabel()
		label.font = .systemFont(ofSize: 20, weight: .bold)
		label.textColor = .systemYellow
		label.textAlignment = .right
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}()
	
	private let progressView: UIProgressView = {
		let progressView = UIProgressView(progressViewStyle: .default)
		progressView.progressTintColor = .systemYellow
		progressView.trackTintColor = .systemGray5
		progressView.layer.cornerRadius = 4
		progressView.clipsToBounds = true
		progressView.translatesAutoresizingMaskIntoConstraints = false
		return progressView
	}()
	
	private let currentAmountLabel: UILabel = {
		let label = UILabel()
		label.font = .systemFont(ofSize: 15, weight: .medium)
		label.textColor = .secondaryLabel
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}()
	
	private let daysRemainingLabel: UILabel = {
		let label = UILabel()
		label.font = .systemFont(ofSize: 15, weight: .medium)
		label.textColor = .secondaryLabel
		label.textAlignment = .right
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}()
	
	// Форматер для грошей
	private let currencyFormatter: NumberFormatter = {
		let formatter = NumberFormatter()
		formatter.numberStyle = .decimal
		formatter.maximumFractionDigits = 0 // Прибираємо копійки для чистоти
		formatter.groupingSeparator = " "
		return formatter
	}()

	// MARK: - Initializers
	
	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		setupViews()
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	// MARK: - Setup
	
	private func setupViews() {
		backgroundColor = .clear
		contentView.backgroundColor = .clear
		selectionStyle = .none

		contentView.addSubview(cardView)
		
		cardView.addSubview(titleLabel)
		cardView.addSubview(percentageLabel) // Додаємо на екран
		cardView.addSubview(progressView)
		cardView.addSubview(currentAmountLabel)
		cardView.addSubview(daysRemainingLabel)
		
		setupLayout()
	}
	
	private func setupLayout() {
		NSLayoutConstraint.activate([
			// 1. Картка (відступи від країв екрану)
			cardView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
			cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
			cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
			cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
			
			// 2. Назва цілі (Зліва зверху)
			titleLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 16),
			titleLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
			// Цей констрейнт не дає назві налізти на відсотки
			titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: percentageLabel.leadingAnchor, constant: -8),
			
			// 3. Відсотки (Справа зверху, навпроти назви)
			percentageLabel.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
			percentageLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),
			
			// 4. Смуга прогресу (По центру)
			progressView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
			progressView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
			progressView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),
			progressView.heightAnchor.constraint(equalToConstant: 8), // Трохи тонша і акуратніша

			// 5. "Накопичено" (Знизу зліва)
			currentAmountLabel.topAnchor.constraint(equalTo: progressView.bottomAnchor, constant: 16),
			currentAmountLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
			currentAmountLabel.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -16), // Важливо: прив'язка до низу
			
			// 6. "Залишилось днів" (Знизу справа)
			daysRemainingLabel.centerYAnchor.constraint(equalTo: currentAmountLabel.centerYAnchor),
			daysRemainingLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16)
		])
	}
	
	// MARK: - Public Configuration
	
	public func configure(with goal: Goal) {
		// 1. Назва
		titleLabel.text = goal.title
		
		// 2. Відсотки
		let percentage = Int(goal.progressPercentage * 100)
		percentageLabel.text = "\(percentage)%"
		
		// 3. Прогрес бар
		progressView.setProgress(Float(goal.progressPercentage), animated: false) // false, щоб не смикалось при прокрутці
		
		// 4. Гроші (форматуємо красиво)
		let current = currencyFormatter.string(from: NSNumber(value: goal.currentAmount)) ?? "\(Int(goal.currentAmount))"
		let total = currencyFormatter.string(from: NSNumber(value: goal.totalAmount)) ?? "\(Int(goal.totalAmount))"
		
		// Формат: "500 / 20 000 UAH"
		currentAmountLabel.text = "\(current) / \(total) \(goal.currency)"
		
		// 5. Дні
		if goal.daysRemaining < 0 {
			daysRemainingLabel.text = "Час вийшов"
			daysRemainingLabel.textColor = .systemRed
		} else {
			// Використовуємо ваше форматування, якщо воно є, або просто дні
			daysRemainingLabel.text = goal.formattedTimeRemaining
			daysRemainingLabel.textColor = .secondaryLabel
		}
	}
}
