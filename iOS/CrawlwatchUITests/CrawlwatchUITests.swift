import XCTest

final class CrawlwatchUITests: XCTestCase {
    func testAddEntryFlow() {
        let app = XCUIApplication()
        app.launch()
        app.buttons["addButton"].tap()
        let field = app.textFields["field_area"]
        XCTAssertTrue(field.waitForExistence(timeout: 2))
        field.tap()
        field.typeText("UI Test Entry")
        app.buttons["saveButton"].tap()
        XCTAssertTrue(app.staticTexts["UI Test Entry"].waitForExistence(timeout: 2))
    }

    func testFreeLimitTriggersPaywall() {
        let app = XCUIApplication()
        app.launch()
        for i in 0..<10 {
            app.buttons["addButton"].tap()
            let field = app.textFields["field_area"]
            if field.waitForExistence(timeout: 1) {
                field.tap()
                field.typeText("Item \(i)")
                app.buttons["saveButton"].tap()
            } else {
                break
            }
        }
        XCTAssertTrue(app.buttons["unlockProButton"].waitForExistence(timeout: 3))
    }

    func testKeyboardDismissOnTapOutside() {
        let app = XCUIApplication()
        app.launch()
        app.buttons["addButton"].tap()
        let field = app.textFields["field_area"]
        XCTAssertTrue(field.waitForExistence(timeout: 2))
        field.tap()
        field.typeText("Dismiss test")
        app.staticTexts["Details"].tap()
        XCTAssertFalse(app.keyboards.element.exists)
    }

    func testSettingsOpens() {
        let app = XCUIApplication()
        app.launch()
        app.buttons["settingsButton"].tap()
        XCTAssertTrue(app.buttons["settingsDoneButton"].waitForExistence(timeout: 2))
    }

    func testCancelAddEntry() {
        let app = XCUIApplication()
        app.launch()
        app.buttons["addButton"].tap()
        app.buttons["cancelButton"].tap()
        XCTAssertFalse(app.textFields["field_area"].exists)
    }
}
