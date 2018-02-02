//
//  ViewController.swift
//  RobobloqSwiftDemo
//
//  Created by liamios on 2018/1/23.
//  Copyright © 2018年 Liam. All rights reserved.
//

import UIKit
import CoreBluetooth

class ViewController: UIViewController {
    /* ROBOBLOQ-k1
     server: "6e400001-b5a3-f393-e0a9-e50e24dcca9e",
     read: "6e400003-b5a3-f393-e0a9-e50e24dcca9e",
     write: "6e400002-b5a3-f393-e0a9-e50e24dcca9e"
     */
    private let Service_UUID: String = "6e400001-b5a3-f393-e0a9-e50e24dcca9e" // "CDD1" //
    private let ServiceWrite_UUID: String = "6e400002-b5a3-f393-e0a9-e50e24dcca9e" //"CDD2" "CDD2" //
    private let ServiceRead_UUID: String = "6e400003-b5a2-f393-e0a9-e50e24dcca9e"
    
    @IBOutlet weak var textField: UITextField!
    private var centralManager: CBCentralManager?
    private var peripheral: CBPeripheral?
    private var characteristic: CBCharacteristic?
    private var connNum : Int = 0
    private var bleCanUse : Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        centralManager = CBCentralManager.init(delegate: self, queue: .main)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // test sound
    @IBAction func didClickTestSound(_ sender: Any) {
        print("click1 ")
        // 5242 0b02 13fa 052a 03e8 c8
        let bytes : [UInt8] = [ 0x52, 0x42, 0x0b, 0x02, 0x13, 0xfa, 0x05, 0x2a, 0x03 ,0xe8 , 0xc8 ]
        let data = Data(bytes:bytes)
        self.peripheral?.writeValue(data, for: self.characteristic!, type: CBCharacteristicWriteType.withResponse)
        print("didClickTestSound --end")
    }
    
    @IBAction func didClickTestLightRed(_ sender: Any) {
        //5242 0a 02 10 fc 08 da 7a08
        let bytes : [UInt8] = [ 0x52, 0x42, 0x0a, 0x02, 0x10, 0xfc, 0x08, 0xda, 0x7a ,0x08 ]
        let data = Data(bytes:bytes)
        self.peripheral?.writeValue(data, for: self.characteristic!, type:CBCharacteristicWriteType.withoutResponse)
        print("didClickTestLightRed --end")
    }
    
    @IBAction func didClickTestLightGreen(_ sender: Any) {
        // 超声波值： 524207 02a10341
        let bytes : [UInt8] = [ 0x52, 0x42, 0x07, 0x02, 0xa1, 0x03, 0x41]
        let data = Data(bytes:bytes)
        self.peripheral?.writeValue(data, for: self.characteristic!, type:CBCharacteristicWriteType.withoutResponse)
        print("didClickTestLightGreen --end")
    }
    
    @IBAction func didClickClear(_ sender: Any) {
        //stop
        print("didClickClear -- start")
        if(self.bleCanUse){
            self.connNum = 0
            let isScanning = centralManager?.isScanning
            if(isScanning != nil && isScanning == true){
                centralManager?.stopScan()
                print("didClickClear -- 1")
            }
            if( self.peripheral != nil){
                centralManager?.cancelPeripheralConnection(self.peripheral!)
                self.peripheral = nil
                print("didClickClear -- 2")
            }
        }
        print("didClickClear --end")
    }
    
    @IBAction func didClickScan(_ sender: Any) {
        //self.peripheral?.readValue(for: self.characteristic!)
        print("didClickScan --0")
        if(self.bleCanUse){
            let isScanning = centralManager?.isScanning
            if(isScanning != nil && isScanning == true){
                print("didClickScan -- 1")
                return ;
            }
            centralManager?.scanForPeripherals(withServices: nil, options: nil)
        }else{
            print("didClickScan -- 不可用")
        }
    }
    

}



