import SwiftUI

public struct PopularityBadge: View {
    public let score: Int
    
    @State private var isDisplayed = false
    
    public init(score: Int) {
        self.score = score
    }
    
    var scoreColor: Color {
        if score < 40 {
            return .red
        } else if score < 60 {
            return .orange
        } else if score < 75 {
            return .yellow
        }
        return .green
    }
    
    var overlay: some View {
        ZStack {
            Circle()
                .trim(from: 0,
                      to: isDisplayed ? CGFloat(score) / 100 : 0)
                .stroke(style: StrokeStyle(lineWidth: 2, dash: [1]))
                .foregroundColor(scoreColor)
        }
        .rotationEffect(.degrees(-90))
        .onAppear {
            withAnimation {
                self.isDisplayed = true
            }
        }
    }
    
    public var body: some View {
        ZStack {
            Circle()
                .foregroundColor(.clear)
                .frame(width: 40)
                .overlay(overlay)
                .shadow(color: scoreColor, radius: 4)
            Text("\(score)%")
                .font(Font.system(size: 10))
                .fontWeight(.bold)
        }
        .frame(width: 40, height: 40)
    }
}

#Preview {
    HStack {
        PopularityBadge(score: 35)
        PopularityBadge(score: 50)
        PopularityBadge(score: 70)
        PopularityBadge(score: 90)
    }
}
