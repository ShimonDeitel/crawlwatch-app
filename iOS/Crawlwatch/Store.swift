import Foundation
import Combine

@MainActor
final class Store: ObservableObject {
    @Published private(set) var entries: [InspectionEntry] = []
    @Published var isPro: Bool = false

    static let freeLimit = 8

    private let fileURL: URL

    init() {
        let dir = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("Crawlwatch", isDirectory: true)
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        fileURL = dir.appendingPathComponent("entries.json")
        load()
        if entries.isEmpty {
            seed()
        }
    }

    var canAddMore: Bool {
        isPro || entries.count < Store.freeLimit
    }

    func add(_ entry: InspectionEntry) {
        entries.insert(entry, at: 0)
        save()
    }

    func update(_ entry: InspectionEntry) {
        guard let idx = entries.firstIndex(where: { $0.id == entry.id }) else { return }
        entries[idx] = entry
        save()
    }

    func delete(at offsets: IndexSet) {
        entries.remove(atOffsets: offsets)
        save()
    }

    func delete(_ entry: InspectionEntry) {
        entries.removeAll(where: { $0.id == entry.id })
        save()
    }

    private func seed() {
        entries = [
            InspectionEntry(area: "Front", moistureLevel: "Recently checked", pestSigns: "Good", notes: "Seed entry"),
            InspectionEntry(area: "Back", moistureLevel: "Last month", pestSigns: "Needs attention", notes: "Seed entry"),
            InspectionEntry(area: "Side", moistureLevel: "Two months ago", pestSigns: "Good", notes: "Seed entry"),
        ]
        save()
    }

    private func save() {
        guard let data = try? JSONEncoder().encode(entries) else { return }
        try? data.write(to: fileURL, options: .atomic)
    }

    private func load() {
        guard let data = try? Data(contentsOf: fileURL),
              let decoded = try? JSONDecoder().decode([InspectionEntry].self, from: data) else { return }
        entries = decoded
    }
}
