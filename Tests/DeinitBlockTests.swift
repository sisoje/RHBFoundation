import XCTest
import RHBFoundation

final class DeinitBlockTests: XCTestCase {
    func testDeinitBlock() {
        var t = 0
        _ = DeinitBlock {
            XCTAssert(t == 0)
            t = 1
        }
        XCTAssert(t == 1)
    }

    func testDeinitBlock2() {
        var t = 0
        var d: DeinitBlock? = DeinitBlock {
            XCTAssert(t == 0)
            t = 1
        }
        XCTAssert(t == 0)
        d?.noop()
        XCTAssert(t == 0)
        d = nil
        XCTAssert(t == 1)
    }

    func testNotificationCenter() {
        let notificationName = NSNotification.Name("testNotificationCenter")
        let exp = self.expectation(description: notificationName.rawValue)
        var rm: DeinitBlock?
        rm = NotificationCenter.default.addSmartObserver(name: notificationName) { _ in
            XCTAssertNotNil(rm)
            rm = nil
            exp.fulfill()
        }
        OperationQueue().addOperation {
            NotificationCenter.default.post(name: notificationName, object: nil)
        }
        self.waitForExpectations(timeout: 1, handler: nil)
    }

    func testTimer() {
        let tick = 0.001
        var x = 0
        let timer = Timer.scheduledTimer(withTimeInterval: tick, repeats: true) { _ in
            x += 1
        }
        autoreleasepool {
            let ex = expectation(description: #function)
            let invalidation = timer.invalidation
            DispatchQueue.global().asyncAfter(deadline: .now()+tick*2) {
                invalidation.noop()
                ex.fulfill()
            }
        }
        waitForExpectations(timeout: 1) { error in
            XCTAssertNil(error)
            XCTAssert(!timer.isValid)
            XCTAssert(x > 0)
        }
    }
}