//
//  AppDelegate.swift
//  gimx-remote-gui
//
//  Created by shdwprince on 10/29/16.
//  Copyright © 2016 shdwprince. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    @IBOutlet weak var window: NSWindow!
    @IBOutlet weak var mapping: Mapping!
    @IBOutlet weak var addrField: NSTextField!
    @IBOutlet weak var selectConfigButton: NSButton!

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        if let url = UserDefaults.standard.url(forKey: "previousConfig") {
            self.parseConfig(url)
        }

        if let address = UserDefaults.standard.value(forKey: "previousAddress") as? String {
            self.addrField.stringValue = address
        }
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    @IBAction func selectConfigAction(_ sender: AnyObject) {
        let dialog = NSOpenPanel();
        dialog.showsResizeIndicator = true
        dialog.showsHiddenFiles = false
        dialog.canCreateDirectories = true
        dialog.allowsMultipleSelection = false

        if (dialog.runModal() == NSModalResponseOK) {
            if let url = dialog.url {
                self.parseConfig(url)
            }
        }
    }

    @IBAction func connectAction(_ sender: AnyObject) {
        do {
            try Remote.shared.connect(self.addrField.stringValue)
            try RemoteManager.shared.testConnection()
            UserDefaults.standard.set(self.addrField.stringValue, forKey: "previousAddress")
            (sender as! NSButton).title = "active"
        } catch let e {
            self.show(e)
        }
    }

    private func parseConfig(_ url: URL) {
        do {
            try self.mapping.parse(from: url)
            UserDefaults.standard.set(url, forKey: "previousConfig")
            self.selectConfigButton.title = url.lastPathComponent
        } catch let e {
            self.show(e)
        }
    }

    private func show(_ error: Error) {
        let alert = NSAlert.init(error: error)
        alert.runModal()
    }
}

class KeyView: NSView {
    @IBOutlet weak var mapping: Mapping!

    override func keyDown(with event: NSEvent) {
        if event.isARepeat {
            return
        }

        if let state = self.mapping.downState(for: event) {
            self.updateState(state)
        }
    }

    override func keyUp(with event: NSEvent) {
        if event.isARepeat {
            return
        }

        if let state = self.mapping.upState(for: event) {
            self.updateState(state)
        }
    }

    var lastModifierFlags = NSEventModifierFlags.init(rawValue: 256)
    override func flagsChanged(with event: NSEvent) {
        for code in [NSEventModifierFlags.control, NSEventModifierFlags.shift, NSEventModifierFlags.capsLock, ] {
            var state: AxleState?

            if lastModifierFlags.contains(code) && !event.modifierFlags.contains(code) {
                state = self.mapping.upState(for: code.rawValue)
            } else if !lastModifierFlags.contains(code) && event.modifierFlags.contains(code) {
                state = self.mapping.downState(for: code.rawValue)
            }

            if let state = state {
                self.updateState(state)
            }
        }

        self.lastModifierFlags = event.modifierFlags
    }

    class AxleLayer: CAShapeLayer {
        enum LayerType {
            case stick
            case button
        }

        let type: LayerType
        required init(_ type: LayerType, size: NSSize) {
            self.type = type
            super.init()

            self.frame.size = size

            let center = NSPoint(x: self.frame.width / 2, y: self.frame.height / 2)
            let path = NSBezierPath()

            switch self.type {
            case .stick:
                path.appendArc(withCenter: center, radius: self.frame.width/2, startAngle: 0, endAngle: 360)
            case .button:
                path.appendRoundedRect(NSRect(origin: CGPoint(x: 0, y: 0), size: self.frame.size), xRadius: 5, yRadius: 5)
                break
            }

            self.strokeColor = NSColor.white.cgColor
            self.fillColor = NSColor.black.cgColor
            self.path = path.cgPath
        }

        required init?(coder aDecoder: NSCoder) {
            self.type = .stick

            super.init(coder: aDecoder)
        }

        override init(layer: Any) {
            self.type = .stick

            super.init(layer: layer)
        }

        func adjust(_ value: AxleRawValue) {
            switch self.type {
            case .button:
                let percent = Double(value) / Double(AxleValue.buttonPressed.rawValue)
                self.fillColor = NSColor(red: 0, green: CGFloat(1.0 * percent), blue: 0, alpha: 1).cgColor
            case .stick:
                let percent = Double(value) / Double(AxleValue.axleMax.rawValue)
                self.fillColor = NSColor(red: 0, green: CGFloat(1.0 * percent), blue: 0, alpha: 1).cgColor
            }
        }
    }

