//
//  AESCrypter.swift
//  Crypter Framework - AES-256 Encryption/Decryption
//
//  Native macOS crypter with runtime decryption and memory execution
//

import Foundation
import CryptoKit

/// AES-256 Crypter for macOS
/// Provides runtime decryption of encrypted payloads
class AESCrypter {
    
    /// AES-256 key (32 bytes)
    private let key: SymmetricKey
    
    /// Initialize with a 256-bit key
    /// - Parameters:
    ///   - keyString: Base64-encoded 32-byte key
    init(keyString: String) throws {
        guard let keyData = Data(base64Encoded: keyString) else {
            throw CrypterError.invalidKey
        }
        
        self.key = SymmetricKey(data: keyData)
    }
    
    /// Encrypt data using AES-256-GCM
    /// - Parameter plaintext: Data to encrypt
    /// - Returns: Base64-encoded ciphertext with nonce prepended
    func encrypt(_ plaintext: Data) throws -> String {
        // Generate cryptographically secure random nonce (12 bytes for GCM)
        var nonceBytes = [UInt8](repeating: 0, count: 12)
        let status = SecRandomCopyBytes(kSecRandomDefault, 12, &nonceBytes)
        guard status == errSecSuccess else {
            throw CrypterError.encryptionFailed
        }
        
        let nonce = try AES.GCM.Nonce(data: Data(nonceBytes))
        let sealed = try AES.GCM.seal(plaintext, using: key, nonce: nonce)
        
        // Combine nonce + ciphertext + tag
        let nonceData = Data(nonceBytes)
        let combined = nonceData + sealed.combined!
        return combined.base64EncodedString()
    }
    
    /// Decrypt data using AES-256-GCM
    /// - Parameter ciphertext: Base64-encoded ciphertext
    /// - Returns: Decrypted plaintext
    func decrypt(_ ciphertext: String) -> Data? {
        guard let combinedData = Data(base64Encoded: ciphertext) else {
            return nil
        }
        
        // First 12 bytes are nonce
        guard combinedData.count >= 28 else {
            return nil
        }
        
        let nonceData = combinedData.prefix(12)
        let encryptedData = combinedData.suffix(from: 12)
        
        do {
            let sealedBox = try AES.GCM.SealedBox(combined: encryptedData)
            let decrypted = try AES.GCM.open(sealedBox, using: key)
            return decrypted
        } catch {
            return nil
        }
    }
    
    /// Generate a random 256-bit key
    static func generateKey() -> String {
        var keyBytes = [UInt8](repeating: 0, count: 32)
        let status = SecRandomCopyBytes(kSecRandomDefault, 32, &keyBytes)
        guard status == errSecSuccess else {
            return Data(count: 32).base64EncodedString()
        }
        let key = Data(keyBytes)
        return key.base64EncodedString()
    }
}

enum CrypterError: Error {
    case invalidKey
    case decryptionFailed
    case encryptionFailed
}
