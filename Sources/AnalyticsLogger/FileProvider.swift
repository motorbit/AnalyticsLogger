//
//  FileProvider.swift
//  mqttLogger
//
//  Created by Anton Makarov on 01.07.2021.
//

import Foundation

class FileProvider {
    
    static let shared = FileProvider()
    private let fm = FileManager.default
    
    func save(clientID: String, model: Model) {
        var model = model
        let folderURL = makeFolderURL(clientId: clientID)
        let fileURL = folderURL.appendingPathComponent("\(model.eventName!)_\(makeTimeStamp()).png")
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
    
    func makeFolderURL(clientId: String) -> URL {
        var folderURL = URL(fileURLWithPath: CommandLine.arguments.first!)
        folderURL.deleteLastPathComponent()
        folderURL = makeOutput(folderURL)
        folderURL = makeClientFolder(folderURL, clientId: clientId)
        return folderURL
    }
    
    func makeOutput(_ path: URL) -> URL {
        var url = path
        url = url.appendingPathComponent("Output")
        if !fm.directoryExists(atUrl: url) {
            try? fm.createDirectory(at: url, withIntermediateDirectories: false, attributes: nil)
        }
        return url
    }
    
    func makeClientFolder(_ path: URL, clientId: String) -> URL {
        var url = path
        url = url.appendingPathComponent(clientId)
        if !fm.directoryExists(atUrl: url) {
            try? fm.createDirectory(at: url, withIntermediateDirectories: false, attributes: nil)
        }
        return url
    }
    
    func makeTimeStamp() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd_MM_YYY_hh_mm"
        return formatter.string(from: Date())
    }
}

