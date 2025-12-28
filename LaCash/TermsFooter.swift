import SwiftUI

struct TermsFooter: View {
    var body: some View {
        VStack(spacing: 2) {
            Text("By Proceeding You Accept")
                .foregroundColor(Color.init(hex: "6A6794"))
                .font(.footnote)

            HStack(spacing: 0) {
                Text("Our ")
                    .foregroundColor(Color.init(hex: "6A6794"))
                    .font(.footnote)

                Link("Terms Of Use", destination: Data.terms)
                    .font(.footnote)
                    .foregroundColor(Color.init(hex: "FE284A"))

                Text(" And ")
                    .foregroundColor(Color.init(hex: "6A6794"))
                    .font(.footnote)

                Link("Privacy Policy", destination: Data.policy)
                    .font(.footnote)
                    .foregroundColor(Color.init(hex: "FE284A"))

            }
        }
        .frame(maxWidth: .infinity)
        .multilineTextAlignment(.center)
    }
}
