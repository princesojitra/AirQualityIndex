//
//  AQICityAPIService.swift
//  AirQuality
//
//  Created by Prince Sojitra on 09/01/22.
//

import Foundation
import Starscream

protocol APIServiceSocketProtocol {
    var serviceURL: String { get }
    var socket: WebSocket? { get set}
    var isConnected: Bool { get set}
    func connectToSocket()
    func disconnectFromSocket()
}

class AQICityAPIService: APIServiceSocketProtocol {
    let serviceURL: String = "ws://city-ws.herokuapp.com/"
    var isConnected: Bool = false
    var socket: WebSocket?
    
    init() {
        self.socket = getWebSocketObject()
    }
    
    func getWebSocketObject() -> WebSocket? {
        guard let url = URL(string: serviceURL) else { return nil}
        let urlRequest = URLRequest(url: url)
        let webSocket = WebSocket(request: urlRequest)
        return webSocket
    }
    
    func connectToSocket() {
        if !self.isConnected {
            self.socket?.connect()
        }
    }
    
    func disconnectFromSocket() {
        self.socket?.disconnect()
    }
}
