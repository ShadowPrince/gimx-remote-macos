//
//  main.swift
//  gimx-remote-macos
//
//  Created by shdwprince on 10/28/16.
//  Copyright © 2016 shdwprince. All rights reserved.
//

import Foundation

try Remote.shared.connect("192.168.12.1:80808")

while true {
    var p = Packet()
    p.putAxle(DS4.lsx, state: AxleState.axleMax)

    try Remote.shared.send(p)
    Thread.sleep(forTimeInterval: 0.1)
}
