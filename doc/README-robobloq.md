# Use robobloq with iOS (Swift)

For iOS developers, we have a Swift Library to control robot (through Bluetooth) with iOS devices.

[github.com/moklib/swiftLib/doc/README-robobloq.md ](https://github.com/moklib/swiftLib/doc/README-robobloq.md)


# Download and for test

[https://github.com/moklib/swiftLib/RbLib/RobobloqSwiftDemo ](https://github.com/moklib/swiftLib/RbLib/RobobloqSwiftDemo)

# Download and Import

[github.com/moklib/swiftLib/RbLib ](https://github.com/moklib/swiftLib/RbLib)

add the RbLib folder to yours project


# Connect to the robot through Bluetooth

## 1.First, you need to let your phone discover Bluetooth devices from the environment. Run the following code will do the work.


## 2. Filter robot by name

func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        if( peripheral.name != nil && (peripheral.name?.hasPrefix(GsConfig.bleUUID.preName.rawValue))! ){
            if( self.connNum == 1){
                central.stopScan()
                central.connect(peripheral, options: nil)
            }
        }
    }

## 3. Registration service

func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        for characteristic in service.characteristics! {
            switch characteristic.uuid.description {
            case GsConfig.bleUUID.read.rawValue : 
                peripheral.readValue(for: characteristic)
                self.peripheral?.setNotifyValue(true, for: characteristic)
                break
            case GsConfig.bleUUID.write.rawValue : 
                self.characteristic = characteristic
                GsRobotManager.addBle(peripheral: peripheral , characteristic: characteristic )
                break
            default:
                break
            }
        }
    }

## 4. After the robot is connected, you need to get the handle of a robot using the connection you made (this can be done before the actual connection happens):

let robot = GsRobotManager.getCurrentRobot()


# Control the robot with Robobloq API

Robobloq class provides a series of APIs to play with the robot. Here are some examples:

## 1. robot.setBuzzer( rate:Int, time:Int , isBack:Bool , _ block: @escaping gsBlockArray )

play a musical note using the on-board buzzer of robot.

## 2. robot.setLed(port:UInt8,red:UInt8, green:UInt8, blue:UInt8 ,isBack:Bool, _ block: @escaping gsBlockArray )

set the color of robot’s on-board LEDs. 

## 3. robot.setMove(port:UInt8,m1Speed:Int8, m2Speed:Int8 ,isBack:Bool, _ block: @escaping gsBlockArray )

tell the robot to move forward in a certain speed (-90 to 90)

[(More available at the API Documentation) ](https://www.robobloq.com)


