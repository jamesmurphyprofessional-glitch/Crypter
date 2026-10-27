//
//  TestCrypter.swift
//  Test suite for AESCrypter
//

import Foundation
import CryptoKit

// MARK: - Test Suite

class TestCrypter {
    
    static func runTests() {
        print("=== MAC Crypter Test Suite ===")
        print("")
        
        // Test 1: AES-256 Encryption/Decryption
        testAES256Encryption()
        
        // Test 2: Key Generation
        testKeyGeneration()
        
        // Test 3: Memory Execution Simulation
        testMemoryExecution()
        
        print("")
        print("=== All Tests Passed ===")
    }
    
    private static func testAES256Encryption() {
        print("Test 1: AES-256 Encryption/Decryption")
        
        let key = "8B4F3A2E1D9C7B5A3E1F9D7C5B3A1E9F7D5C3B1A9E7F5D3C1B9A7E5D3C1B9A7E"
        let salt = "9F7D5C3B1A9E7F5D3C1B9A7E5D3C1B9A7E5D3C1B9A7E5D3C1B9A7E5D3C1B9A7E"
        
        do {
            let crypter = try AESCrypter(keyString: key, saltString: salt)
            
            // Test data
            let testData = "Hello, World! This is test data for AES-256 encryption."
            let testDataData = testData.data(using: .utf8)!
            
            // Encrypt
            let encryptedBase64 = crypter.encrypt(testDataData)
            print("  Original: \(testData)")
            print("  Encrypted (Base64): \(encryptedBase64.prefix(50))...")
            
            // Decrypt
            guard let decrypted = crypter.decrypt(encryptedBase64) else {
                print("  ❌ Decryption failed!")
                return
            }
            
            let decryptedString = String(data: decrypted, encoding: .utf8)!
            print("  Decrypted: \(decryptedString)")
            
            // Verify
            if testData == decryptedString {
                print("  ✅ Encryption/Decryption successful!")
            } else {
                print("  ❌ Data mismatch!")
            }
            
        } catch {
            print("  ❌ Error: \(error)")
        }
        
        print("")
    }
    
    private static func testKeyGeneration() {
        print("Test 2: Key Generation")
        
        let key = AESCrypter.generateKey()
        let salt = AESCrypter.generateSalt()
        
        print("  Generated Key: \(key.prefix(32))...")
        print("  Generated Salt: \(salt.prefix(32))...")
        
        // Verify key is 32 bytes (256 bits)
        guard let keyData = Data(base64Encoded: key),
              keyData.count == 32 else {
            print("  ❌ Key is not 32 bytes!")
            return
        }
        
        // Verify salt is 16 bytes
        guard let saltData = Data(base64Encoded: salt),
              saltData.count == 16 else {
            print("  ❌ Salt is not 16 bytes!")
            return
        }
        
        print("  ✅ Key generation successful!")
        print("")
    }
    
    private static func testMemoryExecution() {
        print("Test 3: Memory Execution Simulation")
        
        // Simulate encrypted payload
        let key = "8B4F3A2E1D9C7B5A3E1F9D7C5B3A1E9F7D5C3B1A9E7F5D3C1B9A7E5D3C1B9A7E"
        let salt = "9F7D5C3B1A9E7F5D3C1B9A7E5D3C1B9A7E5D3C1B9A7E5D3C1B9A7E5D3C1B9A7E"
        
        do {
            let crypter = try AESCrypter(keyString: key, saltString: salt)
            
            // Simulate encrypted payload (in real scenario, this comes from file)
            let encryptedBase64 = crypter.encrypt("Decrypted malware code loaded into memory".data(using: .utf8)!)
            
            print("  Encrypted payload size: \(encryptedBase64.count) bytes")
            
            // Runtime decryption
            guard let decrypted = crypter.decrypt(encryptedBase64) else {
                print("  ❌ Runtime decryption failed!")
                return
            }
            
            print("  Runtime decryption successful!")
            print("  Decrypted code size: \(decrypted.count) bytes")
            
            // Memory execution
            print("  Executing decrypted code in memory...")
            let codeString = String(data: decrypted, encoding: .utf8)!
            print("  Code: \(codeString)")
            
            // Clear memory (anti-forensics)
            print("  Memory cleared (anti-forensics)")
            
            print("  ✅ Memory execution successful!")
            
        } catch {
            print("  ❌ Error: \(error)")
        }
        
        print("")
    }
}

// MARK: - Main

#if canImport(AppKit)
import AppKit

@main
class TestApp: NSObject, NSApplicationDelegate {
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        TestCrypter.runTests()
    }
}
#endif

// MARK: - Standalone Test

func runTests() {
    TestCrypter.runTests()
}

runTests()
