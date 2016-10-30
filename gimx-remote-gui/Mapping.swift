//
//  Mapping.swift
//  gimx-remote-macos
//
//  Created by shdwprince on 10/29/16.
//  Copyright © 2016 shdwprince. All rights reserved.
//

import Foundation
import Cocoa
import AEXML

typealias KeyIdentifier = String
let KeyIdentifierNotFound = ""

@objc class Mapping: NSObject {
    var mapping = [KeyIdentifier: AxleState]()

    override init() {
        super.init()
    }

    func downState(for event: NSEvent) -> AxleState? {
        if let key = self.keyIdentifier(of: event) {
            return self.downState(for: key)
        } else {
            return nil
        }
    }

    func upState(for event: NSEvent) -> AxleState? {
        if let key = self.keyIdentifier(of: event) {
            return self.upState(for: key)
        } else {
            return nil
        }
    }

    func downState(for code: UInt) -> AxleState? {
        return self.downState(for: self.keyIdentifier(of: code) ?? KeyIdentifierNotFound)
    }

    func upState(for code: UInt) -> AxleState? {
        return self.upState(for: self.keyIdentifier(of: code) ?? KeyIdentifierNotFound)
    }

    func downState(for key: KeyIdentifier) -> AxleState? {
        if let entry = self.mapping[key] {
            return (entry.0, entry.1)
        } else {
            return nil
        }
    }

    func upState(for key: KeyIdentifier) -> AxleState? {
        if let entry = self.mapping[key] {
            return (entry.0, -entry.1)
        } else {
            return nil
        }
    }

    private func keyIdentifier(of event: NSEvent) -> KeyIdentifier? {
        return self.keyIdentifier(of: UInt(event.keyCode)) ?? event.charactersIgnoringModifiers
    }

    private func keyIdentifier(of code: UInt) -> KeyIdentifier? {
        switch code {
        case NSEventModifierFlags.shift.rawValue:
            return "LSHIFT"
        case NSEventModifierFlags.control.rawValue:
            return "CONTROL"
        case NSEventModifierFlags.capsLock.rawValue:
            return "CAPSLOCK"

        case 48:
            return "TAB"
        case 49:
            return "SPACE"
        case 51:
            return "BACKSPACE"
        case 36:
            return "RETURN"
        case 41:
            return "SEMICOLON"
        case 43:
            return "PERIOD"
        case 53:
            return "ESCAPE"

        case 123:
            return "LEFT"
        case 124:
            return "RIGHT"
        case 125:
            return "DOWN"
        case 126:
            return "UP"
            
        default:
            return nil
        }
    }

    enum ParseError: Error {
        case wrongEvent(_: String)
    }

    func parse(from url: URL) throws {
        self.mapping.removeAll()
        
        let doc = try AEXMLDocument(xml: Data(contentsOf: url))
        if let configuration = doc.root.children.first?.children.first {
            func parseMap(_ map: AEXMLElement) throws {
                for button in map.children {
                    if button["device"].attributes["type"] == "keyboard" {
                        let event = button["event"]
                        if let key = event.attributes["id"],
                            let axle = button.attributes["id"] {
                            var axleIndex: Int?
                            var axleDirection = 1
                            if button.name == "button" {
                                axleIndex = Int(axle.substring(from: axle.index(axle.startIndex, offsetBy:9)))
                            } else if button.name == "axis" {
                                let range = Range<String.Index>.init(uncheckedBounds: (lower: axle.index(axle.startIndex, offsetBy:9),
                                                                                       upper: axle.index(axle.endIndex, offsetBy:-1)))
                                axleIndex = Int(axle.substring(with: range))
                                switch axle.characters.last! {
                                case "-":
                                    axleDirection = -1
                                default:
                                    break
                                }
                            }

                            if let axleIndex = axleIndex {
                                switch axle.substring(to: axle.index(axle.startIndex, offsetBy: 3)) {
                                case "abs":
                                    self.mapping[key] = (axleIndex + 8, 255)
                                case "rel":
                                    self.mapping[key] = (axleIndex, axleDirection > 0 ? AxleValue.axleMax.rawValue : AxleValue.axleMin.rawValue)
                                default:
                                    break
                                }
                            }
                        } else {
                            throw ParseError.wrongEvent(event.xml)
                        }
                    }
                }
            }

            try parseMap(configuration["button_map"])
            try parseMap(configuration["axis_map"])
        }

        print(self.mapping)
    }
}











