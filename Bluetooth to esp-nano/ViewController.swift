//
//  ViewController.swift
//  Bluetooth to esp-nano
//
//  Created by Brandon Ong on 10/30/19.
//  Copyright © 2019 Brandon Ong. All rights reserved.
//

import UIKit
import CoreBluetooth

class ViewController: UIViewController, CBPeripheralDelegate, CBCentralManagerDelegate, UIPickerViewDataSource, UIPickerViewDelegate {
    
    @IBOutlet weak var soundSwitch: UISwitch!
    @IBOutlet weak var soundLabel: UILabel!
    @IBOutlet weak var lightSwitch: UISwitch!
    @IBOutlet weak var lightLabel: UILabel!
    @IBOutlet weak var connectionLabel: UILabel!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var intervalPicker: UIPickerView!
    @IBOutlet weak var intervalLabel: UILabel!
    @IBOutlet weak var freqSlider: UISlider!
    @IBOutlet weak var freqLabel: UILabel!
    
    
    private var testChar: CBCharacteristic?
    let intervalPickerData = [["0 min", "1 min", "2 min", "3 min", "4 min", "5 min", "6 min", "7 min", "8 min", "9 min", "10 min", "11 min" , "12 min", "13 min", "14 min", "15 min", "16 min", "17 min", "18 min", "19 min", "20 min", "21 min" , "22 min", "23 min", "24 min", "25 min", "26 min", "27 min", "28 min", "29 min", "30 min", "31 min" , "32 min", "33 min", "34 min", "35 min", "36 min", "37 min", "38 min", "39 min", "40 min", "41 min" , "42 min", "43 min", "44 min", "45 min", "46 min", "47 min", "48 min", "49 min", "50 min", "51 min" , "52 min", "53 min", "54 min", "55 min", "56 min", "57 min", "58 min", "59 min"], ["0 sec", "1 sec", "2 sec", "3 sec", "4 sec", "5 sec", "6 sec", "7 sec", "8 sec", "9 sec", "10 sec", "11 sec" , "12 sec", "13 sec", "14 sec", "15 sec", "16 sec", "17 sec", "18 sec", "19 sec", "20 sec", "21 sec" , "22 sec", "23 sec", "24 sec", "25 sec", "26 sec", "27 sec", "28 sec", "29 sec", "30 sec", "31 sec" , "32 sec", "33 sec", "34 sec", "35 sec", "36 sec", "37 sec", "38 sec", "39 sec", "40 sec", "41 sec" , "42 sec", "43 sec", "44 sec", "45 sec", "46 sec", "47 sec", "48 sec", "49 sec", "50 sec", "51 sec" , "52 sec", "53 sec", "54 sec", "55 sec", "56 sec", "57 sec", "58 sec", "59 sec"]]
    
    //Properties
    private var manager: CBCentralManager!
    private var peripheral: CBPeripheral!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        manager = CBCentralManager(delegate: self, queue: nil)
        soundSwitch.isEnabled = false
        lightSwitch.isEnabled = false
        sendButton.isEnabled = false
        sendButton.layer.cornerRadius = 8
        connectionLabel.text = "Disconnected"
        intervalPicker.isUserInteractionEnabled = false
        freqSlider.isEnabled = false
        intervalPicker.selectRow(1, inComponent: 0, animated: true)
        freqSlider.value = 1
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        print("Central state update")
        if central.state != .poweredOn {
            print("Central is not powered on")
        } else {
            print("Central scanning for", ParticlePeripheral.particleLEDServiceUUID);
            manager.scanForPeripherals(withServices: [ParticlePeripheral.particleLEDServiceUUID],options: [CBCentralManagerScanOptionAllowDuplicatesKey : true])
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        print("Found")
        // We've found it so stop scan
        self.manager.stopScan()
        
        // Copy the peripheral instance
        self.peripheral = peripheral
        self.peripheral.delegate = self
        
        // Connect!
        self.manager.connect(self.peripheral, options: nil)
        
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        if peripheral == self.peripheral {
            connectionLabel.text = "Connected"
            print("Connected to your ESP")
            peripheral.discoverServices([ParticlePeripheral.particleLEDServiceUUID]);
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        if peripheral == self.peripheral {
            print("Disconnected")
            
            soundSwitch.isEnabled = false
            lightSwitch.isEnabled = false
            sendButton.isEnabled = false
            connectionLabel.text = "Disconnected"
            intervalPicker.isUserInteractionEnabled = false
            freqSlider.isEnabled = false
            
//            soundSwitch.isOn = false
//            lightSwitch.isOn = false
//            vibrationSwitch.isOn = false
            
            self.peripheral = nil
            
            // Start scanning again
            print("Central scanning for", ParticlePeripheral.particleLEDServiceUUID);
            manager.scanForPeripherals(withServices: [ParticlePeripheral.particleLEDServiceUUID],
                                              options: [CBCentralManagerScanOptionAllowDuplicatesKey : true])
        }
    }
    
    // Handles discovery event
        func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
            if let services = peripheral.services {
                for service in services {
                    if service.uuid == ParticlePeripheral.particleLEDServiceUUID {
                        print("LED service found")
                        //Now kick off discovery of characteristics
                        peripheral.discoverCharacteristics([ParticlePeripheral.particleCharacteristicUUID], for: service)
                    }
                }
            }
        }
        
