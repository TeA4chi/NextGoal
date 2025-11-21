//
//  AddGoalViewController.swift
//  NextGoal
//
//  Created by Олександр Чижик on 24.10.2025.
//

import UIKit

// Оновлений протокол з підтримкою редагування
protocol AddGoalDelegate: AnyObject {
	func didCreateGoal(_ goal: Goal)
	func didUpdateGoal(_ goal: Goal)
}

class AddGoalViewController: UIViewController, UITextViewDelegate, CurrencyPickerDelegate {

	weak var delegate: AddGoalDelegate?
	
	// Змінна для збереження цілі, якщо ми в режимі редагування
	private var goalToEdit: Goal?
	
	// MARK: - Data Properties
	private var currentCurrency: String = "UAH"
	private var currentFrequency: ContributionFrequency = .daily

	// MARK: - UI Elements
	
	private let scrollView = UIScrollView()
	private let contentView = UIView()
	
	private let stackView: UIStackView = {
		let stack = UIStackView()
		stack.axis = .vertical
		stack.spacing = 20
		stack.translatesAutoresizingMaskIntoConstraints = false
		return stack
	}()
	
	// --- Поля вводу ---
	private lazy var titleField: UIView = {
		return createTextField(
			title: "add_goal_name_title".localized(),
			placeholder: "add_goal_name_placeholder".localized(),
			tag: 1
		)
	}()
	
	private lazy var descriptionField: UIView = {
		return createTextView(
			title: "add_goal_desc_title".localized(),
			placeholder: "add_goal_desc_placeholder".localized(),
			tag: 2
		)
	}()
	
	// --- Стек для Суми / Валюти ---
	private let amountStack: UIStackView = {
		let stack = UIStackView()
		stack.axis = .horizontal
		stack.distribution = .fillEqually
		stack.spacing = 16
		return stack
	}()
	
	private lazy var totalAmountField: UIView = {
		let field = createTextField(
			title: "add_goal_total_amount_title".localized(),
			placeholder: "0",
			keyboardType: .decimalPad,
			tag: 3
		)
		return field
	}()
	
