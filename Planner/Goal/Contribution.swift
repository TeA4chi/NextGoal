import Foundation

struct Contribution: Codable {
    let amount: Double
    let date: Date
    let note: String?

    init(amount: Double, date: Date = Date(), note: String? = nil) {
        self.amount = amount
        self.date = date
        self.note = note
    }
}
