//
//  sample_payload.swift
//  Sample malware payload for testing
//

import Foundation

class SamplePayload {
    
    func execute() {
        print("=== Sample Payload Executed ===")
        print("Payload loaded from memory")
        print("Execution time: \(Date())")
        print("=== Payload Complete ===")
    }
}
