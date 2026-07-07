import Foundation
import Combine

@MainActor
final class Store: ObservableObject {
    static let freeLimit = 13

    @Published var items: [Tantrum] = []
    @Published var isPro: Bool = false

    private let fileURL: URL

    init() {
        let dir = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        fileURL = dir.appendingPathComponent("tantrumlog_items.json")
        load()
    }

    var canAddMore: Bool {
        isPro || items.count < Store.freeLimit
    }

    func add(_ item: Tantrum) {
        items.insert(item, at: 0)
        save()
    }

    func update(_ item: Tantrum) {
        if let idx = items.firstIndex(where: { $0.id == item.id }) {
            items[idx] = item
            save()
        }
    }

    func delete(at offsets: IndexSet) {
        items.remove(atOffsets: offsets)
        save()
    }

    func delete(_ item: Tantrum) {
        items.removeAll { $0.id == item.id }
        save()
    }

    private func load() {
        guard let data = try? Data(contentsOf: fileURL),
              let decoded = try? JSONDecoder().decode([Tantrum].self, from: data) else {
            items = [
            Tantrum(trigger: "Tired at bedtime", note: ""),
            Tantrum(trigger: "Wanted more screen time", note: ""),
            Tantrum(trigger: "Sibling took toy", note: "")
            ]
            save()
            return
        }
        items = decoded
    }

    func save() {
        guard let data = try? JSONEncoder().encode(items) else { return }
        try? data.write(to: fileURL, options: .atomic)
    }
}
