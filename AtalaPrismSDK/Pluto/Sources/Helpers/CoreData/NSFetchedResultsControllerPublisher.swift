import Combine
import CoreData
import Foundation

private class FetchedResultsSubscriber<S: Subscriber>:
    NSObject, Subscription, NSFetchedResultsControllerDelegate
    where S.Input == [NSFetchRequestResult], S.Failure == Error
{
    private let context: NSManagedObjectContext
    private let request: NSFetchRequest<NSFetchRequestResult>
    private let controller: NSFetchedResultsController<NSFetchRequestResult>
    private var cache: [NSFetchRequestResult] = []
    private var didFetch = false
    private var subscriber: S?
    private var error: Error?

    init(context: NSManagedObjectContext, request: NSFetchRequest<NSFetchRequestResult>, subscriber: S?) {
        self.context = context
        self.request = request
        self.subscriber = subscriber
        controller = NSFetchedResultsController(
            fetchRequest: self.request,
            managedObjectContext: self.context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        super.init()
        controller.delegate = self
    }

    func request(_ demand: Subscribers.Demand) {
        if let subscriber = subscriber, !didFetch {
            fetch()
            didFetch = true
            if let error = error {
                subscriber.receive(completion: .failure(error))
            } else {
                let cache = self.cache
                context.performAndWait {
                    _ = subscriber.receive(cache)
                }
            }
        }
    }

    func cancel() {
        subscriber = nil
    }

    // TODO: Look why the FetchResultController fetch and the ManageObjectContext save is sometimes blocks.
    private func fetch() {
        context.performAndWait { [weak self] in
            guard let self = self else { return }
            do {
                try self.controller.performFetch()

                self.cache = self.controller.fetchedObjects ?? []
            } catch {
                self.error = error
            }
        }
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        guard let objects = controller.fetchedObjects as? [NSManagedObject] else { return }
        cache = objects
        if let error = error {
            subscriber?.receive(completion: .failure(error))
        } else {
            _ = subscriber?.receive(cache)
        }
    }

    func controller(
        _ controller: NSFetchedResultsController<NSFetchRequestResult>,
        didChange anObject: Any,
        at indexPath: IndexPath?,
        for type: NSFetchedResultsChangeType,
        newIndexPath: IndexPath?
    ) {
        guard let objects = controller.fetchedObjects as? [NSManagedObject] else { return }
        cache = objects
        if let error = error {
            subscriber?.receive(completion: .failure(error))
        } else {
            _ = subscriber?.receive(cache)
        }
    }
}

extension Publishers {
    struct FetchedResultsPublisher: Publisher {
        typealias Output = [NSFetchRequestResult]
        typealias Failure = Error

        private let context: NSManagedObjectContext
        private let request: NSFetchRequest<NSFetchRequestResult>

        init(context: NSManagedObjectContext, request: NSFetchRequest<NSFetchRequestResult>) {
            self.request = request
            self.context = context
        }

        func receive<S: Subscriber>(subscriber: S) where
            FetchedResultsPublisher.Failure == S.Failure, FetchedResultsPublisher.Output == S.Input
        {
            let subscription = FetchedResultsSubscriber(
                context: context,
                request: request,
                subscriber: subscriber
            )
            subscriber.receive(subscription: subscription)
        }
    }
}

extension NSManagedObjectContext {
    func fetchPublisher(request: NSFetchRequest<NSFetchRequestResult>) -> Publishers.FetchedResultsPublisher {
        return Publishers.FetchedResultsPublisher(context: self, request: request)
    }
}
