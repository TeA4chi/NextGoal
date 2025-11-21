//
//  Goal.swift
//  NextGoal
//
//  Created by Олександр Чижик on 25.10.2025.
//

import Foundation

enum ContributionFrequency: String, CaseIterable, Codable {
	case daily
	case weekly
	case monthly

	var localizedTitle: String {
		switch self {
		case .daily: return "freq_daily".localized()
		case .weekly: return "freq_weekly".localized()
		case .monthly: return "freq_monthly".localized()
		}
	}
}

struct Goal: Codable {
	let id: UUID
	var title: String
	var description: String?
	var currency: String
	let totalAmount: Double
	var currentAmount: Double = 0.0
	let contributionAmount: Double
	let contributionFrequency: ContributionFrequency
	let createdDate: Date  // Added this property

	// Add the missing property
	var contributions: [Contribution] = []
	
	// --- Add this computed property for remaining amount ---
	var remainingAmount: Double {
		totalAmount - currentAmount
	}
	
	var equivalentDailyContribution: Double {
		switch contributionFrequency {
		case .daily: return contributionAmount
		case .weekly: return contributionAmount / 7.0
		case .monthly: return contributionAmount / (365.25 / 12.0)
		}
	}

	var daysRemaining: Int {
		let remainingAmount = totalAmount - currentAmount
		guard equivalentDailyContribution > 0 else { return 0 }
		return Int(ceil(remainingAmount / equivalentDailyContribution))
	}

	var progressPercentage: Double {
		guard totalAmount > 0 else { return 0.0 }
		return currentAmount / totalAmount
	}

	var formattedTimeRemaining: String {
		let days = self.daysRemaining

		switch self.contributionFrequency {
		case .daily:
			let format = NSLocalizedString("time_days", comment: "Time remaining in days")
			return String.localizedStringWithFormat(format, days)

		case .weekly:
			let weeks = Int(ceil(Double(days) / 7.0))
			let format = NSLocalizedString("time_weeks", comment: "Time remaining in weeks")
			return String.localizedStringWithFormat(format, weeks)

		case .monthly:
			let months = Int(ceil(Double(days) / (365.25 / 12.0)))
			let format = NSLocalizedString("time_months", comment: "Time remaining in months")
			return String.localizedStringWithFormat(format, months)
		}
	}

    // Add this mutating function for convenience (also required by your VC)
    mutating func addContribution(_ contribution: Contribution) {
        contributions.append(contribution)
        currentAmount += contribution.amount
    }

    // Computed property for expected completion date
    var expectedCompletionDate: Date {
        Calendar.current.date(byAdding: .day, value: daysRemaining, to: createdDate) ?? createdDate
    }

	init?(
		id: UUID = UUID(),
		title: String,
		description: String? = nil,
		currency: String,
		totalAmount: Double,
		contributionAmount: Double,
		contributionFrequency: ContributionFrequency,
		createdDate: Date = Date() // Added parameter with default value
	) {
		if title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty { return nil }
		if totalAmount <= 0 || contributionAmount <= 0 { return nil }

		self.id = id
		self.title = title
		self.description = description
		self.currency = currency
		self.totalAmount = totalAmount
		self.contributionAmount = contributionAmount
		self.contributionFrequency = contributionFrequency
		self.createdDate = createdDate
		// dailyContribution видалено - воно не потрібне!
	}
}