extension ViewController: CBCentralManagerDelegate, CBPeripheralDelegate {
    // 判断手机蓝牙状态
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .unknown:
            print("未知的")
        case .resetting:
            print("重置中")
        case .unsupported:
            print("不支持")
        case .unauthorized:
            print("未验证")
        case .poweredOff:
            print("未启动")
        case .poweredOn:
            print("手机蓝牙:可用")
            self.bleCanUse = true
            //central.scanForPeripherals(withServices: [CBUUID.init(string: Service_UUID)], options: nil) //这个无法找到！
            //central.scanForPeripherals(withServices: nil, options: nil)
            print("centralManagerDidUpdateState 1 ")
        }
    }
    
    /** 发现符合要求的外设 */
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        print("centralManager 1A ")
        
        // 根据外设名称来过滤
        if( peripheral.name != nil && (peripheral.name?.hasPrefix("ROBOBLOQ"))! ){
            self.peripheral = peripheral
            print(peripheral)
            self.connNum = self.connNum + 1
            print(self.connNum)
            if( self.connNum == 1){
                central.stopScan()
                print("centralManager 1A -- connect A")
                central.connect(peripheral, options: nil)
                print("centralManager 1A -- connect B")
                
            }
        }
    }
    
    /** 连接成功 */
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("centralManager 1B ")
        self.centralManager?.stopScan()
        peripheral.delegate = self
        peripheral.discoverServices([CBUUID.init(string: Service_UUID)])
        print("连接成功")
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print("连接失败")
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print("断开连接")
        // 重新连接
        //central.connect(peripheral, options: nil)
    }
    
    /** 发现服务 */
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        print("peripheral 1A ")
        for service: CBService in peripheral.services! {
            print("外设中的服务有：\(service)")
        }
        //本例的外设中只有一个服务
        let service = peripheral.services?.last
        // 根据UUID寻找服务中的特征
        peripheral.discoverCharacteristics([CBUUID.init(string: ServiceWrite_UUID)], for: service!)
    }
    
    /** 发现特征 */
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        print("peripheral 2B ")
        for characteristic: CBCharacteristic in service.characteristics! {
            print("外设中的特征有：\(characteristic)")
            // 读取特征里的数据
            peripheral.readValue(for: characteristic)
            // 订阅 ServiceRead_UUID
            peripheral.setNotifyValue(true, for: characteristic)
        }
        
        self.characteristic = service.characteristics?.last
        // 读取特征里的数据
        //peripheral.readValue(for: self.characteristic!)
        // 订阅 ServiceRead_UUID
        //peripheral.setNotifyValue(true, for: self.characteristic!)
        //var characteristic2:CBCharacteristic? = service.characteristics?.last
        //characteristic2?.UUID = ServiceRead_UUID
        //peripheral.setNotifyValue(true, for: characteristic2!)
    }
    
    /** 订阅状态 */
    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        print("peripheral 3C ")
        if let error = error {
            print("订阅失败: \(error)")
            return
        }
        if characteristic.isNotifying {
            print("订阅成功")
        } else {
            print("取消订阅")
        }
    }
    
    /** 接收到数据 */
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        //print("接收到数据 peripheral 4C --0")
        print(characteristic)
        let data = characteristic.value
        self.textField.text = String.init(data: data!, encoding: String.Encoding.utf8)
        //print( String.init(data: data!, encoding: String.Encoding.utf8) )
        //print( peripheral.readValue(for: characteristic))
        //print("接收到数据 peripheral 4C ---1")
    }
    
    /** 写入数据 */
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        print("写入数据 -- 0")
        print( peripheral.readValue(for: characteristic))
        if (error != nil )  {
            print( error!.localizedDescription )
        }else {
            //[peripheral readValueForCharacteristic:characteristic];
            print( peripheral.readValue(for: characteristic))
        }
        print("写入数据 --- 1")
    }
}

