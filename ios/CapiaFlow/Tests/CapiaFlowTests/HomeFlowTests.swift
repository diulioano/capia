import CapiaFlow
import XCTest

final class HomeFlowTests: XCTestCase {
    func testInitialState() {
        let home = HomeFlow()
        XCTAssertEqual(home.tab, .month)
        XCTAssertEqual(home.categoryTab, .expenses)
        XCTAssertFalse(home.valuesHidden)
    }

    func testTabsAndBillLeadToAccounts() {
        var home = HomeFlow()
        home.send(.select(.goals))
        XCTAssertEqual(home.tab, .goals)
        home.send(.openBill)
        XCTAssertEqual(home.tab, .accounts)
        home.send(.select(.accounts))
        XCTAssertEqual(home.tab, .accounts)
        home.send(.select(.month))
        XCTAssertEqual(home.tab, .month)
    }

    func testCategoryTabsSwitch() {
        var home = HomeFlow()
        home.send(.selectCategory(.income))
        XCTAssertEqual(home.categoryTab, .income)
        home.send(.selectCategory(.income))
        XCTAssertEqual(home.categoryTab, .income)
        home.send(.selectCategory(.expenses))
        XCTAssertEqual(home.categoryTab, .expenses)
    }

    func testHideValuesToggles() {
        var home = HomeFlow()
        home.send(.toggleValuesHidden)
        XCTAssertTrue(home.valuesHidden)
        home.send(.select(.accounts))
        XCTAssertTrue(home.valuesHidden, "Trocar de aba não revela valores")
        home.send(.toggleValuesHidden)
        XCTAssertFalse(home.valuesHidden)
    }

    func testNewRecordActionsDoNotChangeTheHome() {
        var home = HomeFlow()
        home.send(.toggleValuesHidden)
        home.send(.openNewRecord)
        home.send(.closeNewRecord)
        XCTAssertEqual(home.tab, .month)
        XCTAssertTrue(home.valuesHidden)
    }
}
