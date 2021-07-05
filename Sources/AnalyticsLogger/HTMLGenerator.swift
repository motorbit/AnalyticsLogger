//
//  File.swift
//  
//
//  Created by Anton Makarov on 05.07.2021.
//

import Foundation

final class HTMLGenerator {
    
    static let shared = HTMLGenerator()
    
    func save(html: String?, model: Model) -> String {
        let html = html ?? template
        let range = html.range(of: "</table>")
        let firstPart = html[html.startIndex..<range!.lowerBound]
        let secondPart = html[range!.lowerBound..<html.endIndex]
        let line = makeLine(model: model)
        return firstPart + line + secondPart
    }
    
    private func makeLine(model: Model) -> String {
        var result = "<tr>"
        if let path = model.imagePath {
            result += "<td><img src=\(path) width='300'></td>"
        } else {
            result += "<tr><td><img width='300'></td>"
        }
        if let eventName = model.eventName {
            result += "<td style='vertical-align: top;'>\(eventName)</td>"
        } else {
            result += "<td style='vertical-align: top;'></td>"
        }
        if let props = model.props {
        result += "<td style='vertical-align: top;'><pre>\(props)</pre></td></tr>"
        } else {
            result += "<td style='vertical-align: top;'><pre></pre></td></tr>"
        }
        return result
    }
    
    private lazy var template: String = {
        return """
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
                    <table>
                    <tr>
                        <td style="vertical-align: top;">Image</td>
                        <td style="vertical-align: top;">Event Name</td>
                        <td style="vertical-align: top;">Properties</td>
                    </tr>
                    </table>
                    </body>
                    </html>
            """
    }()
}
