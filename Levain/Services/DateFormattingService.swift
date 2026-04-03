import Foundation

enum DateFormattingService {
    private static let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "it_IT")
        formatter.dateFormat = "HH:mm"
        return formatter
    }()

    private static let dayTimeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "it_IT")
        formatter.dateFormat = "EEE d MMM · HH:mm"
        return formatter
    }()

    private static let shortDayTimeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "it_IT")
        formatter.dateFormat = "d MMM · HH:mm"
        return formatter
    }()

    private static let dayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "it_IT")
        formatter.dateFormat = "EEEE d MMM"
        return formatter
    }()

    static func time(_ date: Date) -> String {
        timeFormatter.string(from: date)
    }

    static func dayTime(_ date: Date) -> String {
        dayTimeFormatter.string(from: date)
    }

    /// Mostra solo HH:mm se la data è oggi, altrimenti "d MMM · HH:mm" (senza abbreviazione giorno)
    static func smartDayTime(_ date: Date) -> String {
        if Calendar.current.isDateInToday(date) {
            return timeFormatter.string(from: date)
        }
        return shortDayTimeFormatter.string(from: date)
    }

    static func day(_ date: Date) -> String {
        dayFormatter.string(from: date).capitalized(with: Locale(identifier: "it_IT"))
    }

    static func duration(minutes: Int) -> String {
        let hours = minutes / 60
        let mins = minutes % 60
        if hours > 0 && mins > 0 { return "\(hours) h \(mins) min" }
        if hours > 0 { return "\(hours) h" }
        return "\(mins) min"
    }
}
