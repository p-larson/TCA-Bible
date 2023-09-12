import SwiftUI

public struct DisabledButtonStyle: ButtonStyle {
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .kerning(0.5)
            .textCase(.uppercase)
            .font(.system(size: 14))
            .fontWeight(.bold)
            .foregroundColor(.softBlack)
            .frame(height: 50)
            .frame(maxWidth: .infinity)
            .background {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(
                        Color.softGray
                    )
            }
            .disabled(true)
    }
}

public extension ButtonStyle where Self == DisabledButtonStyle {
    static var disabled: DisabledButtonStyle { DisabledButtonStyle() }
}

public struct DisabledButtonStylePreviews: PreviewProvider {
    public static var previews: some View {
        Button("disabled") {
            
        }
        .buttonStyle(.disabled)
    }
}
