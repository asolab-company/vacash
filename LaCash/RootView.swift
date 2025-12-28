import SwiftUI

let onboardingShownKey = "Welcome"
let receiptsStoreKey = "LaCash.receipts.v1"

enum AppRoute: Equatable {
    case preloader
    case welcome
    case main
    case settings
    case addreceipt

}

struct RootView: View {
    @State private var route: AppRoute = .preloader
    @State private var receipts: [Receipt] = []

    private func makeReceipt(from record: IdeaRecord) -> Receipt? {
        guard let amount = Int(record.details) else { return nil }
        return Receipt(
            id: record.id,
            title: record.title,
            date: record.createdAt,
            amount: amount
        )
    }

    private func loadReceiptsFromStorage() {
        guard
            let data = UserDefaults.standard.data(forKey: "LaCash.receipts.v1"),
            let ideas = try? JSONDecoder().decode([IdeaRecord].self, from: data)
        else {
            receipts = []
            return
        }

        receipts = ideas.compactMap { makeReceipt(from: $0) }
    }

    private func deleteReceipt(_ receipt: Receipt) {

        receipts.removeAll { $0.id == receipt.id }

        guard
            let data = UserDefaults.standard.data(forKey: "LaCash.receipts.v1"),
            var ideas = try? JSONDecoder().decode([IdeaRecord].self, from: data)
        else {
            return
        }

        ideas.removeAll { $0.id == receipt.id }

        if let newData = try? JSONEncoder().encode(ideas) {
            UserDefaults.standard.set(newData, forKey: "LaCash.receipts.v1")
        }
    }

    var body: some View {
        ZStack {
            Color(hex: "222337")
                .ignoresSafeArea()

            currentScreen
        }.onAppear {
            loadReceiptsFromStorage()
        }
    }

    @ViewBuilder
    private var currentScreen: some View {
        switch route {
        case .preloader:
            Preloading {
                let needsOnboarding = !UserDefaults.standard.bool(
                    forKey: onboardingShownKey
                )
                route = needsOnboarding ? .welcome : .main
            }

        case .welcome:
            Welcome {
                UserDefaults.standard.set(true, forKey: onboardingShownKey)
                route = .main
            }

        case .main:
            Main(
                onSettings: { route = .settings },
                onAddReceipt: { route = .addreceipt },
                receipts: receipts,
                onDelete: { receipt in
                    deleteReceipt(receipt)
                }
            )

        case .settings:
            Settings(onBack: { route = .main })

        case .addreceipt:
            AddReceipt(
                onCancel: {
                    route = .main
                },
                onSaved: { record in
                    if let newReceipt = makeReceipt(from: record) {
                        receipts.append(newReceipt)
                    }
                    route = .main
                }
            )
        }
    }
}

#Preview {
    RootView()
}
