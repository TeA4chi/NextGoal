//
//  CurrencyPickerViewViewController.swift
//  NextGoal
//
//  Created by Олександр Чижик on 29.10.2025.
//

import UIKit

protocol CurrencyPickerDelegate: AnyObject {
	func didSelectCurrency(_ currency: String)
}

class CurrencyPickerViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return currencies.count
	}
	
	
	weak var delegate: CurrencyPickerDelegate?
	
	private let tableView = UITableView(frame: .zero, style: .insetGrouped)
	private let currencies = ["UAH", "USD", "EUR"]
	private var	currentCurrency: String
	
	init(currentCurrency: String) {
		self.currentCurrency = currentCurrency
		super.init(nibName: nil, bundle: nil)
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		title = "currency_picker_title".localized()
		view.backgroundColor = .systemGroupedBackground
		setupTableView()
	}
	
	private func setupTableView() {
		view.addSubview(tableView)
		tableView.dataSource = self
		tableView.delegate = self
		tableView.frame = view.bounds
		tableView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
		tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
	}
	
	//MARK: -UITableViewDataSource
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
		let currency = currencies[indexPath.row]
		cell.textLabel?.text = currency
		
		//галочка на поточку валюту
		cell.accessoryType = (currency == currentCurrency) ? .checkmark : .none
		return cell
	}
	
	//MARK: - UITableViewDelegate
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let selectedCurrency = currencies[indexPath.row]
		currentCurrency = selectedCurrency
		
		//повідомлення про вибір
		delegate?.didSelectCurrency(selectedCurrency)
		
		//оновлення таблиці щоб галочки перемалювались
		tableView.reloadData()
		
		//повернення на попередній екран
		navigationController?.popViewController(animated: true)
	}
	
	
}

