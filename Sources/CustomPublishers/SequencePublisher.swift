
import Combine

public struct SequencePublisher<Sequence, Output> where Sequence: Swift.Sequence, Sequence.Element == Output {

    let sequence: Sequence
    public init(_ sequence: Sequence) {
        self.sequence = sequence
    }
}

extension SequencePublisher: Publisher {

    public typealias Failure = Never
    public func receive<Subscriber>(subscriber: Subscriber) where Subscriber: Combine.Subscriber, Subscriber.Failure == Failure, Subscriber.Input == Output {
        let subscription = Subscription(subscriber: subscriber, sequence: sequence)
        subscriber.receive(subscription: subscription)
    }
}

extension SequencePublisher {

    class Subscription<Subscriber> where Subscriber: Combine.Subscriber, Subscriber.Input == Output, Subscriber.Failure == Failure {

        private let subscriber: Subscriber
        private var iterator: Sequence.Iterator
        private var cancelled = false
        private var next: Output?
        private var demand = Subscribers.Demand.none

        init(subscriber: Subscriber, sequence: Sequence) {
            self.subscriber = subscriber
            iterator = sequence.makeIterator()
            next = iterator.next()
        }
    }
}

extension SequencePublisher.Subscription: Combine.Subscription {

    func request(_ additional: Subscribers.Demand) {

        guard !cancelled else { return }
        demand += additional

        while demand > 0 {

            if let output = next {
                demand += subscriber.receive(output)
                demand -= 1
                next = iterator.next()
            }

            // This can't be an else, because it needs to be reevaluated after
            // the potential assignment of the next element.
            if next == nil {
                subscriber.receive(completion: .finished)
                return
            }
        }
    }

    func cancel() {
        cancelled = true
    }
}
