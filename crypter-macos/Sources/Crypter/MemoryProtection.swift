//
//  MemoryProtection.swift
//  Crypter - Memory protection and anti-forensics
//

import Foundation
import Darwin

/// Memory protection utilities for macOS
class MemoryProtection {
    
    /// Clears a block of memory to prevent forensic recovery
    /// - Parameter data: The data to clear
    static func secureClear(_ data: inout Data) {
        for i in 0..<data.count {
            data[i] = 0
        }
    }
    
    /// Sets memory protection flags for a specific memory range
    /// - Parameters:
    ///   - address: The starting address of the memory range
    ///   - length: The length of the memory range
    ///   - protection: The protection flags (e.g., PROT_READ, PROT_WRITE, PROT_EXEC)
    static func setMemoryProtection(address: UnsafeMutableRawPointer, length: Int, protection: Int32) -> Int32 {
        return mprotect(address, length, protection)
    }
}
