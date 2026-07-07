import SwiftUI

struct ContentView: View {
    @EnvironmentObject var store: Store
    @EnvironmentObject var purchases: PurchaseManager
    @State private var showingAdd = false
    @State private var showingSettings = false
    @State private var showingPaywall = false
    @State private var editingEntry: InspectionEntry?

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.background.ignoresSafeArea()
                List {
                    ForEach(store.entries) { entry in
                        Button {
                            editingEntry = entry
                        } label: {
                            EntryRow(entry: entry)
                        }
                        .accessibilityIdentifier("entryRow_\(entry.area)")
                    }
                    .onDelete { offsets in
                        store.delete(at: offsets)
                    }
                    .listRowBackground(Theme.cardBackground)
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Crawlwatch")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        showingSettings = true
                    } label: {
                        Image(systemName: "gearshape.fill")
                    }
                    .accessibilityIdentifier("settingsButton")
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        if store.canAddMore {
                            showingAdd = true
                        } else {
                            showingPaywall = true
                        }
                    } label: {
                        Image(systemName: "plus.circle.fill")
                    }
                    .accessibilityIdentifier("addButton")
                }
            }
            .sheet(isPresented: $showingAdd) {
                EntryFormView(entry: nil) { newEntry in
                    store.add(newEntry)
                }
            }
            .sheet(item: $editingEntry) { entry in
                EntryFormView(entry: entry) { updated in
                    store.update(updated)
                }
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView()
            }
            .sheet(isPresented: $showingPaywall) {
                PaywallView()
            }
        }
    }
}

struct EntryRow: View {
    let entry: InspectionEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(entry.area).font(Theme.bodyFont).fontWeight(.semibold)
            Text(entry.moistureLevel).font(Theme.captionFont).foregroundStyle(.secondary)
            if !entry.notes.isEmpty {
                Text(entry.notes).font(Theme.captionFont).foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

struct EntryFormView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var area: String
    @State private var moistureLevel: String
    @State private var pestSigns: String
    @State private var notes: String
    @FocusState private var focusedField: Field?
    private enum Field { case f1, f2, f3, f4 }

    let existing: InspectionEntry?
    let onSave: (InspectionEntry) -> Void

    init(entry: InspectionEntry?, onSave: @escaping (InspectionEntry) -> Void) {
        self.existing = entry
        self.onSave = onSave
        _area = State(initialValue: entry?.area ?? "")
        _moistureLevel = State(initialValue: entry?.moistureLevel ?? "")
        _pestSigns = State(initialValue: entry?.pestSigns ?? "")
        _notes = State(initialValue: entry?.notes ?? "")
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Details") {
                    TextField("Area", text: $area)
                        .focused($focusedField, equals: .f1)
                        .accessibilityIdentifier("field_area")
                    TextField("Moisturelevel", text: $moistureLevel)
                        .focused($focusedField, equals: .f2)
                        .accessibilityIdentifier("field_moistureLevel")
                    TextField("Pestsigns", text: $pestSigns)
                        .focused($focusedField, equals: .f3)
                        .accessibilityIdentifier("field_pestSigns")
                    TextField("Notes", text: $notes)
                        .focused($focusedField, equals: .f4)
                        .accessibilityIdentifier("field_notes")
                }
            }
            .scrollDismissesKeyboard(.immediately)
            .contentShape(Rectangle())
            .onTapGesture {
                focusedField = nil
            }
            .navigationTitle(existing == nil ? "New Inspection" : "Edit Inspection")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .accessibilityIdentifier("cancelButton")
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let entry = InspectionEntry(
                            id: existing?.id ?? UUID(),
                            area: area,
                            moistureLevel: moistureLevel,
                            pestSigns: pestSigns,
                            notes: notes,
                            createdAt: existing?.createdAt ?? Date()
                        )
                        onSave(entry)
                        dismiss()
                    }
                    .disabled(area.isEmpty)
                    .accessibilityIdentifier("saveButton")
                }
            }
        }
    }
}
