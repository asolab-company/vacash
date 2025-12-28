import SwiftUI

struct Welcome: View {
    var onContinue: () -> Void = {}

    var body: some View {
        ZStack(alignment: .top) {

            Image("app_welcome")
                .resizable()
                .scaledToFill()
                .frame(height: Device.isSmall ? 250 : 450)
                .padding(.vertical)
                .ignoresSafeArea()

            GeometryReader { geo in
                VStack {
                    Spacer()

                    VStack(spacing: 5) {

                        VStack(alignment: .leading, spacing: 8) {
                            FeatureRow(
                                icon: "💰",
                                title: "Stay Aware:",
                                subtitle: "Always know how much you’ve earned."
                            )

                            FeatureRow(
                                icon: "📈",
                                title: "Plan Ahead:",
                                subtitle:
                                    "Track income to make smarter financial decisions."
                            )

                            FeatureRow(
                                icon: "📝",
                                title: "Simple & Fast:",
                                subtitle: "Log earnings in seconds, no clutter."
                            )
                        }
                        .padding(.bottom)

                        Button(action: { onContinue() }) {
                            ZStack {
                                Text("Continue")
                                    .font(.system(size: 24, weight: .bold))
                                HStack {
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .font(
                                            .system(size: 18, weight: .bold)
                                        )
                                }
                                .padding(.horizontal, 20)
                            }
                            .padding(.vertical, 14)
                            .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(BtnStyle(height: Device.isSmall ? 50 : 60))
                        .padding(.bottom, 8)

                        TermsFooter().padding(
                            .bottom,
                            Device.isSmall ? 10 : 60
                        )
                    }
                    .padding(.horizontal, 30)

                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }.ignoresSafeArea()
            .background(
                ZStack {
                    Color(hex: "222337")
                        .ignoresSafeArea()

                }

            )
    }
}

private struct FeatureRow: View {
    let icon: String
    let title: String
    let subtitle: String

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Text(icon)
                .font(.system(size: Device.isSmall ? 16 : 20))
                .frame(width: 26, alignment: .leading)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(
                        .system(size: Device.isSmall ? 16 : 18, weight: .heavy)
                    )
                    .foregroundColor(.white)

                Text(subtitle)
                    .font(.system(size: Device.isSmall ? 12 : 14))
                    .foregroundColor(.white.opacity(0.85))
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    Welcome {
        print("Finished")
    }
}
