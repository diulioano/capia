import CapiaFlow
import Foundation
import XCTest

final class SpaceStoreTests: XCTestCase {
    private var directory: URL!
    /// Criado uma vez por teste, para que os identificadores se mantenham.
    private let sample = ConfiguredSpace(
        profile: Profile(name: "Diuli Vargas", goals: [.understandSpending, .leaveSpreadsheet]),
        accounts: [Account(kind: .checking, name: "Banco Aurora", initialBalance: Cents(123_456)),
                   Account(kind: .wallet, name: "Carteira", initialBalance: .zero)],
        cards: [CreditCard(name: "Banco Aurora", closingDay: 5, dueDay: 12)],
        completedAt: Date(timeIntervalSince1970: 1_793_000_000))

    override func setUpWithError() throws {
        directory = FileManager.default.temporaryDirectory
            .appendingPathComponent("CapiaSpaceStoreTests-\(UUID().uuidString)")
            .appendingPathComponent("Capia")
    }

    override func tearDownWithError() throws {
        try? FileManager.default.removeItem(at: directory.deletingLastPathComponent())
    }

    func testMissingFileLoadsNothing() {
        XCTAssertNil(SpaceStore(directory: directory).load())
    }

    func testRoundTripCreatesDirectoryAndPreservesEverything() throws {
        let store = SpaceStore(directory: directory)
        try store.save(sample)
        XCTAssertEqual(store.load(), sample)

        var updated = sample
        updated.accounts.append(Account(kind: .savings, name: "Poupança", initialBalance: .max))
        try store.save(updated)
        XCTAssertEqual(store.load(), updated)
    }

    func testCorruptFileLoadsNothingAndIsKept() throws {
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        let store = SpaceStore(directory: directory)
        try Data("{ not json".utf8).write(to: store.fileURL)
        XCTAssertNil(store.load())
        XCTAssertTrue(FileManager.default.fileExists(atPath: store.fileURL.path))
    }

    func testUnknownSchemaVersionLoadsNothing() throws {
        let store = SpaceStore(directory: directory)
        try store.save(sample)
        let text = try String(contentsOf: store.fileURL, encoding: .utf8)
            .replacingOccurrences(of: "\"schemaVersion\" : 1", with: "\"schemaVersion\" : 2")
        XCTAssertTrue(text.contains("\"schemaVersion\" : 2"))
        try Data(text.utf8).write(to: store.fileURL)
        XCTAssertNil(store.load())
    }

    func testSpaceWithoutAccountsLoadsNothing() throws {
        var empty = sample
        empty.accounts = []
        let store = SpaceStore(directory: directory)
        try store.save(empty)
        XCTAssertNil(store.load())
    }

    func testCardsStaySeparateFromAccountsInTheDocument() throws {
        let store = SpaceStore(directory: directory)
        try store.save(sample)
        let json = try JSONSerialization.jsonObject(with: Data(contentsOf: store.fileURL)) as? [String: Any]
        XCTAssertEqual((json?["accounts"] as? [Any])?.count, 2)
        XCTAssertEqual((json?["cards"] as? [Any])?.count, 1)
        XCTAssertEqual(((json?["accounts"] as? [[String: Any]])?.first?["initialBalance"] as? Int), 123_456)
    }

    func testSalaryAndReceiptsRoundTrip() throws {
        let store = SpaceStore(directory: directory)
        var space = sample
        space.monthlySalary = Cents(620_000)
        space.salaryReceipts = [SalaryReceipt(year: 2026, month: 11, amount: Cents(620_000),
                                              confirmedAt: Date(timeIntervalSince1970: 1_793_000_100))]
        try store.save(space)
        XCTAssertEqual(store.load(), space)
    }

    func testSpaceSavedBeforeSalaryStillLoads() throws {
        // Documento gravado pela funcionalidade 002, sem as chaves do salário.
        let json = """
        {"accounts":[{"id":"00000000-0000-0000-0000-000000000001","initialBalance":99,"kind":"checking","name":"Banco Aurora"}],
         "cards":[],"completedAt":"2026-11-06T12:00:00Z",
         "profile":{"goals":["saveForGoal"],"name":"Diuli"},"schemaVersion":1}
        """
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        try Data(json.utf8).write(to: SpaceStore(directory: directory).fileURL)
        let loaded = try XCTUnwrap(SpaceStore(directory: directory).load())
        XCTAssertNil(loaded.monthlySalary)
        XCTAssertEqual(loaded.salaryReceipts, [])
        XCTAssertEqual(loaded.accounts.first?.initialBalance, Cents(99))
    }
}
