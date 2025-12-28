import Foundation
import SwiftUI

enum Data {

    static let applink = URL(string: "https://apps.apple.com/app/id6757127481")!
    static let terms = URL(string: "https://docs.google.com/document/d/e/2PACX-1vRATkJ4UgmfywpuXGKkrZ9oXPZMYflqDeYxXPC70-OICkwLPhCg4Xu9WaOOfqsJsmU--T-Z7xZ-Gd4c/pub")!
    static let policy = URL(string: "https://docs.google.com/document/d/e/2PACX-1vRATkJ4UgmfywpuXGKkrZ9oXPZMYflqDeYxXPC70-OICkwLPhCg4Xu9WaOOfqsJsmU--T-Z7xZ-Gd4c/pub")!

    static var shareMessage: String {
        """
        Track Your Income, Take Control!
        \(applink.absoluteString)
        """
    }

    static var shareItems: [Any] { [shareMessage, applink] }
}

enum Device {
    static var isSmall: Bool {
        UIScreen.main.bounds.height < 700
    }

    static var isMedium: Bool {
        UIScreen.main.bounds.height >= 700 && UIScreen.main.bounds.height < 850
    }

    static var isLarge: Bool {
        UIScreen.main.bounds.height >= 850
    }
}

extension Color {
    init(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")

        var rgb: UInt64 = 0
        Scanner(string: hexSanitized).scanHexInt64(&rgb)

        let r = Double((rgb >> 16) & 0xFF) / 255.0
        let g = Double((rgb >> 8) & 0xFF) / 255.0
        let b = Double(rgb & 0xFF) / 255.0

        self.init(red: r, green: g, blue: b)
    }
}

struct BtnStyle: ButtonStyle {
    var height: CGFloat = 50
    var width: CGFloat? = nil

    func makeBody(configuration: Configuration) -> some View {
        let baseGradient = LinearGradient(
            colors: [
                Color(hex: "#FE284A"),
                Color(hex: "#D1213D"),
            ],
            startPoint: .leading,
            endPoint: .trailing
        )

        return configuration.label
            .frame(
                maxWidth: width ?? .infinity,
                maxHeight: height
            )
            .frame(width: width)
            .frame(height: height)
            .background(
                ZStack {
                    baseGradient
                        .clipShape(Capsule())
                        .shadow(
                            color: Color(hex: "#A01024").opacity(
                                configuration.isPressed ? 0.45 : 0.85
                            ),
                            radius: 0,
                            x: 0,
                            y: configuration.isPressed ? 2 : 6
                        )
                }
            )
            .foregroundColor(.white)
            .overlay(
                Capsule()
                    .stroke(
                        Color.white.opacity(
                            configuration.isPressed ? 0.25 : 0.14
                        ),
                        lineWidth: 1
                    )
            )
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
    }
}
