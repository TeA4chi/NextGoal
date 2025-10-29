import UIKit

// 1. ОГОЛОШЕННЯ КЛАСУ
// Зверніть увагу: ми НЕ пишемо тут 'AddGoalDelegate' чи 'AddMenuDelegate'.
// Ми додамо їх у 'extension' в кінці файлу для чистоти коду.
class PlannerViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

	// MARK: - Properties
	
	// Масив даних, який завантажується з пам'яті
	private var goals: [Goal] = PersistenceManager.shared.loadGoals() {
		// 'didSet' спрацьовує при будь-якій зміні масиву
		didSet {
			updateHeaderSubtitle()
			PersistenceManager.shared.saveGoals(goals) // Зберігаємо зміни
		}
	}
	
	// MARK: - UI Elements
	
	private let subtitleLabel: UILabel = {
		let label = UILabel()
		label.textColor = .secondaryLabel
		label.font = .systemFont(ofSize: 16)
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}()
	
	private let tableView: UITableView = {
		let tableView = UITableView(frame: .zero, style: .plain)
		tableView.backgroundColor = .systemBackground
		tableView.separatorStyle = .none
		tableView.translatesAutoresizingMaskIntoConstraints = false
		// Реєструємо нашу кастомну комірку
		tableView.register(GoalTableViewCell.self, forCellReuseIdentifier: "GoalCell")
		return tableView
	}()
	
	private let addButton: UIButton = {
		let button = UIButton(type: .system)
		let config = UIImage.SymbolConfiguration(pointSize: 24, weight: .medium)
		button.setImage(UIImage(systemName: "plus", withConfiguration: config), for: .normal)
		button.backgroundColor = .systemYellow
		button.tintColor = .black
		button.layer.cornerRadius = 28
		button.layer.shadowOpacity = 0.3
		button.layer.shadowRadius = 8
		button.layer.shadowOffset = CGSize(width: 0, height: 4)
		button.translatesAutoresizingMaskIntoConstraints = false
		return button
	}()
	
	// MARK: - Lifecycle
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		setupUI()
		setupLayout()
		updateHeaderSubtitle() // Встановлюємо початковий текст (напр. "0 цілей")
	}
	
	// MARK: - Setup
	
	private func setupUI() {
		view.backgroundColor = .systemBackground
		
		title = "tab_planner".localized()
		navigationController?.navigationBar.prefersLargeTitles = true
		
		// Налаштовуємо таблицю
		tableView.dataSource = self
		tableView.delegate = self
		tableView.tableHeaderView = createTableHeaderView() // Додаємо шапку
		
		// Додаємо елементи на екран
		view.addSubview(tableView)
		view.addSubview(addButton)
		
		// Призначаємо дію для кнопки
		addButton.addTarget(self, action: #selector(addButtonTapped), for: .touchUpInside)
	}
	
	private func setupLayout() {
		NSLayoutConstraint.activate([
			// Таблиця займає весь екран
			tableView.topAnchor.constraint(equalTo: view.topAnchor),
			tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
			tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
			tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
			
			// Кнопка "+" внизу справа
			addButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
			addButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
			addButton.widthAnchor.constraint(equalToConstant: 56),
			addButton.heightAnchor.constraint(equalToConstant: 56)
		])
	}
	
	private func createTableHeaderView() -> UIView {
		let headerView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 40))
		headerView.addSubview(subtitleLabel)
		
		NSLayoutConstraint.activate([
			subtitleLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
			subtitleLabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor)
		])
		
		return headerView
	}
	
	// MARK: - Actions
	
	@objc private func addButtonTapped() {
		// 1. Створюємо нове меню "Що додати?"
		let menuVC = AddMenuViewController()
		
		// 2. Призначаємо себе "слухачем" (делегатом)
		menuVC.delegate = self
		
		// 3. Налаштовуємо показ "знизу"
		if let sheet = menuVC.sheetPresentationController {
			sheet.detents = [.medium()]
			sheet.prefersGrabberVisible = true
			sheet.preferredCornerRadius = 24
		}
		
		// 4. Показуємо меню
		present(menuVC, animated: true, completion: nil)
	}
	
	// MARK: - Helpers
	
	private func updateHeaderSubtitle() {
			// ---- ВИПРАВЛЕННЯ ----
			// Ми більше НЕ використовуємо ".localized()"
			// Ми викликаємо NSLocalizedString напряму
			let formatString = NSLocalizedString("planner_subtitle", comment: "Subtitle for goals count")
			
			// Ця функція тепер отримає правильний шаблон з .stringsdict
			subtitleLabel.text = String.localizedStringWithFormat(formatString, goals.count)
		}
	
	// MARK: - UITableViewDataSource
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return goals.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		// Використовуємо нашу кастомну комірку
		guard let cell = tableView.dequeueReusableCell(withIdentifier: "GoalCell", for: indexPath) as? GoalTableViewCell else {
			return UITableViewCell()
		}
		
		let goal = goals[indexPath.row]
		cell.configure(with: goal)
		return cell
	}
	
	// MARK: - UITableViewDelegate
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return 140 // Висота для кастомної комірки
	}

} // <-- 2. ЦЕ КІНЕЦЬ КЛАСУ 'PlannerViewController'


//
// MARK: - Extensions
//
// 3. Весь код делегатів має бути ТУТ, поза межами класу
//

// "Підписуємо" клас на протокол AddGoalDelegate
extension PlannerViewController: AddGoalDelegate {
	
	func didCreateGoal(_ goal: Goal) {
		// 🔍 ДОДАЙТЕ ЦІ ПРИНТИ:
		print("🎯 didCreateGoal called!")
		print("   Goal title: \(goal.title)")
		print("   Days remaining: \(goal.daysRemaining)")
		print("   Formatted time: \(goal.formattedTimeRemaining)")
		
		// 1. Додаємо нову ціль в початок масиву
		self.goals.insert(goal, at: 0)
		
		print("   Goals count: \(self.goals.count)")
		
		// 2. Оновлюємо таблицю, щоб показати новий елемент
		let indexPath = IndexPath(row: 0, section: 0)
		self.tableView.insertRows(at: [indexPath], with: .automatic)
	}
}

// "Підписуємо" клас на протокол AddMenuDelegate
extension PlannerViewController: AddMenuDelegate {
	
	func didSelectAddGoal() {
		// 1. Закриваємо поточне меню
		dismiss(animated: true) {
			// 2. І одразу після закриття показуємо екран 'AddGoal'
			let addGoalVC = AddGoalViewController()
			addGoalVC.delegate = self // 'self' вже є AddGoalDelegate
			let navController = UINavigationController(rootViewController: addGoalVC)
			self.present(navController, animated: true, completion: nil)
		}
	}
	
	func didSelectAddDebtor() {
		// Ми обрали "Додати боржника" (поки що заглушка)
		dismiss(animated: true) {
			print("TODO: Implement 'Add Debtor' screen")
			// Тут ми будемо показувати екран AddDebtorViewController
		}
	}
}
