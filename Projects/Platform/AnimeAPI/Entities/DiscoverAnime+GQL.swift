import AnimeDomain
import Apollo
import Foundation

extension DiscoverMedia {
  init(media: GQLDiscoverMedia) {
    let startDate = media.startDate?.fragments.fuzzyDateFragmet.date
    let endDate = media.endDate?.fragments.fuzzyDateFragmet.date

    self.init(
      id: media.id,
      startDate: startDate,
      endDate: endDate,
      coverImageURL: media.coverImage?.large.flatMap(URL.init(string:)),
      title: media.title?.english ?? "",
      description: media.description ?? "",
      averageScore: media.averageScore ?? 0
    )
  }
}

extension Calendar {
  func date(from fuzzyDate: FuzzyDateFragmet) -> Date? {
    guard let year = fuzzyDate.year, let month = fuzzyDate.month, let day = fuzzyDate.day else {
      return nil
    }
    return self.date(from: DateComponents(year: year, month: month, day: day))
  }
}
