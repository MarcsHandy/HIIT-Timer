import SwiftUI
import Charts // Make sure to import Charts (iOS 16+)

struct WeightTrackerView: View {
    @Binding var showHamburgerMenu: Bool
    @AppStorage("weightLogs") private var weightLogsData: Data = Data()
    @State private var weightLogs: [WeightEntry] = []
    @State private var newWeight: String = ""
    @State private var editingEntry: WeightEntry? = nil
    @State private var showDeleteAlert = false
    @State private var entryToDelete: WeightEntry? = nil
    
    var body: some View {
        VStack(spacing: 20) {
            
            HeaderView(title: "Weight Tracker", showHamburgerMenu: $showHamburgerMenu)
                .zIndex(1)

            // MARK: - Weight Chart
            if !weightLogs.isEmpty {
                Chart(weightLogs.sorted(by: { $0.date < $1.date })) { entry in
                    LineMark(
                        x: .value("Date", entry.date),
                        y: .value("Weight", entry.weight)
                    )
                    .foregroundStyle(.blue.gradient)
                    .symbol(Circle())
                }
                .frame(height: 200)
                .padding(.horizontal)
            }

            // MARK: - Input
            HStack {
                TextField("Enter weight (kg)", text: $newWeight)
                    .keyboardType(.decimalPad)
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
                
                Button(action: saveOrUpdateWeight) {
                    Text(editingEntry == nil ? "Save" : "Update")
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(editingEntry == nil ? Color.blue : Color.orange)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            }
            .padding(.horizontal)

            // MARK: - Weight List
            List {
                ForEach(weightLogs.reversed(), id: \.id) { entry in
                    HStack {
                        VStack(alignment: .leading) {
                            Text("\(entry.weight, specifier: "%.2f") kg")
                                .font(.headline)
                            Text(entry.date.formatted(date: .abbreviated, time: .shortened))
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        Spacer()
                        if editingEntry?.id == entry.id {
                            Text("Editing")
                                .font(.caption)
                                .foregroundColor(.orange)
                                .padding(4)
                                .background(Color.orange.opacity(0.2))
                                .cornerRadius(4)
                        }
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        editingEntry = entry
                        newWeight = String(format: "%.2f", entry.weight)
                    }
                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                        Button(role: .destructive) {
                            entryToDelete = entry
                            showDeleteAlert = true
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                        
                        Button {
                            editingEntry = entry
                            newWeight = String(format: "%.2f", entry.weight)
                        } label: {
                            Label("Edit", systemImage: "pencil")
                        }
                        .tint(.orange)
                    }
                }
            }
        }
        .padding(.top)
        .onAppear(perform: loadLogs)
        .alert(isPresented: $showDeleteAlert) {
            Alert(
                title: Text("Delete Entry?"),
                message: Text("Are you sure you want to delete this weight entry?"),
                primaryButton: .destructive(Text("Delete")) {
                    if let entry = entryToDelete,
                       let index = weightLogs.firstIndex(where: { $0.id == entry.id }) {
                        weightLogs.remove(at: index)
                        saveLogs()
                    }
                },
                secondaryButton: .cancel()
            )
        }
    }

    // MARK: - Functions
    private func saveOrUpdateWeight() {
        guard let weight = Double(newWeight) else { return }
        let roundedWeight = (weight * 100).rounded() / 100

        if let editing = editingEntry,
           let index = weightLogs.firstIndex(where: { $0.id == editing.id }) {
            weightLogs[index] = WeightEntry(id: editing.id, weight: roundedWeight, date: editing.date)
            editingEntry = nil
        } else {
            let newEntry = WeightEntry(weight: roundedWeight, date: Date())
            weightLogs.append(newEntry)
        }

        saveLogs()
        newWeight = ""
    }

    private func saveLogs() {
        if let encoded = try? JSONEncoder().encode(weightLogs) {
            weightLogsData = encoded
        }
    }

    private func loadLogs() {
        if let decoded = try? JSONDecoder().decode([WeightEntry].self, from: weightLogsData) {
            weightLogs = decoded
        }
    }
}

struct WeightEntry: Identifiable, Codable {
    let id: UUID
    let weight: Double
    let date: Date

    init(id: UUID = UUID(), weight: Double, date: Date) {
        self.id = id
        self.weight = weight
        self.date = date
    }
}
