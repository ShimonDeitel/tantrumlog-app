import XCTest
@testable import TantrumLog

@MainActor
final class TantrumLogTests: XCTestCase {
    var store: Store!

    override func setUp() {
        super.setUp()
        store = Store()
        store.items = []
        store.save()
    }

    func testAddItem() {
        let item = Tantrum(trigger: "Test", note: "Note")
        store.add(item)
        XCTAssertEqual(store.items.count, 1)
    }

    func testAddInsertsAtFront() {
        store.add(Tantrum(trigger: "First", note: ""))
        store.add(Tantrum(trigger: "Second", note: ""))
        XCTAssertEqual(store.items.first?.trigger, "Second")
    }

    func testDeleteItem() {
        let item = Tantrum(trigger: "ToDelete", note: "")
        store.add(item)
        store.delete(item)
        XCTAssertTrue(store.items.isEmpty)
    }

    func testDeleteAtOffsets() {
        store.add(Tantrum(trigger: "A", note: ""))
        store.add(Tantrum(trigger: "B", note: ""))
        store.delete(at: IndexSet(integer: 0))
        XCTAssertEqual(store.items.count, 1)
    }

    func testFreeLimitAllowsAdding() {
        for i in 0..<Store.freeLimit {
            store.add(Tantrum(trigger: "Item \(i)", note: ""))
        }
        XCTAssertEqual(store.items.count, Store.freeLimit)
        XCTAssertFalse(store.canAddMore)
    }

    func testCanAddMoreWhenUnderLimit() {
        store.add(Tantrum(trigger: "One", note: ""))
        XCTAssertTrue(store.canAddMore)
    }

    func testProBypassesLimit() {
        store.isPro = true
        for i in 0..<(Store.freeLimit + 5) {
            store.add(Tantrum(trigger: "Item \(i)", note: ""))
        }
        XCTAssertTrue(store.canAddMore)
    }

    func testUpdateItem() {
        var item = Tantrum(trigger: "Original", note: "")
        store.add(item)
        item.trigger = "Updated"
        store.update(item)
        XCTAssertEqual(store.items.first?.trigger, "Updated")
    }
}
