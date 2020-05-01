
import Combine
import CustomPublishers
import XCTest

final class EmptyPublisherTests: XCTestCase {

    func testCompleteImmediatelyFalse() {

        let s1 = TestSubscriber<Int, Never>(demand: .unlimited)
        Empty<Int, Never>(completeImmediately: false).subscribe(s1)

        let s2 = TestSubscriber<Int, Never>(demand: .unlimited)
        EmptyPublisher<Int, Never>(completeImmediately: false).subscribe(s2)

        let expectation: [TestSubscriber<Int, Never>.Event] = [
            .subscription
        ]

        XCTAssertEqual(s1.events, expectation)
        XCTAssertEqual(s2.events, expectation)
    }

    func testCompleteImmediatelyTrue() {

        let s1 = TestSubscriber<Int, Never>(demand: .unlimited)
        Empty<Int, Never>(completeImmediately: true).subscribe(s1)

        let s2 = TestSubscriber<Int, Never>(demand: .unlimited)
        EmptyPublisher<Int, Never>(completeImmediately: true).subscribe(s2)

        let expectation: [TestSubscriber<Int, Never>.Event] = [
            .subscription,
            .completion(.finished)
        ]

        XCTAssertEqual(s1.events, expectation)
        XCTAssertEqual(s2.events, expectation)
    }

    func testCompleteImmediatelyFalseWithRequest() {

        let s1 = TestSubscriber<Int, Never>(demand: .unlimited)
        Empty<Int, Never>(completeImmediately: false).subscribe(s1)

        let s2 = TestSubscriber<Int, Never>(demand: .unlimited)
        EmptyPublisher<Int, Never>(completeImmediately: false).subscribe(s2)

        let expectation: [TestSubscriber<Int, Never>.Event] = [
            .subscription
        ]

        XCTAssertEqual(s1.events, expectation)
        XCTAssertEqual(s2.events, expectation)

        s1.subscriptions.forEach { $0.request(.unlimited) }
        s2.subscriptions.forEach { $0.request(.unlimited) }

        XCTAssertEqual(s1.events, expectation)
        XCTAssertEqual(s2.events, expectation)
    }
}
