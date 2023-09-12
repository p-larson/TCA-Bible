import SwiftUI

public struct UnselecedButtonStyle: ButtonStyle {
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .offset(y: configuration.isPressed ? 0 : -4)
            .font(.system(size: 14))
            .fontWeight(.bold)
            .foregroundColor(.softBlack)
            .frame(height: 50)
            .frame(maxWidth: .infinity)
            .overlay {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(lineWidth: 2.5)
                    .foregroundColor(.softGray)
            }
            .background {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(
                        Color.white.shadow(
                            ShadowStyle.inner(
                                color: .softGray,
                                radius: 0,
                                x: 0,
                                y: configuration.isPressed ? 0 : -4
                            )
                        )
                    )
            }
    }
}

public extension ButtonStyle where Self == UnselecedButtonStyle {
    static var unselected: UnselecedButtonStyle { UnselecedButtonStyle() }
}


