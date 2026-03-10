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

    static func time(_ date: Date) -> String {
        timeFormatter.string(from: date)
    }

    static func dayTime(_ date: Date) -> String {
        dayTimeFormatter.string(from: date)
    }

    static func duration(minutes: Int) -> String {
        let hours = minutes / 60
        let mins = minutes % 60
        if hours > 0 && mins > 0 { return "\(hours) h \(mins) min" }
        if hours > 0 { return "\(hours) h" }
        return "\(mins) min"
    }
}

