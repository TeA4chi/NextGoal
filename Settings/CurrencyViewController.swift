import UIKit

// Протокол для повідомлення про вибір валюти
protocol CurrencySelectionDelegate: AnyObject {
    func didSelectCurrency(_ currency: String)
}

// (Протокол CurrencySelectionDelegate вже визначено у SettingsViewController)

class CurrencyViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

	// MARK: - Properties
	
	// "Слухач", якому ми повідомимо про вибір (це наш SettingsViewController)
	weak var delegate: CurrencySelectionDelegate?

	private let tableView = UITableView(frame: .zero, style: .insetGrouped)
	
	// Список валют
	private let currencies = ["UAH", "USD", "EUR"] // Можете додати більше
	
	// Поточна обрана валюта
	private var currentCurrency: String

	// MARK: - Init
	
	init() {
		// При створенні, ми одразу беремо поточне значення з "мозку"
		self.currentCurrency = SettingsManager.shared.defaultCurrency
		super.init(nibName: nil, bundle: nil)
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	// MARK: - Lifecycle
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		title = "currency_picker_title".localized() // Використовуємо локалізацію
		view.backgroundColor = .systemGroupedBackground
		
		// Кнопка "Готово" для закриття
		navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneTapped))
		
		setupTableView()
	}
	
	// MARK: - Setup
	
	private func setupTableView() {
		view.addSubview(tableView)
		tableView.dataSource = self
		tableView.delegate = self
		
		// Розтягуємо таблицю на весь екран
		tableView.frame = view.bounds
		tableView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
		
		// Реєструємо звичайну комірку, нам не потрібна кастомна
		tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
	}
	
	// MARK: - @objc Functions
	
	@objc private func doneTapped() {
		// Просто закриваємо екран
		dismiss(animated: true, completion: nil)
	}
	
	// MARK: - UITableViewDataSource
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		// Кількість рядків = кількість валют
		return currencies.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
		let currency = currencies[indexPath.row]
		
		cell.textLabel?.text = currency
		
		// Ставимо галочку, якщо ця валюта - поточна
		if currency == currentCurrency {
			cell.accessoryType = .checkmark
		} else {
			cell.accessoryType = .none
		}
		
		return cell
	}
	
	// MARK: - UITableViewDelegate
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let selectedCurrency = currencies[indexPath.row]
		
		// 1. Оновлюємо 'поточну' валюту (щоб галочка перемістилась)
		currentCurrency = selectedCurrency
		
		// 2. Повідомляємо "слухача" (SettingsViewController) про вибір
		delegate?.didSelectCurrency(selectedCurrency)
		
		// 3. Оновлюємо таблицю, щоб галочки перемалювалися
		tableView.reloadData()
		
		// 4. (Опціонально) Закриваємо екран одразу після вибору
		// dismiss(animated: true, completion: nil)
	}
}
