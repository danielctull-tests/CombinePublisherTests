
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

        let subscriber: Subscriber
        let sequence: [Output]
        private var cancelled = false
        private var index = 0
        private var demand = Subscribers.Demand.none

        init(subscriber: Subscriber, sequence: Sequence) {
            self.subscriber = subscriber
            self.sequence = Array(sequence)
        }
    }
}

extension SequencePublisher.Subscription: Combine.Subscription {

    func request(_ additional: Subscribers.Demand) {

        guard !cancelled else { return }
        demand += additional

        while index < demand {

            demand += subscriber.receive(sequence[index])
            index += 1

            guard index < sequence.count else {
                subscriber.receive(completion: .finished)
                return
            }
        }
    }

    func cancel() {
        cancelled = true
    }
}
