import SwiftUI

struct IdeaRecord: Identifiable, Codable {
    let id: UUID
    let title: String
    let details: String
    let createdAt: Date

}

private let receiptDateFormatter: DateFormatter = {
    let df = DateFormatter()
    df.dateFormat = "dd.MM.yyyy"
    return df
}()

extension IdeaRecord {
    var createdAtFormatted: String {
        receiptDateFormatter.string(from: createdAt)
    }
}

private func loadIdeas() -> [IdeaRecord] {
    guard let data = UserDefaults.standard.data(forKey: receiptsStoreKey) else {
        return []
    }
    return (try? JSONDecoder().decode([IdeaRecord].self, from: data)) ?? []
}

@discardableResult
private func persistIdea(title: String, details: String) -> IdeaRecord {
    var all = loadIdeas()
    let record = IdeaRecord(
        id: UUID(),
        title: title,
        details: details,
        createdAt: Date()
    )
    all.append(record)
    if let data = try? JSONEncoder().encode(all) {
        UserDefaults.standard.set(data, forKey: receiptsStoreKey)
    }
    return record
}

private func updateIdea(id: UUID, title: String, details: String) -> IdeaRecord?
{
    var all = loadIdeas()
    guard let idx = all.firstIndex(where: { $0.id == id }) else { return nil }
    let updated = IdeaRecord(
        id: id,
        title: title,
        details: details,
        createdAt: all[idx].createdAt
    )
    all[idx] = updated
    if let data = try? JSONEncoder().encode(all) {
        UserDefaults.standard.set(data, forKey: receiptsStoreKey)
    }
    return updated
}

struct AddReceipt: View {
    var editRecord: IdeaRecord? = nil
    var onCancel: () -> Void
    var onSaved: (_ saved: IdeaRecord) -> Void = { _ in }

    @State private var title: String = ""
    @State private var details: String = ""
    @FocusState private var focusTitle: Bool

    private var isSaveEnabled: Bool {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedAmount = details.trimmingCharacters(
            in: .whitespacesAndNewlines
        )
        return !trimmedTitle.isEmpty && !trimmedAmount.isEmpty
    }

    var body: some View {
        ZStack(alignment: .top) {

            VStack(spacing: 0) {
                HStack {
                    Button(action: {
                        title = ""
                        details = ""
                        onCancel()
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                    }

                    Text("Add Receipt")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.leading)
                    Spacer()

                    Button(action: {
                        title = ""
                        details = ""

                    }) {
                        Text("Cancel")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(Color.init(hex: "6A6794"))
                    }

                }
                .padding(.horizontal, 30)
                .padding(.bottom)
                .frame(height: 50, alignment: .bottom)
                .background(
                    ZStack {
                        Color(hex: "191929")
                            .ignoresSafeArea()
                    }
                )
                .padding(.bottom, 30)

                Group {
                    Text("Name*")
                        .foregroundColor(.white)
                        .font(.system(size: 16, weight: .regular))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.bottom, 5)
                        .padding(.leading)

                    RoundedField(
                        placeholder: "Enter the receipt name",
                        text: $title,

                        focus: $focusTitle
                    )
                }
                .padding(.horizontal)

                Group {
                    Text("Amount*")
                        .foregroundColor(.white)
                        .font(.system(size: 16, weight: .regular))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.bottom, 5)
                        .padding(.leading)
                        .padding(.top, 10)

                    RoundedField(
                        placeholder: "Enter the amount",
                        text: $details,
                        keyboardType: .numberPad
                    )
                    .onChange(of: details) { newValue in
                        details = newValue.filter { $0.isNumber }
                    }
                }

                .padding(.horizontal)

                if isSaveEnabled {
                    Button(action: {
                        let trimmedTitle = title.trimmingCharacters(
                            in: .whitespacesAndNewlines
                        )
                        let trimmedDetails = details.trimmingCharacters(
                            in: .whitespacesAndNewlines
                        )
                        guard !trimmedTitle.isEmpty, !trimmedDetails.isEmpty
                        else {
                            return
                        }

                        if let rec = editRecord {

                            if let updated = updateIdea(
                                id: rec.id,
                                title: trimmedTitle,
                                details: trimmedDetails
                            ) {
                                NotificationCenter.default.post(
                                    name: Notification.Name(
                                        "Ideax.refreshIdeas"
                                    ),
                                    object: nil
                                )
                                onSaved(updated)
                            }
                            onCancel()
                        } else {

                            let saved = persistIdea(
                                title: trimmedTitle,
                                details: trimmedDetails
                            )
                            NotificationCenter.default.post(
                                name: Notification.Name("Ideax.refreshIdeas"),
                                object: nil
                            )
                            onSaved(saved)
                            onCancel()
                        }
                    }) {
                        ZStack {
                            Text("Save")
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
                    .buttonStyle(BtnStyle(height: 64))
                    .padding(.horizontal)
                    .padding(.top, 30)
                }

                Spacer()

            }
            .onAppear {

                DispatchQueue.main.async { focusTitle = true }

                if let rec = editRecord {
                    if title.isEmpty { title = rec.title }
                    if details.isEmpty { details = rec.details }
                }
            }

        }
        .background(
            ZStack {
                Color(hex: "222337")
                    .ignoresSafeArea()

            }

        )

    }

}

private struct RoundedField: View {
    let placeholder: String
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default
    var focus: FocusState<Bool>.Binding? = nil

    private let height: CGFloat = 44

    var body: some View {
        ZStack(alignment: .leading) {

            if text.isEmpty {
                Text(placeholder)
                    .foregroundColor(Color(hex: "6A6794"))
                    .font(.system(size: 16))
                    .padding(.horizontal, 14)
            }

            Group {
                if let focus {
                    TextField("", text: $text)
                        .focused(focus)
                } else {
                    TextField("", text: $text)
                }
            }
            .keyboardType(keyboardType)
            .foregroundColor(.white)
            .font(.system(size: 16))
            .padding(.horizontal, 14)
        }
        .frame(height: height)
        .background(
            Capsule()
                .fill(Color(hex: "6A6794").opacity(0.1))
        )
    }
}

#Preview {
    AddReceipt(onCancel: {}, onSaved: { _ in })
}
