import SwiftUI

public struct MediaButtonsRow: View {
  var isWatchlistSelected: Bool
  var isSeenlistSelected: Bool
  var isListSelected: Bool
  
  var didTapWatchlist: () -> Void
  var didTapSeenlist: () -> Void
  var didTapList: () -> Void
  
  public init(
    isWatchlistSelected: Bool,
    isSeenlistSelected: Bool,
    isListSelected: Bool,
    didTapWatchlist: @escaping () -> Void,
    didTapSeenlist: @escaping () -> Void,
    didTapList: @escaping () -> Void
  ) {
    self.isWatchlistSelected = isWatchlistSelected
    self.isSeenlistSelected = isSeenlistSelected
    self.isListSelected = isListSelected
    self.didTapWatchlist = didTapWatchlist
    self.didTapSeenlist = didTapSeenlist
    self.didTapList = didTapList
  }

  public var body: some View {
    HStack {
      BorderedButton(
        isSelected: isWatchlistSelected,
        text: isWatchlistSelected ? "In Watchlist" : "Watchlist",
        systemImageName: "heart",
        color: .pink,
        action: didTapWatchlist
      )
      BorderedButton(
        isSelected: isSeenlistSelected,
        text: isSeenlistSelected ? "Seen" : "Seenlist",
        systemImageName: "eye",
        color: .orange,
        action: didTapSeenlist
      )
      BorderedButton(
        isSelected: isListSelected,
        text: "List",
        systemImageName: "pin",
        color: .indigo,
        action: didTapList
      )
    }
    .padding([.top, .bottom], 4)
    .font(.callout)
  }
}
