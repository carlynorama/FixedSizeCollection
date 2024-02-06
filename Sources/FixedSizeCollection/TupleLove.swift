//
//  File.swift
//  
//
//  Created by Carlyn Maw on 2/6/24.
//

import Foundation


extension FixedSizeCollection {
    
    
    internal func _loadIntoTuple<U>(tuple: inout U, count:N, type:N.Type) throws {
        precondition(count == self.count)
        precondition(type == Element.self)
        precondition(MemoryLayout.size(ofValue: tuple) == MemoryLayout<N>.stride * count)

        Swift.withUnsafeMutablePointer(to: &tuple) { tuplePointer in
            precondition(Int(bitPattern: tuplePointer).isMultiple(of: MemoryLayout<N>.alignment))
            tuplePointer.withMemoryRebound(to: Element.self, capacity: count) { reboundPointer in
                let bufferPointer = UnsafeMutableBufferPointer(start: UnsafeMutablePointer(reboundPointer), count: count)
                for i in stride(from: bufferPointer.startIndex, to: bufferPointer.endIndex, by: 1) {
                    bufferPointer[i] = self[i]
                }
            }
            
        }
    }
    
    //YOLO.
    //Don't use this.
    internal func _memCopyToTuple<U>(tuple: inout U, count:Int, type:N.Type) throws {
        precondition(count == self.count)
        precondition(type == Element.self)
        precondition(MemoryLayout.size(ofValue: tuple) == MemoryLayout<N>.stride * count)
        precondition(MemoryLayout.size(ofValue: tuple) == MemoryLayout<N>.stride * self.count)
        
        try Swift.withUnsafeMutablePointer(to: &tuple) { tuplePointer in
            precondition(Int(bitPattern: tuplePointer).isMultiple(of: MemoryLayout<N>.alignment))
            let _ = try self.withUnsafeBufferPointer { bufferPointer in
                memcpy(tuplePointer, bufferPointer?.baseAddress, count * MemoryLayout<N>.stride)
            }
            
        }
    }
    
    
}