        func peripheral(_ peripheral: CBPeripheral,
                         didUpdateNotificationStateFor characteristic: CBCharacteristic,
                         error: Error?) {
            print("Enabling notify ", characteristic.uuid)
            
            if error != nil {
                print("Enable notify error")
            }
        }
        
        // Handling discovery of characteristics
        func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
            if let characteristics = service.characteristics {
                for characteristic in characteristics {
                    if characteristic.uuid == ParticlePeripheral.particleCharacteristicUUID {
                        print("Arduino Characteristic Found")
                        
                        // Set the characteristic
                        testChar = characteristic
                        
                        // Unmask red slider
                        soundSwitch.isEnabled = true
                        lightSwitch.isEnabled = true
                        
                        sendButton.isEnabled = true
                        intervalPicker.isUserInteractionEnabled = true
                        freqSlider.isEnabled = true
                    }
                }
            }
        }

        private func writeLEDValueToChar() {
            // Check if it has the write property
            if peripheral != nil {
                
                var sound = UInt8(NSNumber(value:soundSwitch.isOn))
                var light = UInt8(NSNumber(value:lightSwitch.isOn))
                var min = UInt8(intervalPicker.selectedRow(inComponent: 0))
                var sec = UInt8(intervalPicker.selectedRow(inComponent: 1))
                var freq = UInt8(freqSlider.value*100)
//                var swi:UInt8 =UInt8(NSNumber(value:testSwitch.isOn))
//                swi = swi * 10 + UInt8(outputControl.selectedSegmentIndex)
                
//                for i in swi{
//                    peripheral.writeValue(Data([i]), for: testChar!, type: .withResponse)
//                }
                peripheral.writeValue(Data([sound]), for: testChar!, type: .withResponse)
                peripheral.writeValue(Data([light]), for: testChar!, type: .withResponse)
//                peripheral.writeValue(Data([output]), for: testChar!, type: .withResponse)
                peripheral.writeValue(Data([min]), for: testChar!, type: .withResponse)
                peripheral.writeValue(Data([sec]), for: testChar!, type: .withResponse)
                peripheral.writeValue(Data([freq]), for: testChar!, type: .withResponse)
                
                print("Switch:", sound)
                print("Light:", light)
                print("Minutes:", min)
                print("Seconds:", sec)
                print("Frequency:", freq)
            }
        }
    
    @IBAction func SoundChanged(_ sender: Any) {
        print("Sound:", soundSwitch.isOn)
    }
    @IBAction func LightChanged(_ sender: Any) {
        print("Lights:", lightSwitch.isOn)
    }
    @IBAction func SendButtonPressed(_ sender: Any) {
        writeLEDValueToChar()
    }
    @IBAction func FrequencyChanged(_ sender: Any) {
        print("Frequency:", freqSlider.value)
        print("UInt8:", UInt8(freqSlider.value*100))
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        intervalPickerData[component][row]
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        intervalPickerData[component].count
    }
    

}

