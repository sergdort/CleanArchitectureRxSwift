import SwiftUI

public struct BorderedButton: View {
  public let isSelected: Bool
  public let text: String
  public let systemImageName: String
  public let color: Color
  public let action: () -> Void

  @Environment(\.isEnabled) var isEnabled

  public init(
    isSelected: Bool,
    text: String,
    systemImageName: String,
    color: Color,
    action: @escaping () -> Void
  ) {
    self.isSelected = isSelected
    self.text = text
    self.systemImageName = systemImageName
    self.color = color
    self.action = action
  }

  public var body: some View {
    Button(action: {
      self.action()
    }, label: {
      HStack(alignment: .center, spacing: 4) {
        Image(systemName: systemImageName)
          .foregroundColor(isSelected ? .white : color)
        Text(text)
          .foregroundColor(isSelected ? .white : color)
      }
      .font(.caption)
    })
    .buttonStyle(
      BorderedButtonStyle(color: color, isSelected: isSelected)
    )
  }
}

struct BorderedButtonStyle: ButtonStyle {
  var color: Color
  var isSelected: Bool

  func makeBody(configuration: Configuration) -> some View {
    configuration.label
      .padding(4)
      .foregroundStyle(isSelected ? .red : color)
      .background(
        RoundedRectangle(cornerRadius: 8)
          .stroke(color, lineWidth: isSelected ? 0 : 2)
          .background(isSelected ? color : .clear)
          .cornerRadius(8)
      )
  }
}

#Preview {
  BorderedButton(isSelected: false, text: "Seenlist", systemImageName: "eye", color: .green, action: {})
  BorderedButton(isSelected: true, text: "Seenlist", systemImageName: "eye", color: .green, action: {})
}
