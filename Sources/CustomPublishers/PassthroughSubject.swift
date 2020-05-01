
import Combine

final public class PassthroughSubject<Output, Failure: Error> {
    private var subscriptions: [Subscription] = []
    public init() {}
}

extension PassthroughSubject: Publisher {

    public func receive<Subscriber>(subscriber: Subscriber) where Subscriber: Combine.Subscriber, Subscriber.Failure == Failure, Subscriber.Input == Output {
        let subscription = Subscription(subscriber: AnySubscriber(subscriber))
        subscriber.receive(subscription: subscription)
        subscriptions.append(subscription)
    }
}

extension PassthroughSubject {

    class Subscription {
        private var cancelled = false
        private let subscriber: AnySubscriber<Output, Failure>
        private var demand = Subscribers.Demand.none
        init(subscriber: AnySubscriber<Output, Failure>) {
            self.subscriber = subscriber
        }
    }
}

extension PassthroughSubject.Subscription: Combine.Subscription {

    func request(_ additional: Subscribers.Demand) {
        demand += additional
    }

    func cancel() {
        cancelled = true
    }
}

extension PassthroughSubject.Subscription {

    func send(_ input: Output) {
        guard demand > 0 else { return }
        demand += subscriber.receive(input)
        demand -= 1
    }

    func send(completion: Subscribers.Completion<Failure>) {
        subscriber.receive(completion: completion)
    }
}

extension PassthroughSubject: Subject {

    public func send(_ input: Output) {
        subscriptions.forEach { $0.send(input) }
    }

    public func send(completion: Subscribers.Completion<Failure>) {
        subscriptions.forEach { $0.send(completion: completion) }
    }

    public func send(subscription: Combine.Subscription) {
    }
}
