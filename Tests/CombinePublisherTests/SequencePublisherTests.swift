
import Combine
import CustomPublishers
import XCTest

final class SequencePublisherTests: XCTestCase {

    func testCompleteUnlimited() {

        let s1 = TestSubscriber<Int, Never>(demand: .unlimited)
        [1,2,3].publisher.subscribe(s1)

        let s2 = TestSubscriber<Int, Never>(demand: .unlimited)
        SequencePublisher([1,2,3]).subscribe(s2)

        let expectation: [TestSubscriber<Int, Never>.Event] = [
            .subscription,
            .input(1),
            .input(2),
            .input(3),
            .completion(.finished)
        ]

        XCTAssertEqual(s1.events, expectation)
        XCTAssertEqual(s2.events, expectation)
    }

    func testIncomplete() {

        let s1 = TestSubscriber<Int, Never>(demand: .max(2))
        [1,2,3].publisher.subscribe(s1)

        let s2 = TestSubscriber<Int, Never>(demand: .max(2))
        SequencePublisher([1,2,3]).subscribe(s2)

        let expectation: [TestSubscriber<Int, Never>.Event] = [
            .subscription,
            .input(1),
            .input(2)
        ]

        XCTAssertEqual(s1.events, expectation)
        XCTAssertEqual(s2.events, expectation)
    }

    func testIncreaseOnceComplete() {

        func makeSubscriber() -> TestSubscriber<Int, Never> {
            var shouldIncrease = true
            return TestSubscriber<Int, Never>(demand: .max(2), increase: {
                guard shouldIncrease else { return .none }
                shouldIncrease.toggle()
                return .max(1)
            })
        }

        let s1 = makeSubscriber()
        [1,2,3].publisher.subscribe(s1)

        let s2 = makeSubscriber()
        SequencePublisher([1,2,3]).subscribe(s2)

        let expectation: [TestSubscriber<Int, Never>.Event] = [
            .subscription,
            .input(1),
            .input(2),
            .input(3),
            .completion(.finished)
        ]

        XCTAssertEqual(s1.events, expectation)
        XCTAssertEqual(s2.events, expectation)
    }

    func testIncreaseOnceIncomplete() {

        func makeSubscriber() -> TestSubscriber<Int, Never> {
            var shouldIncrease = true
            return TestSubscriber<Int, Never>(demand: .max(1), increase: {
                guard shouldIncrease else { return .none }
                shouldIncrease.toggle()
                return .max(1)
            })
        }

        let s1 = makeSubscriber()
        [1,2,3].publisher.subscribe(s1)

        let s2 = makeSubscriber()
        SequencePublisher([1,2,3]).subscribe(s2)

        let expectation: [TestSubscriber<Int, Never>.Event] = [
            .subscription,
            .input(1),
            .input(2)
        ]

        XCTAssertEqual(s1.events, expectation)
        XCTAssertEqual(s2.events, expectation)
    }

    func testManualRequest() {

        let s1 = TestSubscriber<Int, Never>(demand: .none)
        [1,2,3].publisher.subscribe(s1)

        let s2 = TestSubscriber<Int, Never>(demand: .none)
        SequencePublisher([1,2,3]).subscribe(s2)

        var expectation: [TestSubscriber<Int, Never>.Event] = [
            .subscription,
        ]
        XCTAssertEqual(s1.events, expectation)
        XCTAssertEqual(s2.events, expectation)

        s1.subscriptions.forEach { $0.request(.max(1)) }
        s2.subscriptions.forEach { $0.request(.max(1)) }
        expectation.append(.input(1))
        XCTAssertEqual(s1.events, expectation)
        XCTAssertEqual(s2.events, expectation)

        s1.subscriptions.forEach { $0.request(.none) }
        s2.subscriptions.forEach { $0.request(.none) }
        XCTAssertEqual(s1.events, expectation)
        XCTAssertEqual(s2.events, expectation)

        s1.subscriptions.forEach { $0.request(.max(2)) }
        s2.subscriptions.forEach { $0.request(.max(2)) }
        expectation.append(.input(2))
        expectation.append(.input(3))
        expectation.append(.completion(.finished))
        XCTAssertEqual(s1.events, expectation)
        XCTAssertEqual(s2.events, expectation)
    }

    func testManualCancel() {

        let s1 = TestSubscriber<Int, Never>(demand: .none)
        [1,2,3].publisher.subscribe(s1)

        let s2 = TestSubscriber<Int, Never>(demand: .none)
        SequencePublisher([1,2,3]).subscribe(s2)

        var expectation: [TestSubscriber<Int, Never>.Event] = [
            .subscription,
        ]
        XCTAssertEqual(s1.events, expectation)
        XCTAssertEqual(s2.events, expectation)

        s1.subscriptions.forEach { $0.request(.max(1)) }
        s2.subscriptions.forEach { $0.request(.max(1)) }
        expectation.append(.input(1))
        XCTAssertEqual(s1.events, expectation)
        XCTAssertEqual(s2.events, expectation)

        s1.subscriptions.forEach { $0.cancel() }
        s2.subscriptions.forEach { $0.cancel() }
        XCTAssertEqual(s1.events, expectation)
        XCTAssertEqual(s2.events, expectation)

        s1.subscriptions.forEach { $0.request(.max(2)) }
        s2.subscriptions.forEach { $0.request(.max(2)) }
        XCTAssertEqual(s1.events, expectation)
        XCTAssertEqual(s2.events, expectation)
    }
}
