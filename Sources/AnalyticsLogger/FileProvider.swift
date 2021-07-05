//
//  FileProvider.swift
//  mqttLogger
//
//  Created by Anton Makarov on 01.07.2021.
//

import Foundation

class FileProvider {
    
    static let shared = FileProvider()
    let folderURL = makeFolderURL()
    private static let fm = FileManager.default
    
    func save(model: Model) {
        var model = model
        let fileURL = folderURL.appendingPathComponent("\(model.eventName!)_\(FileProvider.makeTimeStamp()).png")
        do {
            if let data = model.image {
                try data.write(to: fileURL)
            }
            model.imagePath = fileURL.lastPathComponent
            model.image = nil
        } catch {
            LogProvider.shared.log(error.localizedDescription)
        }
        let htmlPath = folderURL.appendingPathComponent("index.html")
        let previousHtml = try? String(contentsOf: htmlPath)
        let html = HTMLGenerator.shared.save(html: previousHtml, model: model)
        do {
            let data = html.data(using: String.Encoding.utf8)!
            try data.write(to: htmlPath, options: .atomic)
        } catch {
            print(error)
        }
    }
    
    static func makeFolderURL() -> URL {
        var folderURL = URL(fileURLWithPath: CommandLine.arguments.first!)
        folderURL.deleteLastPathComponent()
        folderURL = makeOutput(folderURL)
        folderURL = folderURL.appendingPathComponent(makeTimeStamp())
        if !fm.directoryExists(atUrl: folderURL) {
            do {
                try FileManager.default.createDirectory(at: folderURL, withIntermediateDirectories: false, attributes: nil)
            } catch {
                LogProvider.shared.log(error.localizedDescription)
            }
        }
        return folderURL
    }
    
    private static func makeOutput(_ path: URL) -> URL {
        var url = path
        url = url.appendingPathComponent("Output")
        if !fm.directoryExists(atUrl: url) {
            try? fm.createDirectory(at: url, withIntermediateDirectories: false, attributes: nil)
        }
        return url
    }
    
    static func makeTimeStamp() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd_MM_YYY_hh_mm"
        return formatter.string(from: Date())
    }
}