    private var axleLayers: [AxleIndex: AxleLayer] = [0: AxleLayer(.stick, size: NSSize(width: 50, height: 50)),
                                                      1: AxleLayer(.stick, size: NSSize(width: 50, height: 50)),
                                                      8: AxleLayer(.button, size: NSSize(width: 10, height: 10)),
                                                      9: AxleLayer(.button, size: NSSize(width: 10, height: 10)),
                                                      10: AxleLayer(.button, size: NSSize(width: 10, height: 10)),

                                                      11: AxleLayer(.button, size: NSSize(width: 20, height: 20)),
                                                      12: AxleLayer(.button, size: NSSize(width: 20, height: 20)),
                                                      13: AxleLayer(.button, size: NSSize(width: 20, height: 20)),
                                                      14: AxleLayer(.button, size: NSSize(width: 20, height: 20)),

                                                      15: AxleLayer(.button, size: NSSize(width: 20, height: 20)),
                                                      16: AxleLayer(.button, size: NSSize(width: 20, height: 20)),
                                                      17: AxleLayer(.button, size: NSSize(width: 20, height: 20)),
                                                      18: AxleLayer(.button, size: NSSize(width: 20, height: 20)),

                                                      19: AxleLayer(.button, size: NSSize(width: 32, height: 16)),
                                                      20: AxleLayer(.button, size: NSSize(width: 32, height: 16)),
                                                      21: AxleLayer(.button, size: NSSize(width: 32, height: 16)),
                                                      22: AxleLayer(.button, size: NSSize(width: 32, height: 16)),
                                                      23: AxleLayer(.button, size: NSSize(width: 16, height: 16)),
                                                      24: AxleLayer(.button, size: NSSize(width: 16, height: 16)),
                                                      ]
    override func viewDidMoveToWindow() {
        self.axleLayers[0]!.frame.origin = CGPoint(x: 120, y: 30)
        self.axleLayers[1]!.frame.origin = CGPoint(x: 480-120-50, y: 30)
        self.axleLayers[23]!.frame.origin = CGPoint(x: 120+25-5, y: 30+25-5)
        self.axleLayers[24]!.frame.origin = CGPoint(x: 480-120-50+25-5, y: 30+25-5)

        self.axleLayers[8]!.frame.origin = CGPoint(x: 480 / 2 - 50 + 5, y: 150)
        self.axleLayers[9]!.frame.origin = CGPoint(x: 480 / 2 + 50 - 5, y: 150)
        self.axleLayers[10]!.frame.origin = CGPoint(x: 480 / 2 - 5, y: 150)

        self.axleLayers[11]!.frame.origin = CGPoint(x: 100, y: 150)
        self.axleLayers[12]!.frame.origin = CGPoint(x: 100 + 20, y: 150 - 20)
        self.axleLayers[13]!.frame.origin = CGPoint(x: 100, y: 150 - 40)
        self.axleLayers[14]!.frame.origin = CGPoint(x: 100 - 20, y: 150 - 20)

        self.axleLayers[15]!.frame.origin = CGPoint(x: 480-20-100, y: 150)
        self.axleLayers[16]!.frame.origin = CGPoint(x: 480-20-100 + 20, y: 150 - 20)
        self.axleLayers[17]!.frame.origin = CGPoint(x: 480-20-100, y: 150 - 40)
        self.axleLayers[18]!.frame.origin = CGPoint(x: 480-20-100 - 20, y: 150 - 20)

        self.axleLayers[19]!.frame.origin = CGPoint(x: 100-16, y: 180)
        self.axleLayers[20]!.frame.origin = CGPoint(x: 480-100-16, y: 180)
        self.axleLayers[21]!.frame.origin = CGPoint(x: 100-16, y: 200)
        self.axleLayers[22]!.frame.origin = CGPoint(x: 480-100-16, y: 200)
        //self.axleLayers[]!.frame.origin = CGPoint(x: <#T##Int#>, y: <#T##Int#>)

        for v in self.axleLayers.values.reversed() {
            self.layer?.addSublayer(v)
        }
    }

    private func updateState(_ state: AxleState) {
        RemoteManager.shared.packet.putAxle(state)
        RemoteManager.shared.queueUpdate()

        let lsMax = max(abs(RemoteManager.shared.packet.data[0]), abs(RemoteManager.shared.packet.data[1]))
        let rsMax = max(abs(RemoteManager.shared.packet.data[2]), abs(RemoteManager.shared.packet.data[3]))
        self.axleLayers[0]?.adjust(lsMax)
        self.axleLayers[1]?.adjust(rsMax)

        for i in 8...24 {
            self.axleLayers[i]!.adjust(RemoteManager.shared.packet.data[i])
        }
    }

    override func becomeFirstResponder() -> Bool {
        self.layer?.backgroundColor = NSColor.white.cgColor
        return true
    }

    override func resignFirstResponder() -> Bool {
        self.layer?.backgroundColor = NSColor.gray.cgColor
        return true
    }

    override var canBecomeKeyView: Bool {
        return true
    }

    override var acceptsFirstResponder: Bool {
        return true
    }
}

extension NSBezierPath {
    public var cgPath: CGPath {
        let path = CGMutablePath()
        var points = [CGPoint](repeating: .zero, count: 3)

        for i in 0 ..< self.elementCount {
            let type = self.element(at: i, associatedPoints: &points)
            switch type {
            case .moveToBezierPathElement:
                path.move(to: points[0])
            case .lineToBezierPathElement:
                path.addLine(to: points[0])
            case .curveToBezierPathElement:
                path.addCurve(to: points[2], control1: points[0], control2: points[1])
            case .closePathBezierPathElement:
                path.closeSubpath()
            }
        }

        return path
    }
}
