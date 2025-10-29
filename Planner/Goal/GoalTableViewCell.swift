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
	
	// (МИ ВИДАЛИЛИ 'iconContainer' ТА 'iconImageView')
	
	private let titleLabel: UILabel = {
		let label = UILabel()
		label.font = .systemFont(ofSize: 18, weight: .semibold)
		label.textColor = .label
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}()
	
	private let progressView: UIProgressView = {
		let progressView = UIProgressView(progressViewStyle: .default)
		progressView.progressTintColor = .systemYellow
		progressView.trackTintColor = .systemGray5
		progressView.layer.cornerRadius = 5
		progressView.clipsToBounds = true
		progressView.translatesAutoresizingMaskIntoConstraints = false
		return progressView
	}()
	
	private let currentAmountLabel: UILabel = {
		let label = UILabel()
		label.font = .systemFont(ofSize: 14, weight: .medium)
		label.textColor = .secondaryLabel
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}()
	
	private let daysRemainingLabel: UILabel = {
		let label = UILabel()
		label.font = .systemFont(ofSize: 14, weight: .medium)
		label.textColor = .secondaryLabel
		label.textAlignment = .right
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}()
	
	// Створюємо форматер для грошей (1000.0 -> 1 000,00)
	private let currencyFormatter: NumberFormatter = {
		let formatter = NumberFormatter()
		formatter.numberStyle = .decimal
		formatter.maximumFractionDigits = 2
		formatter.minimumFractionDigits = 0
		formatter.groupingSeparator = " " // Пробіл як роздільник
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
		
		// (МИ ВИДАЛИЛИ 'iconContainer')
		
		cardView.addSubview(titleLabel)
		cardView.addSubview(progressView)
		cardView.addSubview(currentAmountLabel)
		cardView.addSubview(daysRemainingLabel)
		
		setupLayout()
	}
	
	private func setupLayout() {
		NSLayoutConstraint.activate([
			// Картка
			cardView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
			cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
			cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
			cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
			
			// (ВИДАЛЕНО КОНСТРЕЙНТИ ДЛЯ 'iconContainer')
			
			// Назва цілі (ОНОВЛЕНО 'leadingAnchor')
			titleLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 20),
			titleLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16), // <--- ЗМІНЕНО
			titleLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),
			
			// Смуга прогресу
			progressView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
			progressView.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
			progressView.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
			progressView.heightAnchor.constraint(equalToConstant: 10),

			// "Накопичено"
			currentAmountLabel.topAnchor.constraint(equalTo: progressView.bottomAnchor, constant: 12),
			currentAmountLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
			
			// "Залишилось днів"
			daysRemainingLabel.topAnchor.constraint(equalTo: progressView.bottomAnchor, constant: 12),
			daysRemainingLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor)
		])
	}
	
	// MARK: - Public Configuration
	
	public func configure(with goal: Goal) {
		// 🔍 ДОДАЙТЕ ЦІ ПРИНТИ:
		print("🔧 Configuring cell for goal: \(goal.title)")
		print("   Current amount: \(goal.currentAmount)")
		print("   Total amount: \(goal.totalAmount)")
		print("   Days remaining: \(goal.daysRemaining)")
		print("   Formatted time: \(goal.formattedTimeRemaining)")
		
		// 1. Налаштовуємо тексти
		titleLabel.text = goal.title
		
		// 2. Використовуємо 'formattedTimeRemaining'
		daysRemainingLabel.text = goal.formattedTimeRemaining
		
		// 3. Форматуємо гроші
		let formattedAmount = currencyFormatter.string(from: NSNumber(value: goal.currentAmount)) ?? "\(goal.currentAmount)"
		currentAmountLabel.text = "Накопичено: \(formattedAmount) \(goal.currency)"
		
		// 4. Налаштовуємо смугу прогресу
		progressView.setProgress(Float(goal.progressPercentage), animated: true)
	}
}
