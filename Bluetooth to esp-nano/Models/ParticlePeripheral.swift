//
//  ParticlePeripheral.swift
//  Bluetooth to esp-nano
//
//  Created by Brandon Ong on 11/3/19.
//  Copyright © 2019 Brandon Ong. All rights reserved.
//

import Foundation
import UIKit
import CoreBluetooth

protocol ParticleDelegate{
    
}

class ParticlePeripheral: NSObject{
    public static let particleLEDServiceUUID = CBUUID.init(string: "3b7d9313-56b5-485a-9534-36846518775b")
    
    public static let particleCharacteristicUUID = CBUUID.init(string: "dd93f7ca-915b-4f26-98f7-79e381bfbc18")
}
