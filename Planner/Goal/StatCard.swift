import UIKit

final class StatCard: UIView {
	private let titleLabel: UILabel = {
		let label = UILabel()
		label.font = .systemFont(ofSize: 13, weight: .medium)
		label.textColor = .secondaryLabel
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}()
	
	private let valueLabel: UILabel = {
		let label = UILabel()
		label.font = .systemFont(ofSize: 20, weight: .bold)
		label.textColor = .label
		label.translatesAutoresizingMaskIntoConstraints = false
		label.numberOfLines = 1
		return label
	}()
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		setupUI()
	}
	
	required init?(coder: NSCoder) {
		super.init(coder: coder)
		setupUI()
	}
	
	private func setupUI() {
		backgroundColor = .secondarySystemGroupedBackground
		layer.cornerRadius = 14
		layer.masksToBounds = true
		
		addSubview(titleLabel)
		addSubview(valueLabel)
		
		NSLayoutConstraint.activate([
			titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 16),
			titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
			titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
			
			valueLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
			valueLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
			valueLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
			valueLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16)
		])
	}
	
	func configure(title: String, value: String) {
		titleLabel.text = title
		valueLabel.text = value
	}
}
