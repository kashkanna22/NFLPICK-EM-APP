import Foundation

func formatGameDate(_ date: Date, calendar: Calendar = .current) -> String {
    let now = Date()
    let startOfToday = calendar.startOfDay(for: now)
    let startOfDate = calendar.startOfDay(for: date)
    
    let components = calendar.dateComponents([.day], from: startOfToday, to: startOfDate)
    guard let dayDifference = components.day else {
        return formattedWeekdayTime(date: date, calendar: calendar)
    }
    
    if dayDifference == 0 {
        return "Today"
    } else if dayDifference == 1 {
        return "Tomorrow"
    } else {
        return formattedWeekdayTime(date: date, calendar: calendar)
    }
}

private func formattedWeekdayTime(date: Date, calendar: Calendar) -> String {
    let formatter = DateFormatter()
    formatter.calendar = calendar
    formatter.locale = Locale.current
    formatter.dateFormat = "EE h:mm a"
    return formatter.string(from: date)
}
