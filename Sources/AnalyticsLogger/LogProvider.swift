//
//  File.swift
//  
//
//  Created by Anton Makarov on 04.07.2021.
//

import Foundation

final class LogProvider {
    
    static let shared = LogProvider()
    private let folderURL = makeFolderURL()
    
    func log(_ text: String) {
        print(text)
        saveToFile(text)
    }
    
    private func saveToFile(_ text: String) {
        let url = folderURL.appendingPathComponent("AnalyticsLogger.log")
        try? "[\(timeStamp)] \(text)".appendLineToURL(fileURL: url)
    }
    
    private static func makeFolderURL() -> URL {
        var folderURL = URL(fileURLWithPath: CommandLine.arguments.first!)
        folderURL.deleteLastPathComponent()
        folderURL = folderURL.appendingPathComponent("Logs")
        if !FileManager.default.directoryExists(atUrl: folderURL) {
            do {
                try FileManager.default.createDirectory(at: folderURL, withIntermediateDirectories: false, attributes: nil)
            } catch {
                print(error)
            }
        }
        return folderURL
    }
    
    var timeStamp: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy mm:hh:ss"
        return formatter.string(from: Date())
    }
}

extension FileManager {

    func directoryExists(atUrl url: URL) -> Bool {
        var isDirectory: ObjCBool = false
        let exists = self.fileExists(atPath: url.path, isDirectory:&isDirectory)
        return exists && isDirectory.boolValue
    }
}

extension Data {
     func append(fileURL: URL) throws {
         if let fileHandle = FileHandle(forWritingAtPath: fileURL.path) {
             defer {
                 fileHandle.closeFile()
             }
             fileHandle.seekToEndOfFile()
             fileHandle.write(self)
         }
         else {
             try write(to: fileURL, options: .atomic)
         }
     }
 }

extension String {
    func appendLineToURL(fileURL: URL) throws {
         try (self + "\n").appendToURL(fileURL: fileURL)
     }

     func appendToURL(fileURL: URL) throws {
         let data = self.data(using: String.Encoding.utf8)!
         try data.append(fileURL: fileURL)
     }
 }
