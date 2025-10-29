import UIKit

class SettingsViewController: UIViewController {

	// MARK: - UI Elements
	
	// --- Елементи "Темна тема" ---
	private let containerView: UIView = {
		let view = UIView()
		view.backgroundColor = .secondarySystemGroupedBackground
		view.layer.cornerRadius = 10
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()
	
	private let darkModeLabel: UILabel = {
		let label = UILabel()
		label.text = "settings_dark_mode".localized()
		label.font = .systemFont(ofSize: 17)
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}()
	
	private let darkModeSwitch: UISwitch = {
		let uiSwitch = UISwitch()
		uiSwitch.translatesAutoresizingMaskIntoConstraints = false
		return uiSwitch
	}()

	// --- Елементи "Мова" ---
	private let languageContainerView: UIView = {
		let view = UIView()
		view.backgroundColor = .secondarySystemGroupedBackground
		view.layer.cornerRadius = 10
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()
	
	private let languageTitleLabel: UILabel = {
		let label = UILabel()
		label.text = "settings_language".localized()
		label.font = .systemFont(ofSize: 17)
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}()
	
	private let currentLanguageLabel: UILabel = {
		let label = UILabel()
		let currentLangCode = Locale.current.language.languageCode?.identifier ?? "en"
		let currentLangName = Locale.current.localizedString(forIdentifier: currentLangCode)
		label.text = currentLangName?.capitalized
		label.font = .systemFont(ofSize: 17, weight: .regular)
		label.textColor = .secondaryLabel
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}()
	
	private let languageAccessoryView: UIImageView = {
		let imageView = UIImageView(image: UIImage(systemName: "chevron.right"))
		imageView.tintColor = .secondaryLabel
		imageView.translatesAutoresizingMaskIntoConstraints = false
		return imageView
	}()

	// MARK: - Lifecycle
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		view.backgroundColor = .systemGroupedBackground
		title = "settings_title".localized()
		navigationController?.navigationBar.prefersLargeTitles = true
		
		darkModeSwitch.isOn = SettingsManager.shared.isDarkMode
		
		// Додаємо елементи на екран
		view.addSubview(containerView)
		containerView.addSubview(darkModeLabel)
		containerView.addSubview(darkModeSwitch)
		
		view.addSubview(languageContainerView)
		languageContainerView.addSubview(languageTitleLabel)
		languageContainerView.addSubview(currentLanguageLabel)
		languageContainerView.addSubview(languageAccessoryView)
		
		setupLayout()
		addActions()
	}
	
	// MARK: - Setup
	
	private func setupLayout() {
		NSLayoutConstraint.activate([
			// --- Контейнер теми ---
			containerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
			containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
			containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
			containerView.heightAnchor.constraint(equalToConstant: 50),
			
			darkModeLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
			darkModeLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
			
			darkModeSwitch.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
			darkModeSwitch.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
			
			// --- Контейнер мови ---
			// ОНОВЛЕНО: Тепер прив'язується до 'containerView', а не 'currencyContainerView'
			languageContainerView.topAnchor.constraint(equalTo: containerView.bottomAnchor, constant: 12),
			languageContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
			languageContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
			languageContainerView.heightAnchor.constraint(equalToConstant: 50),
			
			languageTitleLabel.leadingAnchor.constraint(equalTo: languageContainerView.leadingAnchor, constant: 16),
			languageTitleLabel.centerYAnchor.constraint(equalTo: languageContainerView.centerYAnchor),
			
			languageAccessoryView.trailingAnchor.constraint(equalTo: languageContainerView.trailingAnchor, constant: -16),
			languageAccessoryView.centerYAnchor.constraint(equalTo: languageContainerView.centerYAnchor),
			
			currentLanguageLabel.trailingAnchor.constraint(equalTo: languageAccessoryView.leadingAnchor, constant: -8),
			currentLanguageLabel.centerYAnchor.constraint(equalTo: languageContainerView.centerYAnchor)
		])
	}
	
	private func addActions() {
		darkModeSwitch.addTarget(self, action: #selector(darkModeSwitchChanged), for: .valueChanged)
		
		let langTapGesture = UITapGestureRecognizer(target: self, action: #selector(languageContainerTapped))
		languageContainerView.addGestureRecognizer(langTapGesture)
	}

	// MARK: - @objc Functions
	
	@objc private func darkModeSwitchChanged(_ sender: UISwitch) {
		let isDark = sender.isOn
		SettingsManager.shared.isDarkMode = isDark

		// Updated code to avoid deprecated 'windows'
		if let windowScenes = UIApplication.shared.connectedScenes as? Set<UIWindowScene> {
			for windowScene in windowScenes {
				for window in windowScene.windows {
					window.overrideUserInterfaceStyle = isDark ? .dark : .light
				}
			}
		}
	}
	
	// МИ ВИДАЛИЛИ 'currencyContainerTapped'
	
	@objc private func languageContainerTapped() {
		guard let settingsUrl = URL(string: UIApplication.openSettingsURLString),
			  UIApplication.shared.canOpenURL(settingsUrl) else {
			return
		}
		UIApplication.shared.open(settingsUrl, completionHandler: nil)
	}
}

// МИ ВИДАЛИЛИ 'extension SettingsViewController: CurrencySelectionDelegate'
