import UIKit

// Протокол, який повідомить PlannerViewController, що ми вибрали
protocol AddMenuDelegate: AnyObject {
	func didSelectAddGoal()
	func didSelectAddDebtor()
}

class AddMenuViewController: UIViewController {

	weak var delegate: AddMenuDelegate?

	// MARK: - UI Elements
	
	private let titleLabel: UILabel = {
		let label = UILabel()
		label.text = "Що додати?" // TODO: Локалізувати
		label.font = .systemFont(ofSize: 28, weight: .bold)
		label.textColor = .label
		label.textAlignment = .center
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}()
	
	private lazy var addGoalButton: UIView = {
		let view = createMenuButton(
			iconName: "target",
			title: "Додати мету", // TODO: Локалізувати
			subtitle: "Створити нову ціль заощаджень" // TODO: Локалізувати
		)
		// Додаємо дію
		let tap = UITapGestureRecognizer(target: self, action: #selector(didTapAddGoal))
		view.addGestureRecognizer(tap)
		return view
	}()
	
	private lazy var addDebtorButton: UIView = {
		let view = createMenuButton(
			iconName: "person.crop.circle.badge.plus",
			title: "Додати боржника", // TODO: Локалізувати
			subtitle: "Записати кому позичили гроші" // TODO: Локалізувати
		)
		let tap = UITapGestureRecognizer(target: self, action: #selector(didTapAddDebtor))
		view.addGestureRecognizer(tap)
		return view
	}()

	// MARK: - Lifecycle
	
	override func viewDidLoad() {
		super.viewDidLoad()
		view.backgroundColor = .systemGroupedBackground
		setupViews()
	}
	
	// MARK: - Setup
	
	private func setupViews() {
		view.addSubview(titleLabel)
		view.addSubview(addGoalButton)
		view.addSubview(addDebtorButton)
		
		NSLayoutConstraint.activate([
			titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32),
			titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
			titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
			
			addGoalButton.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 32),
			addGoalButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
			addGoalButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
			addGoalButton.heightAnchor.constraint(equalToConstant: 80), // Висота кнопки
			
			addDebtorButton.topAnchor.constraint(equalTo: addGoalButton.bottomAnchor, constant: 16),
			addDebtorButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
			addDebtorButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
			addDebtorButton.heightAnchor.constraint(equalToConstant: 80)
		])
	}
	
	// MARK: - @objc Actions
	
	@objc private func didTapAddGoal() {
		delegate?.didSelectAddGoal()
	}
	
	@objc private func didTapAddDebtor() {
		delegate?.didSelectAddDebtor()
	}
	
	// MARK: - Helper Function
	
	// Допоміжна функція для створення кнопок, як на скріншоті
	private func createMenuButton(iconName: String, title: String, subtitle: String) -> UIView {
		let container = UIView()
		container.backgroundColor = .secondarySystemGroupedBackground
		container.layer.cornerRadius = 16
		container.translatesAutoresizingMaskIntoConstraints = false
		
		let iconContainer = UIView()
		iconContainer.backgroundColor = .systemYellow.withAlphaComponent(0.2)
		iconContainer.layer.cornerRadius = 10
		iconContainer.translatesAutoresizingMaskIntoConstraints = false
		
		let icon = UIImageView(image: UIImage(systemName: iconName))
		icon.tintColor = .systemYellow
		icon.contentMode = .scaleAspectFit
		icon.translatesAutoresizingMaskIntoConstraints = false
		
		let titleLabel = UILabel()
		titleLabel.text = title
		titleLabel.font = .systemFont(ofSize: 17, weight: .semibold)
		titleLabel.textColor = .label
		
		let subtitleLabel = UILabel()
		subtitleLabel.text = subtitle
		subtitleLabel.font = .systemFont(ofSize: 14)
		subtitleLabel.textColor = .secondaryLabel
		
		let vStack = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
		vStack.axis = .vertical
		vStack.spacing = 2
		vStack.translatesAutoresizingMaskIntoConstraints = false
		
		container.addSubview(iconContainer)
		iconContainer.addSubview(icon)
		container.addSubview(vStack)
		
		NSLayoutConstraint.activate([
			iconContainer.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
			iconContainer.centerYAnchor.constraint(equalTo: container.centerYAnchor),
			iconContainer.widthAnchor.constraint(equalToConstant: 50),
			iconContainer.heightAnchor.constraint(equalToConstant: 50),
			
			icon.centerXAnchor.constraint(equalTo: iconContainer.centerXAnchor),
			icon.centerYAnchor.constraint(equalTo: iconContainer.centerYAnchor),
			icon.widthAnchor.constraint(equalToConstant: 28),
			icon.heightAnchor.constraint(equalToConstant: 28),
			
			vStack.leadingAnchor.constraint(equalTo: iconContainer.trailingAnchor, constant: 16),
			vStack.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
			vStack.centerYAnchor.constraint(equalTo: container.centerYAnchor)
		])
		
		return container
	}
}
