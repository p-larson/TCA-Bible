import SwiftUI

public struct CorrectButtonStyle: ButtonStyle {
    
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .kerning(0.5)
            .textCase(.uppercase)
            .offset(y: configuration.isPressed ? 0 : -4)
            .font(.system(size: 14))
            .fontWeight(.bold)
            .foregroundColor(.white)
            .frame(height: 50)
            .frame(maxWidth: .infinity)
            .background {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(
                        Color.correctGreen.shadow(
                            ShadowStyle.inner(
                                color: .darkGreen,
                                radius: 0,
                                x: 0,
                                y: configuration.isPressed ? 0 : -4
                            )
                        )
                    )
            }
    }
}

public extension ButtonStyle where Self == CorrectButtonStyle {
    static var correct: CorrectButtonStyle { CorrectButtonStyle() }
}

struct BibleButton_Previews: PreviewProvider {
    static var previews: some View {
        Button("Correct") {
            
        }
        .buttonStyle(.correct)
    }
}
