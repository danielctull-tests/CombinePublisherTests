
import Combine

public struct ArrayPublisher<Output> {

    let array: [Output]
    public init(_ array: [Output]) {
        self.array = array
    }
}

extension ArrayPublisher: Publisher {

    public typealias Failure = Never
    public func receive<Subscriber>(subscriber: Subscriber) where Subscriber: Combine.Subscriber, Subscriber.Failure == Failure, Subscriber.Input == Output {
        let subscription = Subscription(subscriber: subscriber, array: array)
        subscriber.receive(subscription: subscription)
    }
}

extension ArrayPublisher {

    class Subscription<Subscriber> where Subscriber: Combine.Subscriber, Subscriber.Input == Output, Subscriber.Failure == Failure {

        let subscriber: Subscriber
        let array: [Output]
        private var cancelled = false
        private var index = 0
        private var demand = Subscribers.Demand.none

        init(subscriber: Subscriber, array: [Output]) {
            self.subscriber = subscriber
            self.array = array
        }
    }
}

extension ArrayPublisher.Subscription: Combine.Subscription {

    func request(_ additional: Subscribers.Demand) {

        guard !cancelled else { return }
        demand += additional

        while index < demand {

            demand += subscriber.receive(array[index])
            index += 1

            guard index < array.count else {
                subscriber.receive(completion: .finished)
                return
            }
        }
    }

    func cancel() {
        cancelled = true
    }
}
