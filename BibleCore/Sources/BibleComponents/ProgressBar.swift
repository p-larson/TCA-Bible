import SwiftUI

public struct ProgressBar: View {
    
    private let progress: Double
    
    public init(progress: Double) {
        self.progress = progress
    }
    
    public var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.softGray)
            GeometryReader { proxy in
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.correctGreen)
                    .frame(width: (proxy.size.width - 32) * progress + 32)
//                RoundedRectangle(cornerRadius: 16)
//                    .fill(Color.white.opacity(1/10))
//                    .frame(width: (proxy.size.width - 32) * progress + 16)
//                    .frame(height: 8)
//                    .offset(x: 8, y: 2)
            }
        }
        .frame(minWidth: 48)
        .frame(height: 16)
    }
}

struct ProgressBar_Previews: PreviewProvider {
    static var previews: some View {
        ProgressBar(progress: 1.0)
            .padding()
    }
}
