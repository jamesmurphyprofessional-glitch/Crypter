//
//  AntiDetection.swift
//  Crypter - Anti-debugging and Anti-VM detection
//

import Foundation
import MachO

/// Anti-detection utilities for macOS
class AntiDetection {
    
    /// Checks if a debugger is attached to the process
    /// - Returns: True if a debugger is detected
    static func isDebuggerAttached() -> Bool {
        var info = kinfo_proc()
        var size = MemoryLayout<kinfo_proc>.size
        let machPort = mach_msg_type_number_t(MemoryLayout<kinfo_proc>.size / MemoryLayout<integer_t>.size)
        
        let result = proc_pidinfo(getpid(), PROC_PID_INFO, &info, &size, machPort)
        if result == KERN_SUCCESS {
            return info.kp_proc.p_flag & P_TRACED != 0
        }
        return false
    }
    
    /// Checks if the process is running in a virtual machine or sandbox
    /// - Returns: True if a VM or sandbox is detected
    static func isRunningInVM() -> Bool {
        // Check for common VM indicators
        let vmIndicators = [
            "VMware", "VirtualBox", "QEMU", "Parallels", "Citrix", "Hyper-V"
        ]
        
        for indicator in vmIndicators {
            if let hostName = Host.current().localizedName, hostName.contains(indicator) {
                return true
            }
        }
        
        // Check for specific hardware identifiers
        let cpuInfo = ProcessInfo.processInfo.processorCount
        if cpuInfo < 2 {
            return true
        }
        
        return false
    }
    
    /// Performs a series of anti-debugging and anti-VM checks
    /// - Returns: True if any detection triggers
    static func performChecks() -> Bool {
        if isDebuggerAttached() {
            print("Debugger detected!")
            return true
        }
        
        if isRunningInVM() {
            print("VM detected!")
            return true
        }
        
        return false
    }
}
