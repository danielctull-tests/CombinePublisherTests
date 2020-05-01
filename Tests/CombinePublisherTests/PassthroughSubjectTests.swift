
import Combine
import CustomPublishers
import XCTest

final class PassthroughSubjectTests: XCTestCase {

    func testUnlimited() {

        let p1 = Combine.PassthroughSubject<Int, Never>()
        let s1 = TestSubscriber<Int, Never>(demand: .unlimited)
        p1.subscribe(s1)

        let p2 = Combine.PassthroughSubject<Int, Never>()
        let s2 = TestSubscriber<Int, Never>(demand: .unlimited)
        p2.subscribe(s2)

        var expectation: [TestSubscriber<Int, Never>.Event] = [
            .subscription
        ]

        XCTAssertEqual(s1.events, expectation)
        XCTAssertEqual(s2.events, expectation)

        p1.send(0)
        p2.send(0)
        expectation.append(.input(0))
        XCTAssertEqual(s1.events, expectation)
        XCTAssertEqual(s2.events, expectation)

        p1.send(completion: .finished)
        p2.send(completion: .finished)
        expectation.append(.completion(.finished))
        XCTAssertEqual(s1.events, expectation)
        XCTAssertEqual(s2.events, expectation)
    }

    func testNone() {

        let p1 = Combine.PassthroughSubject<Int, Never>()
        let s1 = TestSubscriber<Int, Never>(demand: .none)
        p1.subscribe(s1)

        let p2 = Combine.PassthroughSubject<Int, Never>()
        let s2 = TestSubscriber<Int, Never>(demand: .none)
        p2.subscribe(s2)

        var expectation: [TestSubscriber<Int, Never>.Event] = [
            .subscription
        ]
        XCTAssertEqual(s1.events, expectation)
        XCTAssertEqual(s2.events, expectation)

        p1.send(0)
        p2.send(0)
        XCTAssertEqual(s1.events, expectation)
        XCTAssertEqual(s2.events, expectation)

        p1.send(completion: .finished)
        p2.send(completion: .finished)
        expectation.append(.completion(.finished))
        XCTAssertEqual(s1.events, expectation)
        XCTAssertEqual(s2.events, expectation)
    }

    func testOne() {

        let p1 = Combine.PassthroughSubject<Int, Never>()
        let s1 = TestSubscriber<Int, Never>(demand: .max(1))
        p1.subscribe(s1)

        let p2 = Combine.PassthroughSubject<Int, Never>()
        let s2 = TestSubscriber<Int, Never>(demand: .max(1))
        p2.subscribe(s2)

        var expectation: [TestSubscriber<Int, Never>.Event] = [
            .subscription
        ]
        XCTAssertEqual(s1.events, expectation)
        XCTAssertEqual(s2.events, expectation)

        p1.send(0)
        p2.send(0)
        expectation.append(.input(0))
        XCTAssertEqual(s1.events, expectation)
        XCTAssertEqual(s2.events, expectation)

        p1.send(1)
        p2.send(1)
        XCTAssertEqual(s1.events, expectation)
        XCTAssertEqual(s2.events, expectation)

        p1.send(completion: .finished)
        p2.send(completion: .finished)
        expectation.append(.completion(.finished))
        XCTAssertEqual(s1.events, expectation)
        XCTAssertEqual(s2.events, expectation)
    }
}
