import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
	
	var window: UIWindow?
	
	func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
		
		guard let windowScene = (scene as? UIWindowScene) else { return }
		let window = UIWindow(windowScene: windowScene)
		window.overrideUserInterfaceStyle = SettingsManager.shared.isDarkMode ? .dark : .light
		
		let tabBarController = UITabBarController()
		
		// --- Створюємо екрани ---
		let plannerVC = PlannerViewController()
		let mapVC = MapViewController()
		let insightsVC = InsightsViewController()
		let settingsVC = SettingsViewController()
		
		
		// "Загортаємо" екрани, яким потрібен заголовок, у Navigation Controller
		let plannerNav = UINavigationController(rootViewController: plannerVC)
		let settingsNav = UINavigationController(rootViewController: settingsVC)
		// ------------------------------------------
		
		// Налаштовуємо іконки і назви
		plannerNav.tabBarItem = UITabBarItem(title: "tab_planner".localized(),
											 image: UIImage(systemName: "folder"),
											 selectedImage: UIImage(systemName: "folder.fill"))
		
		mapVC.tabBarItem = UITabBarItem(title: "tab_map".localized(),
										image: UIImage(systemName: "map"),
										selectedImage: UIImage(systemName: "map.fill"))
		
		insightsVC.tabBarItem = UITabBarItem(title: "tab_insights".localized(),
											 image: UIImage(systemName: "chart.bar"),
											 selectedImage: UIImage(systemName: "chart.bar.fill"))
		
		settingsNav.tabBarItem = UITabBarItem(title: "settings_title".localized(),
											  image: UIImage(systemName: "gearshape"),
											  selectedImage: UIImage(systemName: "gearshape.fill"))
		
		tabBarController.tabBar.tintColor = .systemYellow
		
		// "Запаковуємо" в меню оновлені екрани
		tabBarController.viewControllers = [plannerNav, mapVC, insightsVC, settingsNav]
		// ------------------------------------------
		
		window.rootViewController = tabBarController
		
		self.window = window
		window.makeKeyAndVisible()
	}
}
