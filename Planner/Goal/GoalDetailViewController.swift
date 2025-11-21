//
//  GoalDetailViewController.swift
//  NextGoal
//
//  Created by Олександр Чижик on 03.11.2025.
//

import UIKit

// Протокол для повідомлення PlannerViewController про оновлення
protocol GoalDetailDelegate: AnyObject {
	func didUpdateGoal(_ goal: Goal)
	func didDeleteGoal(_ goal: Goal)
}

// 1. ПРИБРАНО 'AddContributionDelegate' З ЦЬОГО РЯДКА.
// Ми оголосимо його в 'extension' в кінці файлу.
class GoalDetailViewController: UIViewController {
	
	// MARK: - Properties
	
	private var goal: Goal
	weak var delegate: GoalDetailDelegate?
	
	// 3. ДОДАНО: Посилання на констрейнт висоти таблиці,
	// щоб ми могли його оновлювати
	private var tableViewHeightConstraint: NSLayoutConstraint?
	
	// MARK: - UI Elements
	
	private let scrollView: UIScrollView = {
		let scroll = UIScrollView()
		scroll.translatesAutoresizingMaskIntoConstraints = false
		return scroll
	}()
	
	private let contentView: UIView = {
		let view = UIView()
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()
	
	private let titleLabel: UILabel = {
		let label = UILabel()
		label.font = .systemFont(ofSize: 28, weight: .bold)
		label.numberOfLines = 0
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}()
	
	private let descriptionLabel: UILabel = {
		let label = UILabel()
		label.font = .systemFont(ofSize: 16)
		label.textColor = .secondaryLabel
		label.numberOfLines = 0
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}()
	
	private let progressCard: UIView = {
		let view = UIView()
		view.backgroundColor = .secondarySystemGroupedBackground
		view.layer.cornerRadius = 16
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()
	
	private let progressLabel: UILabel = {
		let label = UILabel()
		label.text = "Прогрес" // TODO: Локалізувати
		label.font = .systemFont(ofSize: 14, weight: .medium)
		label.textColor = .secondaryLabel
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}()
	
	private let percentageLabel: UILabel = {
		let label = UILabel()
		label.font = .systemFont(ofSize: 24, weight: .bold)
		label.textColor = .systemYellow
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}()
	
	private let progressView: UIProgressView = {
		let progress = UIProgressView(progressViewStyle: .default)
		progress.progressTintColor = .systemYellow
		progress.trackTintColor = .systemGray5
		progress.layer.cornerRadius = 5
		progress.clipsToBounds = true
		progress.translatesAutoresizingMaskIntoConstraints = false
		return progress
	}()
	
	private let savedLabel: UILabel = {
		let label = UILabel()
		label.font = .systemFont(ofSize: 14, weight: .medium)
		label.textColor = .secondaryLabel
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}()
	
	private let currentAmountLabel: UILabel = {
		let label = UILabel()
		label.font = .systemFont(ofSize: 28, weight: .bold)
		label.textColor = .systemYellow
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}()
	
	private let goalLabel: UILabel = {
		let label = UILabel()
		label.font = .systemFont(ofSize: 14, weight: .medium)
		label.textColor = .secondaryLabel
		label.textAlignment = .right
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}()
	
	private let totalAmountLabel: UILabel = {
		let label = UILabel()
		label.font = .systemFont(ofSize: 28, weight: .bold)
		label.textAlignment = .right
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}()
	
	private let statsStack: UIStackView = {
		let stack = UIStackView()
		stack.axis = .vertical
		stack.distribution = .fillEqually
		stack.spacing = 12
		stack.translatesAutoresizingMaskIntoConstraints = false
		return stack
	}()
	
	private let remainingCard = StatCard()
	private let daysCard = StatCard()
	private let dailyCard = StatCard()
	private let dateCard = StatCard()
	
	private let historyLabel: UILabel = {
		let label = UILabel()
		label.text = "Останні відкладення" // TODO: Локалізувати
		label.font = .systemFont(ofSize: 22, weight: .bold)
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}()
	
	private let tableView: UITableView = {
		let table = UITableView(frame: .zero, style: .plain)
		table.backgroundColor = .clear
		table.separatorStyle = .none
		table.isScrollEnabled = false
		table.translatesAutoresizingMaskIntoConstraints = false
		table.register(ContributionCell.self, forCellReuseIdentifier: "ContributionCell")
		return table
	}()
	
	private let addButton: UIButton = {
		let button = UIButton(type: .system)
		button.setTitle("Додати відкладення", for: .normal) // TODO: Локалізувати
		button.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
		button.backgroundColor = .systemYellow
		button.setTitleColor(.black, for: .normal)
		button.layer.cornerRadius = 12
		button.translatesAutoresizingMaskIntoConstraints = false
		return button
	}()
	
	private let currencyFormatter: NumberFormatter = {
		let formatter = NumberFormatter()
		formatter.numberStyle = .decimal
		formatter.maximumFractionDigits = 2
		formatter.minimumFractionDigits = 0
		formatter.groupingSeparator = " "
		return formatter
	}()
	
	// MARK: - Init
	
	init(goal: Goal) {
		self.goal = goal
		super.init(nibName: nil, bundle: nil)
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	// MARK: - Lifecycle
	
	override func viewDidLoad() {
		super.viewDidLoad()
		setupUI()
		setupLayout()
		updateUI()
	}
	
	// MARK: - Setup
	
	private func setupUI() {
		view.backgroundColor = .systemBackground
		title = "Деталі мети" // TODO: Локалізувати
		
		navigationItem.rightBarButtonItem = UIBarButtonItem(
			image: UIImage(systemName: "ellipsis.circle"),
			style: .plain,
			target: self,
			action: #selector(menuTapped)
		)
		
		view.addSubview(scrollView)
		scrollView.addSubview(contentView)
		
		contentView.addSubview(titleLabel)
		contentView.addSubview(descriptionLabel)
		contentView.addSubview(progressCard)
		contentView.addSubview(statsStack)
		contentView.addSubview(historyLabel)
		contentView.addSubview(tableView)
		contentView.addSubview(addButton)
		
		// Progress Card
		progressCard.addSubview(progressLabel)
		progressCard.addSubview(percentageLabel)
		progressCard.addSubview(progressView)
		progressCard.addSubview(savedLabel)
		progressCard.addSubview(currentAmountLabel)
		progressCard.addSubview(goalLabel)
		progressCard.addSubview(totalAmountLabel)
				
				// 1. Верхній рядок (Залишок + Дні)
				let topRow = UIStackView(arrangedSubviews: [remainingCard, daysCard])
				topRow.axis = .horizontal
				topRow.distribution = .fillEqually
				topRow.spacing = 12
				
				// 2. Нижній рядок (Внесок + Дата)
				let bottomRow = UIStackView(arrangedSubviews: [dailyCard, dateCard])
				bottomRow.axis = .horizontal
				bottomRow.distribution = .fillEqually
				bottomRow.spacing = 12
				
				// 3. Додаємо рядки у головний вертикальний стек
				statsStack.addArrangedSubview(topRow)
				statsStack.addArrangedSubview(bottomRow)
		
		tableView.dataSource = self
		tableView.delegate = self
		
		addButton.addTarget(self, action: #selector(addContributionTapped), for: .touchUpInside)
	}
	
	private func setupLayout() {
		// 4. ОНОВЛЕНО: Ми зберігаємо посилання на констрейнт висоти
		
		// Створюємо констрейнт для висоти таблиці
		let heightConstraint = tableView.heightAnchor.constraint(equalToConstant: CGFloat(goal.contributions.count * 80))
		// Зберігаємо посилання
		self.tableViewHeightConstraint = heightConstraint
		
		NSLayoutConstraint.activate([
			scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
			scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
			scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
			scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
			
			contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
			contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
			contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
			contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
			contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
			
			titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
			titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
			titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
			
			descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
			descriptionLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
			descriptionLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
			
			progressCard.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 24),
			progressCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
			progressCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
			progressCard.heightAnchor.constraint(equalToConstant: 200),
			
			progressLabel.topAnchor.constraint(equalTo: progressCard.topAnchor, constant: 20),
			progressLabel.leadingAnchor.constraint(equalTo: progressCard.leadingAnchor, constant: 20),
			
			percentageLabel.centerYAnchor.constraint(equalTo: progressLabel.centerYAnchor),
			percentageLabel.trailingAnchor.constraint(equalTo: progressCard.trailingAnchor, constant: -20),
			
			progressView.topAnchor.constraint(equalTo: progressLabel.bottomAnchor, constant: 16),
			progressView.leadingAnchor.constraint(equalTo: progressLabel.leadingAnchor),
			progressView.trailingAnchor.constraint(equalTo: percentageLabel.trailingAnchor),
			progressView.heightAnchor.constraint(equalToConstant: 10),
			
			savedLabel.topAnchor.constraint(equalTo: progressView.bottomAnchor, constant: 20),
			savedLabel.leadingAnchor.constraint(equalTo: progressLabel.leadingAnchor),
			
			currentAmountLabel.topAnchor.constraint(equalTo: savedLabel.bottomAnchor, constant: 8),
			currentAmountLabel.leadingAnchor.constraint(equalTo: savedLabel.leadingAnchor),
			
			goalLabel.topAnchor.constraint(equalTo: savedLabel.topAnchor),
			goalLabel.trailingAnchor.constraint(equalTo: percentageLabel.trailingAnchor),
			
			totalAmountLabel.topAnchor.constraint(equalTo: currentAmountLabel.topAnchor),
			totalAmountLabel.trailingAnchor.constraint(equalTo: goalLabel.trailingAnchor),
			
			statsStack.topAnchor.constraint(equalTo: progressCard.bottomAnchor, constant: 16),
			statsStack.leadingAnchor.constraint(equalTo: progressCard.leadingAnchor),
			statsStack.trailingAnchor.constraint(equalTo: progressCard.trailingAnchor),
			statsStack.heightAnchor.constraint(equalToConstant: 220),
			
			historyLabel.topAnchor.constraint(equalTo: statsStack.bottomAnchor, constant: 32),
			historyLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
			historyLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
			
			tableView.topAnchor.constraint(equalTo: historyLabel.bottomAnchor, constant: 16),
			tableView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
			tableView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
			// Активуємо наш збережений констрейнт
			heightConstraint,
			
			addButton.topAnchor.constraint(equalTo: tableView.bottomAnchor, constant: 24),
			addButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
			addButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
			addButton.heightAnchor.constraint(equalToConstant: 54),
			addButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -32)
		])
	}
	
	// Ця функція тепер буде викликатися з делегата
	private func updateUI() {
		titleLabel.text = goal.title
		descriptionLabel.text = goal.description ?? "Перша власна квартира в історичному центрі" // TODO: Локалізувати
		descriptionLabel.isHidden = goal.description == nil
		
		// Progress Card
		let percentage = Int(goal.progressPercentage * 100)
		percentageLabel.text = "\(percentage)%"
		progressView.setProgress(Float(goal.progressPercentage), animated: true)
		
		savedLabel.text = "Заощаджено" // TODO: Локалізувати
		let current = currencyFormatter.string(from: NSNumber(value: goal.currentAmount)) ?? "\(goal.currentAmount)"
		currentAmountLabel.text = "\(current) \(goal.currency)"
		
		goalLabel.text = "Ціль" // TODO: Локалізувати
		let total = currencyFormatter.string(from: NSNumber(value: goal.totalAmount)) ?? "\(goal.totalAmount)"
		totalAmountLabel.text = "\(total) \(goal.currency)"
		
		// Stats Cards
		let remaining = currencyFormatter.string(from: NSNumber(value: goal.remainingAmount)) ?? "\(goal.remainingAmount)"
		remainingCard.configure(title: "Залишилось", value: "\(remaining) \(goal.currency)") // TODO: ЛокалізуL
		
		daysCard.configure(title: "Днів", value: "\(goal.daysRemaining)") // TODO: Локалізувати
		
		let daily = currencyFormatter.string(from: NSNumber(value: goal.equivalentDailyContribution)) ?? "\(goal.equivalentDailyContribution)"
		dailyCard.configure(title: "Щоденний внесок", value: "\(daily) \(goal.currency)") // TODO: Локалізувати
		
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "dd.MM.yyyy"
		let dateString = dateFormatter.string(from: goal.expectedCompletionDate)
		dateCard.configure(title: "Очікувана дата досягнення", value: dateString) // TODO: Локалізувати
		
		// Оновлюємо таблицю, щоб показати новий внесок
		tableView.reloadData()
	}
	
	// MARK: - Actions
	
	@objc private func addContributionTapped() {
		let addVC = AddContributionViewController(goal: goal)
		addVC.delegate = self
		let navController = UINavigationController(rootViewController: addVC)
		present(navController, animated: true)
	}
	
	@objc private func menuTapped() {
		let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
		
		// --- ДІЯ: РЕДАГУВАТИ ---
		alert.addAction(UIAlertAction(title: "Редагувати", style: .default) { [weak self] _ in
			guard let self = self else { return }
			
			// Тепер використовуємо ініціалізатор із goalToEdit:
			let editVC = AddGoalViewController(goalToEdit: self.goal)
			
			editVC.delegate = self
			let navController = UINavigationController(rootViewController: editVC)
			self.present(navController, animated: true)
		})
		
		// --- ДІЯ: ВИДАЛИТИ ---
		alert.addAction(UIAlertAction(title: "Видалити", style: .destructive) { [weak self] _ in
			guard let self = self else { return }
			
			// Показуємо підтвердження перед видаленням
			let confirmAlert = UIAlertController(
				title: "Видалити ціль?",
				message: "Цю дію неможливо скасувати.",
				preferredStyle: .alert
			)
			
			confirmAlert.addAction(UIAlertAction(title: "Скасувати", style: .cancel))
			confirmAlert.addAction(UIAlertAction(title: "Видалити", style: .destructive) { _ in
				// Викликаємо делегат (PlannerViewController), щоб він видалив ціль
				self.delegate?.didDeleteGoal(self.goal)
			})
			
			self.present(confirmAlert, animated: true)
		})
		
		alert.addAction(UIAlertAction(title: "Скасувати", style: .cancel))
		
		present(alert, animated: true)
	}
}

// MARK: - UITableView DataSource & Delegate

extension GoalDetailViewController: UITableViewDataSource, UITableViewDelegate {
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return goal.contributions.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		guard let cell = tableView.dequeueReusableCell(withIdentifier: "ContributionCell", for: indexPath) as? ContributionCell else {
			return UITableViewCell()
		}
		
		// Показуємо в зворотному порядку (останні зверху)
		let contribution = goal.contributions.sorted(by: { $0.date > $1.date })[indexPath.row]
		cell.configure(with: contribution, currency: goal.currency)
		return cell
	}
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return 80
	}
}

