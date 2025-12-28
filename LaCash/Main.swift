import SwiftUI

struct Receipt: Identifiable {
    let id: UUID
    let title: String
    let date: Date
    let amount: Int
}

struct Main: View {
    var onSettings: () -> Void = {}
    var onAddReceipt: () -> Void = {}
    @State private var selected: Mode = .month
    @State private var currentYear: Int = Calendar.current.component(
        .year,
        from: Date()
    )
    @State private var currentMonth: Int = Calendar.current.component(
        .month,
        from: Date()
    )

    enum Mode { case month, year, total }
    let receipts: [Receipt]
    var onDelete: (Receipt) -> Void = { _ in }

    var body: some View {
        ZStack(alignment: .top) {

            VStack(spacing: 0) {
                Image("app_main")
                    .resizable()
                    .scaledToFill()
                    .frame(height: Device.isSmall ? 290 : 385)
                    .clipped()
                    .ignoresSafeArea()

                    .overlay(alignment: .topTrailing) {
                        Button(action: {
                            onSettings()
                        }) {
                            Image(systemName: "gearshape.fill")
                                .font(.system(size: 22, weight: .bold))
                                .foregroundColor(.white)
                                .padding(10)

                        }
                        .padding(.top, 40)
                        .padding(.trailing, 24)
                    }

                    .overlay(alignment: .bottomTrailing) {
                        Button(action: {
                            onAddReceipt()
                        }) {
                            Image(systemName: "plus")
                                .font(.system(size: 24, weight: .heavy))
                                .foregroundColor(.white)
                                .padding(12)

                        }
                        .padding(.trailing, 24)
                        .padding(.bottom, 16)
                        .buttonStyle(
                            BtnStyle(
                                height: Device.isSmall ? 48 : 58,
                                width: Device.isSmall ? 50 : 60
                            )
                        )
                    }

                    .overlay(alignment: .top) {
                        ZStack {

                            Image("total_bg")
                                .resizable()
                                .scaledToFit()
                                .frame(height: 52)

                            Text("\(periodTotal)")
                                .font(.system(size: 24, weight: .heavy))
                                .foregroundColor(Color.init(hex: "FF9F19"))
                        }
                        .padding(.top, Device.isSmall ? 80 : 120)
                    }
                ZStack {
                    Image("app_bg_choose")
                        .resizable()
                        .scaledToFill()
                        .frame(height: 90)
                        .clipped()

                    VStack(spacing: 10) {

                        HStack(spacing: 8) {
                            segmentButton(.month, title: "Month")
                            segmentButton(.year, title: "Year")
                            segmentButton(.total, title: "Total")
                        }
                        .padding(.horizontal)

                        HStack {
                            Button(action: {
                                goPreviousPeriod()
                            }) {
                                Image(systemName: "chevron.left")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(.white)
                            }

                            Spacer()

                            Text(periodTitle)
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.white)

                            Spacer()

                            Button(action: {
                                goNextPeriod()
                            }) {
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 18, weight: .regular))
                                    .foregroundColor(.white)
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                    .padding(.horizontal, 5)
                }
                .frame(height: 90)

                Text("Swipe left on the bar if you want to delete receipt.")
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(Color.white.opacity(0.9))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(
                        Capsule()
                            .fill(Color(hex: "6A6794").opacity(0.2))
                    )
                    .padding(.horizontal, 24)
                    .padding(.top, 10)

                if filteredReceipts.isEmpty {
                    VStack(spacing: 5) {
                        Image("app_bg_empty")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 120)

                        Text("There are no receipts in your list yet.")
                            .font(.system(size: 16, weight: .regular))
                            .foregroundColor(Color(hex: "6A6794"))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 24)

                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List {
                        ForEach(filteredReceipts) { receipt in
                            ReceiptRow(receipt: receipt)
                                .listRowSeparator(.hidden)
                                .listRowBackground(Color.clear)
                                .listRowInsets(
                                    EdgeInsets(
                                        top: 10,
                                        leading: 24,
                                        bottom: 0,
                                        trailing: 24
                                    )
                                )
                                .swipeActions(
                                    edge: .trailing,
                                    allowsFullSwipe: true
                                ) {
                                    Button(role: .destructive) {
                                        onDelete(receipt)
                                    } label: {
                                        Image(systemName: "trash")
                                    }
                                }
                        }
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                }

                Spacer()

            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

        }.ignoresSafeArea()
            .background(
                ZStack {
                    Color(hex: "222337")
                        .ignoresSafeArea()

                }

            )
    }

    private var filteredReceipts: [Receipt] {
        switch selected {
        case .month:
            return receipts.filter { rec in
                let comps = Calendar.current.dateComponents(
                    [.year, .month],
                    from: rec.date
                )
                return comps.year == currentYear && comps.month == currentMonth
            }
        case .year:
            return receipts.filter { rec in
                let comps = Calendar.current.dateComponents(
                    [.year],
                    from: rec.date
                )
                return comps.year == currentYear
            }
        case .total:
            return receipts
        }
    }

    private var periodTotal: Int {
        filteredReceipts.reduce(0) { $0 + $1.amount }
    }

    private var periodTitle: String {
        switch selected {
        case .month:
            return "\(monthName(for: currentMonth)) \(currentYear)"
        case .year:
            return "\(currentYear)"
        case .total:
            return "All time"
        }
    }

    private func monthName(for month: Int) -> String {
        let df = DateFormatter()
        df.locale = Locale.current
        let months = df.monthSymbols ?? []
        guard month > 0, month <= months.count else {
            return "Month"
        }
        return months[month - 1]
    }

    private func goPreviousPeriod() {
        switch selected {
        case .month:
            if currentMonth == 1 {
                currentMonth = 12
                currentYear -= 1
            } else {
                currentMonth -= 1
            }
        case .year:
            currentYear -= 1
        case .total:
            break
        }
    }

    private func goNextPeriod() {
        switch selected {
        case .month:
            if currentMonth == 12 {
                currentMonth = 1
                currentYear += 1
            } else {
                currentMonth += 1
            }
        case .year:
            currentYear += 1
        case .total:
            break
        }
    }

    @ViewBuilder
    private func segmentButton(_ mode: Mode, title: String) -> some View {
        let isSelected = (selected == mode)

        Button(action: {
            selected = mode
        }) {
            Text(title)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(isSelected ? .white : Color(hex: "A5A5BE"))
                .padding(.vertical, 6)
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 5)
                        .fill(
                            Color(hex: "121325")
                                .opacity(isSelected ? 1.0 : 0.3)
                        )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(
                            Color.white.opacity(isSelected ? 1.0 : 0.4),
                            lineWidth: 1
                        )
                )
        }
        .buttonStyle(.plain)
        .contentShape(RoundedRectangle(cornerRadius: 5))
    }
}

private struct ReceiptRow: View {
    let receipt: Receipt

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 30)
                .fill(Color(hex: "191929"))

            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(receipt.title)
                        .font(.system(size: 16, weight: .regular))
                        .foregroundColor(.white)

                    Text(receipt.dateFormatted)
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(Color(hex: "6A6794"))
                }

                Spacer()

                Text("\(receipt.amount)")
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(Color(hex: "FE284A"))
            }
            .padding(.horizontal, 24)

        }
        .frame(height: 68)
    }
}

private let receiptDateFormatter: DateFormatter = {
    let df = DateFormatter()
    df.dateFormat = "dd.MM.yyyy"
    return df
}()

extension Receipt {
    fileprivate var dateFormatted: String {
        receiptDateFormatter.string(from: date)
    }
}

#Preview {
    Main(
        onSettings: {
            print("Finished")
        },
        onAddReceipt: {
            print("Finished")
        },
        receipts: [

        ]
    )
}
