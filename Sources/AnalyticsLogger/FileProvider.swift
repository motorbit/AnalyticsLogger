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
    
    func save(model: Model) {
        let fileURL = folderURL.appendingPathComponent("\(model.eventName!)_\(FileProvider.makeTimeStamp()).png")
        do {
            try model.image.write(to: fileURL)
        } catch {
            LogProvider.shared.log(error.localizedDescription)
        }
        addModelToCSV(model, fileURL: fileURL)
    }
    
    static func makeFolderURL() -> URL {
        var folderURL = URL(fileURLWithPath: CommandLine.arguments.first!)
        folderURL.deleteLastPathComponent()
        folderURL = folderURL.appendingPathComponent("Output")
        folderURL = folderURL.appendingPathComponent(makeFolderName())
        if !FileManager.default.fileExists(atPath: folderURL.absoluteString) {
            do {
                try FileManager.default.createDirectory(at: folderURL, withIntermediateDirectories: false, attributes: nil)
                let url = folderURL.appendingPathComponent("index.html")
                try? html.appendLineToURL(fileURL: url)
            } catch {
                LogProvider.shared.log(error.localizedDescription)
            }
        }
        return folderURL
    }
    
    func addModelToCSV(_ model: Model, fileURL: URL) {
        let str = "\(fileURL.lastPathComponent);\(model.eventName!);\(model.props!.replacingOccurrences(of: "\n", with: " "))"
        let csvPath = folderURL.appendingPathComponent("data.csv")
        if !FileManager.default.fileExists(atPath: csvPath.path) {
            let title = "Image;Event Name;Properties"
            try? title.appendLineToURL(fileURL: csvPath)
        }
        try? str.appendLineToURL(fileURL: csvPath)
    }
    
    static func makeFolderName() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "ddMMYYYhhmm"
        return formatter.string(from: Date())
    }
    
    static func makeTimeStamp() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM_dd_yyyy_hh_mm"
        return formatter.string(from: Date())
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


let html = """
    <!DOCTYPE html>
    <html lang="en">
        <head>
            <meta charset="utf-8">
            <style>
                table {
                    border-collapse: collapse;
                    border: 2px black solid;
                    font: 12px sans-serif;
                }

                td {
                    border: 1px black solid;
                    padding: 5px;
                }
            </style>
        </head>
        <body>
            <script src="http://d3js.org/d3.v3.min.js"></script>
            <!-- <script src="d3.js"></script> -->

            <script type="text/javascript"charset="utf-8">
                d3.text("data.csv", function(data) {
                    var parsedCSV = d3.dsv(";").parseRows(data);

                    var container = d3.select("body")
                        .append("table")

                        .selectAll("tr")
                            .data(parsedCSV).enter()
                            .append("tr")

                        .selectAll("td")
                        .data(function(d) { return d; }).enter()
                            .append("td")
                            
                d3.select("table")
                .selectAll("td").
                filter((d, i) => (i % 3 === 1) || i < 3)
                .style("vertical-align", "top")
                .text(function(d) { return d; })

                d3.select("table")
                .selectAll("td").
                filter((d, i) => (i % 3 === 2) && i != 2)
                .style("vertical-align", "top")
                .append("pre")
                .text(function(d) {
                 return d.replaceAll(" ", "").slice(1).slice(0,-1).split(",").join("\\n");
             })

                d3.select("table")
                .selectAll("td").
                filter((d, i) => (i % 3 === 0) && i != 0 ).append("img")
                            .attr('src', function(d) { return d;})
                            .attr('width',300)
                });
            </script>
        </body>
    </html>
"""
