import Foundation
import PrismAPI

extension Data {
    func toKotlinByteArray() -> KotlinByteArray {
        let result = KotlinByteArray(size: Int32(count))
        for index in indices {
            result.set(index: Int32(index), value: Int8(bitPattern: self[index]))
        }
        return result
    }
}

extension Array where Element == Int8 {
    func toKotlinByteArray() -> KotlinByteArray {
        let result = KotlinByteArray(size: Int32(count))
        for index in indices {
            result.set(index: Int32(index), value: self[index])
        }
        return result
    }
}

extension KotlinByteArray {
    func toData() -> Data {
        let kotlinByteArray = self
        var data = Data(count: Int(kotlinByteArray.size))
        for index in data.indices {
            data[index] = UInt8(bitPattern: kotlinByteArray.get(index: Int32(index)))
        }
        return data
    }
}
