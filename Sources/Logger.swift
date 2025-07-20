//
//  Logger.swift
//  XprojGen
//
//  Created by Akihiro Matsuyama on 2025/07/20.
//

import Foundation

protocol LoggerProtocol {
    static func info(_ message: String)
    static func success(_ message: String)
    static func warning(_ message: String)
    static func error(_ message: String)
    static func debug(_ message: String)
}

struct Logger: LoggerProtocol {

    static func info(_ message: String)    { log(.info, message) }
    static func success(_ message: String) { log(.success, message) }
    static func warning(_ message: String) { log(.warning, message) }
    static func error(_ message: String)   { log(.error, message) }
    static func debug(_ message: String)   { log(.debug, message) }
    
    private enum LogLevel: String {
        case info = " [INFO] "
        case success = " [SUCCESS] "
        case warning = " [WARNING] "
        case error = " [ERROR] "
        case debug = " [DEBUG] "
    }
    
    private enum ANSIColor: String {
        case reset  = "\u{001B}[0m"
        case red    = "\u{001B}[31m"
        case green  = "\u{001B}[32m"
        case yellow = "\u{001B}[33m"
        case blue   = "\u{001B}[34m"
        case cyan   = "\u{001B}[36m"

        static func forLevel(_ level: LogLevel) -> ANSIColor {
            switch level {
            case .info: return .blue
            case .success: return .green
            case .warning: return .yellow
            case .error: return .red
            case .debug: return .cyan
            }
        }
    }

    private static func log(_ level: LogLevel, _ message: String) {
        let color = ANSIColor.forLevel(level).rawValue
        let timestamp = ISO8601DateFormatter().string(from: Date())
        print("\(color)\(timestamp) \(level.rawValue) \(message)\(ANSIColor.reset.rawValue)")
    }
}
