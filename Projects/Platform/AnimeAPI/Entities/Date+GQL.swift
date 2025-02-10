import Foundation

extension FuzzyDateFragmet {
    var date: Date? {
        guard let year = self.year, let month = self.month, let day = self.day else {
            return nil
        }
        return Calendar.current.date(
            from: DateComponents(
                year: year,
                month: month,
                day: day
            )
        )
    }
}
