//
//  MQTTClient.swift
//  mqttLogger
//
//  Created by Anton Makarov on 01.07.2021.
//

import Foundation
import MQTTNIO

class Client {
    
    static var host: String {
        if CommandLine.arguments.count > 1 {
            let value = CommandLine.arguments[1]
            return value
        }
        return "localhost"
    }
    
    static var conifg: MQTTConfiguration {
        let host = host
        LogProvider.shared.log("Trying to connect to: \(host)")
        return MQTTConfiguration(target: .host(host, port: 1883))
    }
    
    let mqtt = MQTTClient(configuration: conifg,eventLoopGroupProvider: .createNew)
    
    static let shared = Client()
    
    init() {
        mqtt.subscribe(to: "Analytics/+")
        mqtt.whenConnected { response in
            LogProvider.shared.log("Connected to: \(self.mqtt.configuration.target)")
        }
        mqtt.whenDisconnected { reason in
            LogProvider.shared.log("Disconnected")
        }
        mqtt.whenMessage { message in
            guard let str = message.payload.string,
                  let model = try? JSONDecoder().decode(Model.self, from: Data(str.utf8))
            else { return }
            LogProvider.shared.log("Received: \(model)")
            FileProvider.shared.save(model: model)
        }
        mqtt.connect()
    }
}


struct Model: Codable {
    let image: Data
    let props: String?
    let eventName: String?
}
