import Combine
import CoreData
import Foundation

private class WriteContextSubscriber<S: Subscriber, T>: NSObject, Subscription where S.Input == T, S.Failure == Error {
    private let context: NSManagedObjectContext
    private let saveBlock: (NSManagedObjectContext) throws -> T
    private var subscriber: S?
    private var isRunning = false

    init(
        context: NSManagedObjectContext,
        subscriber: S?,
        saveBlock: @escaping (NSManagedObjectContext) throws -> T
    ) {
        self.saveBlock = saveBlock
        self.context = context
        self.subscriber = subscriber
        super.init()
    }

    func request(_ demand: Subscribers.Demand) {
        while let subscriber = subscriber, demand > 0, isRunning == false {
            perform(subscriber)
        }
    }

    func cancel() {
        subscriber = nil
    }

    private func perform(_ subscriber: S) {
        isRunning = true
        do {
            var result: T?
            try context.saveWithBlock {
                result = try self.saveBlock($0)
            }
            result.map { _ = subscriber.receive($0) }
            subscriber.receive(completion: .finished)
        } catch {
            subscriber.receive(completion: .failure(error))
        }
    }
}

extension Publishers {
    struct WriteContextPublisher<T>: Publisher {
        typealias Output = T
        typealias Failure = Error

        private let context: NSManagedObjectContext
        private let saveBlock: (NSManagedObjectContext) throws -> T

        init(context: NSManagedObjectContext, saveBlock: @escaping (NSManagedObjectContext) throws -> T) {
            self.saveBlock = saveBlock
            self.context = context
        }

        func receive<S: Subscriber>(
            subscriber: S
        ) where WriteContextPublisher.Failure == S.Failure, WriteContextPublisher.Output == S.Input {
            let subscription = WriteContextSubscriber(
                context: context,
                subscriber: subscriber,
                saveBlock: saveBlock
            )
            subscriber.receive(subscription: subscription)
        }
    }
}

extension NSManagedObjectContext {
    func write<T>(_ saveBlock: @escaping (NSManagedObjectContext) throws -> T) -> Publishers.WriteContextPublisher<T> {
        return Publishers.WriteContextPublisher(context: self, saveBlock: saveBlock)
    }
}