	private lazy var currencyField: UIView = {
		let field = createTextField(
			title: "add_goal_currency_title".localized(),
			placeholder: currentCurrency, // Початкове значення
			isButton: true,
			tag: 4
		)
		field.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(openCurrencyPicker)))
		return field
	}()
	
	// --- Стек для Внеску / Частоти ---
	private let contributionStack: UIStackView = {
		let stack = UIStackView()
		stack.axis = .horizontal
		stack.distribution = .fillEqually
		stack.spacing = 16
		return stack
	}()
	
	private lazy var contributionAmountField: UIView = {
		let field = createTextField(
			title: "add_goal_contribution_amount_title".localized(),
			placeholder: "0",
			keyboardType: .decimalPad,
			tag: 5
		)
		return field
	}()
	
	private lazy var frequencyControl: UISegmentedControl = {
		let items = ContributionFrequency.allCases.map { $0.localizedTitle }
		
		let control = UISegmentedControl(items: items)
		control.selectedSegmentIndex = 0 // .daily
		control.addTarget(self, action: #selector(frequencyChanged), for: .valueChanged)
		return control
	}()
	
	private lazy var frequencyField: UIView = {
		return createTitledView(title: "add_goal_frequency_title".localized(), view: frequencyControl)
	}()
	
	// --- Інфо-блок ---
	private lazy var infoBox: UIView = {
		let view = UIView()
		view.backgroundColor = .systemYellow.withAlphaComponent(0.1)
		view.layer.cornerRadius = 12
		
		let icon = UIImageView(image: UIImage(systemName: "lightbulb.fill"))
		icon.tintColor = .systemYellow
		
		let label = UILabel()
		label.text = "add_goal_infobox_text".localized()
		label.font = .systemFont(ofSize: 14)
		label.textColor = .secondaryLabel
		label.numberOfLines = 0
		
		view.addSubview(icon)
		view.addSubview(label)
		icon.translatesAutoresizingMaskIntoConstraints = false
		label.translatesAutoresizingMaskIntoConstraints = false
		
		NSLayoutConstraint.activate([
			icon.topAnchor.constraint(equalTo: view.topAnchor, constant: 16),
			icon.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
			icon.widthAnchor.constraint(equalToConstant: 20),
			
			label.topAnchor.constraint(equalTo: icon.topAnchor, constant: 2),
			label.leadingAnchor.constraint(equalTo: icon.trailingAnchor, constant: 12),
			label.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
			label.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -16)
		])
		
		return view
	}()

	// MARK: - Init
	
	// Оновлений ініціалізатор, що приймає необов'язкову ціль для редагування
	init(goalToEdit: Goal? = nil) {
		self.goalToEdit = goalToEdit
		super.init(nibName: nil, bundle: nil)
		
		// Якщо ми редагуємо, одразу підтягуємо налаштування
		if let goal = goalToEdit {
			self.currentCurrency = goal.currency
			self.currentFrequency = goal.contributionFrequency
		}
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	// MARK: - Lifecycle
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		setupUI()
		setupLayout()
		prefillDataIfEditing() // Заповнюємо поля, якщо це редагування
		
		// Жест для закриття клавіатури
		let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
		view.addGestureRecognizer(tap)
	}
	
	// MARK: - Setup UI
	
	private func setupUI() {
		view.backgroundColor = .systemGroupedBackground
		
		// Змінюємо заголовок залежно від режиму
		if goalToEdit != nil {
			title = "Редагування мети" // TODO: Локалізувати
		} else {
			title = "add_goal_title".localized()
		}
		
		navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelTapped))
		navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveTapped))
		
		scrollView.translatesAutoresizingMaskIntoConstraints = false
		contentView.translatesAutoresizingMaskIntoConstraints = false
		view.addSubview(scrollView)
		scrollView.addSubview(contentView)
		
		contentView.addSubview(stackView)
		
		amountStack.addArrangedSubview(totalAmountField)
		amountStack.addArrangedSubview(currencyField)
		
		contributionStack.addArrangedSubview(contributionAmountField)
		contributionStack.addArrangedSubview(frequencyField)
		
		stackView.addArrangedSubview(titleField)
		stackView.addArrangedSubview(descriptionField)
		stackView.addArrangedSubview(amountStack)
		stackView.addArrangedSubview(contributionStack)
		stackView.addArrangedSubview(infoBox)
		
		updateCurrencyField(text: currentCurrency)
	}
	
	private func setupLayout() {
		NSLayoutConstraint.activate([
			scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
			scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
			scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
			scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
			
			contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
			contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
			contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
			contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
			contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
			
			stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
			stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20),
			stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
			stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
		])
	}
	
	// MARK: - Prefill Data (Editing Mode)
	
	private func prefillDataIfEditing() {
		guard let goal = goalToEdit else { return }
		
		// 1. Назва
		if let textField = titleField.viewWithTag(1) as? UITextField {
			textField.text = goal.title
		}
		
		// 2. Опис
		if let textView = descriptionField.viewWithTag(2) as? UITextView,
		   let desc = goal.description, !desc.isEmpty {
			textView.text = desc
			textView.textColor = .label
		}
		
		// Форматер для чисел (щоб не показувати 5000.0 як 5000)
		let formatter = NumberFormatter()
		formatter.minimumFractionDigits = 0
		formatter.maximumFractionDigits = 2
		
		// 3. Загальна сума
		if let textField = totalAmountField.viewWithTag(3) as? UITextField {
			textField.text = formatter.string(from: NSNumber(value: goal.totalAmount))
		}
		
		// 4. Сума внеску
		if let textField = contributionAmountField.viewWithTag(5) as? UITextField {
			textField.text = formatter.string(from: NSNumber(value: goal.contributionAmount))
		}
		
		// 5. Частота
		if let index = ContributionFrequency.allCases.firstIndex(of: goal.contributionFrequency) {
			frequencyControl.selectedSegmentIndex = index
		}
		
		// Валюта вже встановлена в init()
	}
	
	// MARK: - Actions
	
	@objc private func cancelTapped() {
		dismiss(animated: true, completion: nil)
	}
	
	@objc private func saveTapped() {
		// Отримуємо дані з полів по тегам
		guard let title = (titleField.viewWithTag(1) as? UITextField)?.text,
			  let descriptionText = (descriptionField.viewWithTag(2) as? UITextView)?.text,
			  let totalAmountText = (totalAmountField.viewWithTag(3) as? UITextField)?.text,
			  let contributionAmountText = (contributionAmountField.viewWithTag(5) as? UITextField)?.text
		else {
			showError(message: "error_unknown".localized())
			return
		}
		
		// Конвертуємо числа (заміна коми на крапку)
		let totalAmount = Double(totalAmountText.replacingOccurrences(of: ",", with: ".")) ?? 0.0
		let contributionAmount = Double(contributionAmountText.replacingOccurrences(of: ",", with: ".")) ?? 0.0
		
		let finalDescription = (descriptionText.isEmpty || descriptionText == "add_goal_desc_placeholder".localized()) ? nil : descriptionText

		// --- ЛОГІКА ЗБЕРЕЖЕННЯ ---
		
		if let existingGoal = goalToEdit {
			// 1. РЕДАГУВАННЯ
			// Ми створюємо нову структуру Goal, але обов'язково передаємо старий ID, дату створення
			// та переносимо історію внесків
			
			let updatedGoal = Goal(
				id: existingGoal.id,         // <-- ВАЖЛИВО: Зберігаємо старий ID
				title: title,
				description: finalDescription,
				currency: currentCurrency,
				totalAmount: totalAmount,
				contributionAmount: contributionAmount,
				contributionFrequency: currentFrequency,
				createdDate: existingGoal.createdDate // <-- ВАЖЛИВО: Зберігаємо дату створення
			)
			
			if var finalGoal = updatedGoal {
				// Відновлюємо історію
				finalGoal.contributions = existingGoal.contributions
				finalGoal.currentAmount = existingGoal.currentAmount
				
				delegate?.didUpdateGoal(finalGoal)
				dismiss(animated: true)
			} else {
				showError(message: "error_validation_failed".localized())
			}
			
		} else {
			// 2. СТВОРЕННЯ НОВОЇ
			let newGoal = Goal(
				title: title,
				description: finalDescription,
				currency: currentCurrency,
				totalAmount: totalAmount,
				contributionAmount: contributionAmount,
				contributionFrequency: currentFrequency
			)
			
			if let goal = newGoal {
				delegate?.didCreateGoal(goal)
				dismiss(animated: true)
			} else {
				showError(message: "error_validation_failed".localized())
			}
		}
	}
	
	@objc private func frequencyChanged(_ sender: UISegmentedControl) {
		currentFrequency = ContributionFrequency.allCases[sender.selectedSegmentIndex]
	}
	
	@objc private func openCurrencyPicker() {
		let pickerVC = CurrencyPickerViewController(currentCurrency: currentCurrency)
		pickerVC.delegate = self
		navigationController?.pushViewController(pickerVC, animated: true)
	}
	
	@objc private func dismissKeyboard() {
		view.endEditing(true)
	}
	
	// MARK: - CurrencyPickerDelegate
	
	func didSelectCurrency(_ currency: String) {
		currentCurrency = currency
		updateCurrencyField(text: currency)
	}
	
	// MARK: - Helpers
	
	private func updateCurrencyField(text: String) {
		if let currencyLabel = currencyField.viewWithTag(4) as? PaddedLabel {
			currencyLabel.text = text
			currencyLabel.textColor = .label
		} else if let currencyLabel = currencyField.viewWithTag(4) as? UILabel {
			 // Fallback if PaddedLabel casting fails or view structure differs slightly
			 currencyLabel.text = text
			 currencyLabel.textColor = .label
		}
	}
	
	private func showError(message: String) {
		let alert = UIAlertController(title: "error_title".localized(), message: message, preferredStyle: .alert)
		alert.addAction(UIAlertAction(title: "alert_ok".localized(), style: .default, handler: nil))
		present(alert, animated: true)
	}
	
	// ---- UI Helper для створення полів вводу ----
	
	private func createTitledView(title: String, view: UIView) -> UIView {
		let container = UIStackView()
		container.axis = .vertical
		container.spacing = 8
		
		let titleLabel = UILabel()
		titleLabel.text = title
		titleLabel.font = .systemFont(ofSize: 14, weight: .medium)
		titleLabel.textColor = .secondaryLabel
		
		container.addArrangedSubview(titleLabel)
		container.addArrangedSubview(view)
		return container
	}
	
	// Додав параметр 'tag' для зручного доступу
	private func createTextField(title: String, placeholder: String, keyboardType: UIKeyboardType = .default, isButton: Bool = false, tag: Int) -> UIView {
		
		let textField = UITextField()
		textField.placeholder = placeholder
		textField.font = .systemFont(ofSize: 16)
		textField.keyboardType = keyboardType
		textField.backgroundColor = .secondarySystemGroupedBackground
		textField.borderStyle = .none
		textField.layer.cornerRadius = 10
		textField.tag = tag // <-- Tag
		
		textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: 0))
		textField.leftViewMode = .always
		
		// Використовуємо PaddedLabel для кнопки валюти
		let paddedLabel = PaddedLabel(with: UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 30))
		paddedLabel.text = placeholder
		paddedLabel.font = .systemFont(ofSize: 16)
		paddedLabel.textColor = .placeholderText
		paddedLabel.backgroundColor = .secondarySystemGroupedBackground
		paddedLabel.layer.cornerRadius = 10
		paddedLabel.clipsToBounds = true
		paddedLabel.isUserInteractionEnabled = true
		paddedLabel.tag = tag // <-- Tag
		
		let icon = UIImageView(image: UIImage(systemName: "chevron.right"))
		icon.tintColor = .secondaryLabel
		icon.translatesAutoresizingMaskIntoConstraints = false
		
		// Вирішуємо, чи це кнопка (PaddedLabel) чи звичайне поле (UITextField)
		let fieldView: UIView = isButton ? paddedLabel : textField
		
		fieldView.heightAnchor.constraint(equalToConstant: 48).isActive = true
		
		if isButton {
			// Додаємо іконку в PaddedLabel
			fieldView.addSubview(icon)
			NSLayoutConstraint.activate([
				icon.trailingAnchor.constraint(equalTo: fieldView.trailingAnchor, constant: -12),
				icon.centerYAnchor.constraint(equalTo: fieldView.centerYAnchor)
			])
		}
		
		return createTitledView(title: title, view: fieldView)
	}
	
	private func createTextView(title: String, placeholder: String, tag: Int) -> UIView {
		let textView = UITextView()
		textView.text = placeholder
		textView.font = .systemFont(ofSize: 16)
		textView.textColor = .placeholderText
		textView.backgroundColor = .secondarySystemGroupedBackground
		textView.layer.cornerRadius = 10
		textView.tag = tag // <-- Tag
		textView.delegate = self
		
		textView.textContainerInset = UIEdgeInsets(top: 12, left: 8, bottom: 12, right: 8)
		
		textView.heightAnchor.constraint(equalToConstant: 100).isActive = true
		
		return createTitledView(title: title, view: textView)
	}
	
	// --- UITextViewDelegate для плейсхолдера ---
	func textViewDidBeginEditing(_ textView: UITextView) {
		if textView.textColor == .placeholderText {
			textView.text = nil
			textView.textColor = .label
		}
	}
	
	func textViewDidEndEditing(_ textView: UITextView) {
		if textView.text.isEmpty {
			textView.text = "add_goal_desc_placeholder".localized()
			textView.textColor = .placeholderText
		}
	}
	
}

// MARK: - Helper Classes

// Допоміжний клас для лейбла з відступами (використовується для кнопки валюти)
private class PaddedLabel: UILabel {
	private var padding: UIEdgeInsets

	init(with padding: UIEdgeInsets) {
		self.padding = padding
		super.init(frame: .zero)
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func drawText(in rect: CGRect) {
		super.drawText(in: rect.inset(by: padding))
	}
	
	override var intrinsicContentSize: CGSize {
		let size = super.intrinsicContentSize
		return CGSize(width: size.width + padding.left + padding.right,
					  height: size.height + padding.top + padding.bottom)
	}
}
