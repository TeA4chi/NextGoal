import UIKit

protocol AddContributionDelegate: AnyObject {
	func didAddContribution(_ contribution: Contribution)
}

class AddContributionViewController: UIViewController {

	// MARK: - Properties
	
	private let goal: Goal
	weak var delegate: AddContributionDelegate?
	
	// MARK: - UI Elements
	
	private let titleLabel: UILabel = {
		let label = UILabel()
		label.text = "Новий внесок"
		label.font = .systemFont(ofSize: 22, weight: .bold)
		label.textAlignment = .center
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}()
	
	private let amountContainer: UIView = {
		let view = UIView()
		view.backgroundColor = .secondarySystemGroupedBackground
		view.layer.cornerRadius = 12
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()
	
	private let currencyLabel: UILabel = {
		let label = UILabel()
		label.font = .systemFont(ofSize: 24, weight: .bold)
		label.textColor = .secondaryLabel
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}()
	
	private let amountTextField: UITextField = {
		let tf = UITextField()
		tf.placeholder = "0"
		tf.font = .systemFont(ofSize: 32, weight: .bold)
		tf.keyboardType = .decimalPad // Дозволяє крапку/кому
		tf.textAlignment = .right
		tf.translatesAutoresizingMaskIntoConstraints = false
		return tf
	}()
	
	private let datePicker: UIDatePicker = {
		let picker = UIDatePicker()
		picker.datePickerMode = .date
		picker.preferredDatePickerStyle = .compact
		picker.translatesAutoresizingMaskIntoConstraints = false
		return picker
	}()
	
	private let dateLabel: UILabel = {
		let label = UILabel()
		label.text = "Дата внеску"
		label.font = .systemFont(ofSize: 17, weight: .medium)
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}()
	
	private let noteTextField: UITextField = {
		let tf = UITextField()
		tf.placeholder = "Опис (необов'язково)"
		tf.borderStyle = .roundedRect
		tf.backgroundColor = .secondarySystemGroupedBackground
		tf.clearButtonMode = .whileEditing
		tf.translatesAutoresizingMaskIntoConstraints = false
		return tf
	}()
	
	private let saveButton: UIButton = {
		let button = UIButton(type: .system)
		button.setTitle("Додати внесок", for: .normal)
		button.titleLabel?.font = .systemFont(ofSize: 17, weight: .bold)
		button.backgroundColor = .systemYellow
		button.setTitleColor(.black, for: .normal)
		button.layer.cornerRadius = 12
		button.translatesAutoresizingMaskIntoConstraints = false
		return button
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
		amountTextField.becomeFirstResponder()
	}
	
	// MARK: - Setup
	
	private func setupUI() {
		view.backgroundColor = .systemBackground
		currencyLabel.text = goal.currency
		
		view.addSubview(titleLabel)
		view.addSubview(amountContainer)
		amountContainer.addSubview(amountTextField)
		amountContainer.addSubview(currencyLabel)
		
		view.addSubview(dateLabel)
		view.addSubview(datePicker)
		view.addSubview(noteTextField)
		view.addSubview(saveButton)
		
		saveButton.addTarget(self, action: #selector(saveTapped), for: .touchUpInside)
		
		let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
		view.addGestureRecognizer(tap)
	}
	
	private func setupLayout() {
		NSLayoutConstraint.activate([
			titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
			titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
			
			amountContainer.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 30),
			amountContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
			amountContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
			amountContainer.heightAnchor.constraint(equalToConstant: 80),
			
			currencyLabel.trailingAnchor.constraint(equalTo: amountContainer.trailingAnchor, constant: -16),
			currencyLabel.centerYAnchor.constraint(equalTo: amountContainer.centerYAnchor),
			
			amountTextField.leadingAnchor.constraint(equalTo: amountContainer.leadingAnchor, constant: 16),
			amountTextField.trailingAnchor.constraint(equalTo: currencyLabel.leadingAnchor, constant: -8),
			amountTextField.centerYAnchor.constraint(equalTo: amountContainer.centerYAnchor),
			amountTextField.heightAnchor.constraint(equalTo: amountContainer.heightAnchor),
			
			dateLabel.topAnchor.constraint(equalTo: amountContainer.bottomAnchor, constant: 30),
			dateLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
			
			datePicker.centerYAnchor.constraint(equalTo: dateLabel.centerYAnchor),
			datePicker.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
			
			noteTextField.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 30),
			noteTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
			noteTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
			noteTextField.heightAnchor.constraint(equalToConstant: 50),
			
			saveButton.topAnchor.constraint(equalTo: noteTextField.bottomAnchor, constant: 40),
			saveButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
			saveButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
			saveButton.heightAnchor.constraint(equalToConstant: 54)
		])
	}
	
	// MARK: - Actions
	
	@objc private func dismissKeyboard() {
		view.endEditing(true)
	}
	
	@objc private func saveTapped() {
		// 1. Отримуємо текст
		guard let text = amountTextField.text else { return }
		
		// 2. Замінюємо кому на крапку (для України це часта проблема) і конвертуємо
		let cleanText = text.replacingOccurrences(of: ",", with: ".")
		
		guard let amount = Double(cleanText), amount > 0 else {
			print("Помилка: Некоректна сума")
			// Тут можна додати анімацію тряски (shake) поля
			return
		}
		
		// 3. Логіка автоматичного опису
		var note = noteTextField.text ?? ""
		
		// Якщо користувач нічого не написав, генеруємо "розумний" опис
		if note.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
			note = determineDefaultNote(for: datePicker.date)
		}
		
		// 4. Створення та збереження
		let contribution = Contribution(
			amount: amount,
			date: datePicker.date,
			note: note
		)
		
		delegate?.didAddContribution(contribution)
		dismiss(animated: true)
	}
	
	// MARK: - Helper Logic
	
	/// Ця функція визначає автоматичну назву внеску базуючись на частоті цілі та даті
	private func determineDefaultNote(for selectedDate: Date) -> String {
		let calendar = Calendar.current
		
		switch goal.contributionFrequency {
		case .daily:
			// Для щоденної цілі будь-який день підходить
			return "Щоденний внесок"
			
		case .weekly:
			// Перевіряємо, чи співпадає день тижня (Понеділок == Понеділок)
			// startAmountDate - це дата створення цілі або дата першого платежу
			let goalWeekday = calendar.component(.weekday, from: goal.createdDate)
			let selectedWeekday = calendar.component(.weekday, from: selectedDate)
			
			if goalWeekday == selectedWeekday {
				return "Тижневий внесок"
			} else {
				return "Додатковий внесок"
			}
			
		case .monthly:
			// Перевіряємо, чи співпадає число місяця (21-ше == 21-ше)
			let goalDay = calendar.component(.day, from: goal.createdDate)
			let selectedDay = calendar.component(.day, from: selectedDate)
			
			if goalDay == selectedDay {
				return "Місячний внесок"
			} else {
				return "Додатковий внесок"
			}
		}
	}
}