// MARK: - AddContributionDelegate

extension GoalDetailViewController: AddContributionDelegate {
	// Ця функція буде викликана екраном 'AddContributionViewController'
	func didAddContribution(_ contribution: Contribution) {
		// 1. Оновлюємо нашу локальну модель 'goal'
		// (Припускаємо, що 'Goal' - це struct і 'addContribution' - 'mutating')
		goal.addContribution(contribution)
		
		// 2. Повідомляємо попередній екран (PlannerVC), що ціль оновилась
		delegate?.didUpdateGoal(goal)
		
		// 3. Оновлюємо ВЕСЬ UI на цьому екрані з новими даними
		updateUI()
		
		// 4. ОНОВЛЕНО: Правильно оновлюємо висоту таблиці
		// Ми змінюємо 'constant' у існуючого констрейнта
		self.tableViewHeightConstraint?.constant = CGFloat(goal.contributions.count * 80)
		
		// 5. (Опціонально) Анімуємо зміну висоти
		UIView.animate(withDuration: 0.3) {
			self.view.layoutIfNeeded() // 'self.view' оновить лейаут
		}
	}
}

// MARK: - AddGoalDelegate (для редагування цілі)

extension GoalDetailViewController: AddGoalDelegate {
	// Цей метод спрацює, коли ми натиснемо "Зберегти" на екрані редагування
	func didCreateGoal(_ updatedGoal: Goal) {
		// 1. Оновлюємо локальну модель
		self.goal = updatedGoal
		
		// 2. Оновлюємо весь інтерфейс новими даними
		updateUI()
		
		// 3. Повідомляємо головний екран (PlannerViewController),
		// що дані змінилися (щоб оновити список на головній)
		delegate?.didUpdateGoal(updatedGoal)
	}
	
	func didUpdateGoal(_ updatedGoal: Goal) {
		// Для деталей мети, редагування і створення працюють однаково:
		self.goal = updatedGoal
		updateUI()
		delegate?.didUpdateGoal(updatedGoal)
	}
}

