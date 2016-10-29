//
//  GimxRemote.swift
//  gimx-remote-macos
//
//  Created by shdwprince on 10/29/16.
//  Copyright © 2016 shdwprince. All rights reserved.
//

import Foundation

typealias AxleIndex = Int
typealias AxleRawValue = Int32

enum AxleValue: AxleRawValue {
    case released = 0

    case buttonPressed = 255

    case axleMin = -128
    case axleMax = 128
}

typealias AxleState = (AxleIndex, AxleRawValue)

@objc class Packet: NSObject {
    var data = [AxleRawValue].init(repeating: 0, count: 38)

    func putAxle<Mapping: RawRepresentable, State: RawRepresentable>(_ axle: Mapping, state: State) where Mapping.RawValue == AxleIndex, State.RawValue == AxleRawValue {
        self.putAxle((axle.rawValue, state.rawValue))
    }

    func putAxle<T: RawRepresentable>(_ axle: T, state: AxleRawValue) where T.RawValue == AxleIndex {
        self.putAxle((axle.rawValue, state))
    }

    func putAxle(_ axle: AxleIndex, state: AxleRawValue) {
        self.putAxle((axle, state))
    }

    func putAxle(_ axle: AxleState) {
        self.data[axle.0] += axle.1
    }
}

enum RemoteError: Error {
    case connectionFailed(code: Int)
}

class Remote {
    static let shared = Remote()
    var socketId: UInt32 = 0
    var socketAddr = sockaddr_in()

    func connect(_ location: String) throws {
        let addr = location.components(separatedBy: ":").first!
        let port = Int32(location.components(separatedBy: ":").last!)!

        let code = UDPConnect(addr, port, &self.socketId, &self.socketAddr)
        if code != 0 {
            throw RemoteError.connectionFailed(code: code)
        }
    }

    func send(_ packet: Packet) throws {
        let code = UDPSend(self.socketId, self.socketAddr, packet.data)
        if code != 0 {
            throw RemoteError.connectionFailed(code: code)
        }
    }

    func type() throws -> Int {
        let code = UDPType(self.socketId, self.socketAddr)
        if code < 0 {
            throw RemoteError.connectionFailed(code: code)
        }

        return code
    }
}

class RemoteManager {
    static let shared = RemoteManager()
    
    var packet = Packet()
    let queue = OperationQueue()

    func testConnection() throws {
        try Remote.shared.type()
    }
    
    func queueUpdate() {
        self.queue.addOperation {
            do {
                try Remote.shared.send(self.packet)
            } catch let e {
                print(e)
                return
            }
        }
    }
}
