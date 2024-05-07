import ApolloLibrary
import Foundation

extension Array where Element: AnyObject {
    /// Allows conversion from `KotlinArray` to `Array`
    public init(_ array: KotlinArray<Element>) {
        self.init()
        self.reserveCapacity(Int(array.size))
        let iterator = array.iterator()
        while iterator.hasNext() {
            guard let element = iterator.next() as? Element else { return }
            self.append(element)
        }
    }
}
