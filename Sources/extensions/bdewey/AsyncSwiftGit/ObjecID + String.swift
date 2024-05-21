//
//  ObjecID + String.swift
//
//
//  Created by Ky on 2024-05-10.
//

//import Foundation

//import SwiftLibgit2
//import Clibgit2



//public extension ObjectID {
//    init(_ string: String) throws {
//        var buffer: UnsafeMutableBufferPointer<git_oid> = .allocate(capacity: 20)
//        
//        guard try 20 == Data(hexString: string).copyBytes(to: buffer) else {
//            throw FromStringError.wrongByteLength(fromString: string)
//        }
//        
//        let oidPointer: UnsafePointer<git_oid>? = buffer.baseAddress?.pointer(to: \.self)
//        
//        self.init(oidPointer)
//    }
//    
//    
//    
//    enum FromStringError: LocalizedError {
//        case wrongByteLength(fromString: String)
//        
//        
//        public var errorDescription: String? {
//            switch self {
//            case .wrongByteLength(fromString: let string):
//                "Couldn't convert given string into a Git object ID because it wasn't the corrent length: \(string)"
//            }
//        }
//    }
//}
