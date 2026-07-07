import Foundation

struct Tantrum: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    var trigger: String
    var note: String
    var date: Date = Date()
}
