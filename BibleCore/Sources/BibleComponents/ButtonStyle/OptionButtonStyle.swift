//
//  SwiftUIView.swift
//  
//
//  Created by Peter Larson on 9/12/23.
//

import SwiftUI

public struct OptionButtonStyle: ButtonStyle {
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 14))
            .fontWeight(.bold)
            .foregroundColor(.softBlack)
            .padding()
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
                                y: -4
                            )
                        )
                    )
            }
    }
}

public extension ButtonStyle where Self == OptionButtonStyle {
    static var option: OptionButtonStyle { OptionButtonStyle() }
}

struct OptionButtonStyle_Previews: PreviewProvider {
    static var previews: some View {
        Button("Word") {
            
        }
        .buttonStyle(.option)
    }
}
