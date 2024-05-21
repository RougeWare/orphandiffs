//
//  Data + hex.swift
//
//
//  Created by Ky on 2024-05-10.
//

import Foundation



//public extension Data {
//    init<S: StringProtocol>(hexString: S) throws {
//        self.init(try hexString
//            .map { character in
//                guard
//                    let converted = UInt8(String(character), radix: 0x10),
//                    (0x0...0xF).contains(converted)
//                else {
//                    throw DataHexDecodingError.nonHexDigitFound(wholeString: .init(hexString))
//                }
//                return converted
//            }
//            .reduce(into: Data(capacity: hexString.count / 2)) { data, hexDigit in
//                let a = hexDigit / 0x10
//                let b = hexDigit % 0x10
//                return data + [a + (a < 0x0A ? 0x30 : 0x57),
//                               b + (b < 0x0A ? 0x30 : 0x57)]
//            }
//        )
//    }
//}
//
//
//
//public enum DataHexDecodingError: LocalizedError {
//    case nonHexDigitFound(wholeString: String)
//    
//    
//    public var errorDescription: String? {
//        switch self {
//        case .nonHexDigitFound(let wholeString):
//            "Found a non-hex digit when trying to parse string as hex: \(wholeString)"
//        }
//    }
//}
