import UIKit

class ContributionCell: UITableViewCell {
	
	// MARK: - UI Elements
	
	private let containerView: UIView = {
		let view = UIView()
		view.backgroundColor = .secondarySystemGroupedBackground // Темно-сірий фон картки
		view.layer.cornerRadius = 12
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()
	
	// Дата (маленька зверху)
	private let dateLabel: UILabel = {
		let label = UILabel()
		label.font = .systemFont(ofSize: 12, weight: .medium)
		label.textColor = .secondaryLabel // Сірий колір
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}()
	
	// Опис (основний текст)
	private let noteLabel: UILabel = {
		let label = UILabel()
		label.font = .systemFont(ofSize: 16, weight: .regular)
		label.textColor = .label // Білий колір
		label.numberOfLines = 1 // Або 2, якщо описи довгі
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}()
	
	// Сума (справа)
	private let amountLabel: UILabel = {
		let label = UILabel()
		label.font = .systemFont(ofSize: 18, weight: .bold)
		label.textColor = .systemYellow // Жовтий для акценту
		label.textAlignment = .right
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}()
	
	// MARK: - Init
	
	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		setupUI()
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	// MARK: - Setup
	
	private func setupUI() {
		backgroundColor = .clear
		selectionStyle = .none
		
		contentView.addSubview(containerView)
		containerView.addSubview(dateLabel)
		containerView.addSubview(noteLabel)
		containerView.addSubview(amountLabel)
		
		NSLayoutConstraint.activate([
			// Картка (відступи)
			containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6),
			containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6),
			containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 0), // Можна поставити 16, якщо хочете відступи збоку
			containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 0),
			
			// Сума (Справа по центру)
			amountLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
			amountLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
			// Встановлюємо ширину, щоб сума не стискалась, якщо текст довгий
			amountLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 80),
			
			// Дата (Зверху зліва)
			dateLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
			dateLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
			
			// Нотатка (Знизу зліва, під датою)
			noteLabel.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 4),
			noteLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
			noteLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -12),
			// Нотатка не має залазити на суму
			noteLabel.trailingAnchor.constraint(equalTo: amountLabel.leadingAnchor, constant: -12)
		])
	}
	
	// MARK: - Configuration
	
	func configure(with contribution: Contribution, currency: String) {
		// 1. Встановлюємо дату
		let formatter = DateFormatter()
		formatter.dateFormat = "d MMM yyyy" // Наприклад: "21 лист. 2025"
		dateLabel.text = formatter.string(from: contribution.date)
		
		// 2. Встановлюємо текст нотатки
		// Якщо нотатка пуста, пишемо щось дефолтне (хоча у нас тепер є авто-генерація)
		noteLabel.text = (contribution.note ?? "").isEmpty ? "Внесок" : (contribution.note ?? "")
		
		// 3. Встановлюємо суму
		// (Використовуємо форматер чисел, якщо він у вас є глобальний, або простий варіант)
		let amountString = String(format: "%.0f", contribution.amount) // Без копійок
		amountLabel.text = "+\(amountString) \(currency)"
	}
}

