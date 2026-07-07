import Foundation

struct InspectionEntry: Identifiable, Codable, Equatable {
    let id: UUID
    var area: String
    var moistureLevel: String
    var pestSigns: String
    var notes: String
    var createdAt: Date

    init(id: UUID = UUID(), area: String, moistureLevel: String, pestSigns: String, notes: String = "", createdAt: Date = Date()) {
        self.id = id
        self.area = area
        self.moistureLevel = moistureLevel
        self.pestSigns = pestSigns
        self.notes = notes
        self.createdAt = createdAt
    }
}
