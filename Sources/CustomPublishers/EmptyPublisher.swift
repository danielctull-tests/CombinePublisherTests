
import Combine

public struct EmptyPublisher<Output, Failure: Error> {

    private let completeImmediately: Bool
    public init(completeImmediately: Bool) {
        self.completeImmediately = completeImmediately
    }
}

extension EmptyPublisher: Publisher {

    public func receive<Subscriber>(subscriber: Subscriber) where Subscriber: Combine.Subscriber, Subscriber.Failure == Failure, Subscriber.Input == Output {
        let subscription = Subscription(subscriber: subscriber, completeImmediately: completeImmediately)
        subscriber.receive(subscription: subscription)
    }
}

extension EmptyPublisher {

    class Subscription<Subscriber> where Subscriber: Combine.Subscriber, Subscriber.Input == Output, Subscriber.Failure == Failure {

        private let subscriber: Subscriber
        private let completeImmediately: Bool

        init(subscriber: Subscriber, completeImmediately: Bool) {
            self.subscriber = subscriber
            self.completeImmediately = completeImmediately
        }
    }
}

extension EmptyPublisher.Subscription: Combine.Subscription {

    func request(_ additional: Subscribers.Demand) {
        guard completeImmediately else { return }
        subscriber.receive(completion: .finished)
    }

    func cancel() {}
}
