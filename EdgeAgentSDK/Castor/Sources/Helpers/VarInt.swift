//
//  VarInt.swift
//  VarInt
//
//  Created by Teo on 01/10/15.
//  Licensed under MIT See LICENCE file in the root of this project for details.
//
/** This code provides "varint" encoding of 64-bit integers.
    It is based on the Go implementation of the Google Protocol Buffers
    varint specification.

    Varints are a method of serializing integers using one or more bytes.
    Smaller numbers take a smaller number of bytes.
    For more details see ipfs/QmXJXJMai4p88HMsp2TPP1EtZxfSZQ1vyRtN5dGKvQ6MCw

    The encoding is:
    -   Unsigned integers are serialized 7 bits at a time, starting with the
        least significant bits.

    -   The most significant bit (msb) in each output byte indicates if there
        is a continuation byte.

    -   Signed integers are mapped to unsigned integers using "zig-zag" encoding:
        Positive values x are written as 2*x + 0,
        Negative values x are written as 2*(~x) + 1
        So, negative values are complemented and whether to complement is encoded
        in bit 0.
*/
import Domain
import Foundation

enum VarIntError : Error {
    case inputStreamRead
    case overflow
}

/** putVarInt encodes a UInt64 into a buffer and returns it.
 */
func putUVarInt(_ value: UInt64) -> [UInt8] {
    var buffer = [UInt8]()
    var val: UInt64 = value

    while val >= 0x80 {
        buffer.append((UInt8(truncatingIfNeeded: val) | 0x80))
        val >>= 7
    }

    buffer.append(UInt8(val))
    return buffer
}

/** uVarInt decodes an UInt64 from a byte buffer and returns the value and the
    number of bytes greater than 0 that were read.
    If an error occurs the value will be 0 and the number of bytes n is <= 0
    with the following meaning:
        n == 0: buf too small
        n  < 0: value larger than 64 bits (overflow)
        and -n is the number of bytes read
 */
func uVarInt(_ buffer: [UInt8]) -> (UInt64, Int) {
    var output: UInt64 = 0
    var counter = 0
    var shifter:UInt64 = 0

    for byte in buffer {
        if byte < 0x80 {
            if counter > 9 || counter == 9 && byte > 1 {
                return (0, -(counter + 1))
            }
            return (output | UInt64(byte) << shifter, counter + 1)
        }

        output |= UInt64(byte & 0x7f) << shifter
        shifter += 7
        counter += 1
    }
    return (0, 0)
}

/** putVarInt encodes an Int64 into a buffer and returns it.
*/
func putVarInt(_ value: Int64) -> [UInt8] {
    let unsignedValue = UInt64(value) << 1

    return putUVarInt(unsignedValue)
}

/** varInt decodes an Int64 from a byte buffer and returns the value and the
    number of bytes greater than 0 that were read.
    If an error occurs the value will be 0 and the number of bytes n is <= 0
    with the following meaning:
         n == 0: buf too small
         n  < 0: value larger than 64 bits (overflow)
                 and -n is the number of bytes read
*/
func varInt(_ buffer: [UInt8]) -> (Int64, Int) {
    let (unsignedValue, bytesRead)  = uVarInt(buffer)
    var value                       = Int64(unsignedValue >> 1)

    if unsignedValue & 1 != 0 { value = ~value }

    return (value, bytesRead)
}

/** readUVarInt reads an encoded unsigned integer from the reader and returns
    it as an UInt64 */
func readUVarInt(_ reader: InputStream) throws -> UInt64 {
    var value: UInt64   = 0
    var shifter: UInt64 = 0
    var index = 0

    repeat {
        var buffer = [UInt8](repeating: 0, count: 10)

        if reader.read(&buffer, maxLength: 1) < 0 {
            throw VarIntError.inputStreamRead
        }

        let buf = buffer[0]

        if buf < 0x80 {
            if index > 9 || index == 9 && buf > 1 {
                throw VarIntError.overflow
            }
            return value | UInt64(buf) << shifter
        }
        value |= UInt64(buf & 0x7f) << shifter
        shifter += 7
        index += 1
    } while true
}

/** readVarInt reads an encoded signed integer from the reader and returns
    it as an Int64 */
func readVarInt(_ reader: InputStream) throws -> Int64 {
    let unsignedValue = try readUVarInt(reader)
    var value = Int64(unsignedValue >> 1)

    if unsignedValue & 1 != 0 {
        value = ~value
    }

    return value
}

/// Read and strip the unsigned variable int buffer size value from front of buffer
///
/// - Parameter buffer: The buffer prefixed with the size of the payload as an uvarint
/// - Returns: the size as an int64 and the buffer with the uvarint indicating size removed.
/// - Throws:
func uVarInt(buffer: [UInt8]) throws -> (UInt64, [UInt8]) {
    let (size, bytesRead) = uVarInt(buffer)
    guard
        bytesRead != 0,
        bytesRead >= 0
    else {
        throw UnknownError.somethingWentWrongError(
            customMessage: "VarInt error, invalid byte size",
            underlyingErrors: nil
        )
    }

    // Return the size as read from the uvarint and the buffer without the uvarint
    return (size, Array(buffer[bytesRead..<buffer.count]))
}
