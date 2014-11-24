//
//  UPnPDB.swift
//  ControlPointDemo
//
//  Created by David Robles on 11/16/14.
//  Copyright (c) 2014 David Robles. All rights reserved.
//

import Foundation

@objc class UPnPDB_Swift {
    // public
    var rootDevices: [AbstractUPnPDevice_Swift] {
        var rootDevices: [AbstractUPnPDevice_Swift]!
        dispatch_sync(_concurrentDeviceQueue, { () -> Void in
            rootDevices = Array(self._rootDevices.values)
        })
        return rootDevices
    }
    let ssdpDB: SSDPDB_ObjC
    
    // private
    private let _concurrentDeviceQueue = dispatch_queue_create("com.upnpx.swift.rootDeviceQueue", DISPATCH_QUEUE_CONCURRENT)
    lazy private var _rootDevices = [String: AbstractUPnPDevice_Swift]()
    
    init(ssdpDB: SSDPDB_ObjC) {
        self.ssdpDB = ssdpDB
        ssdpDB.addSSDPDBObserver(self)
    }
    
    func ssdpServicesFor(uuid: String) -> [SSDPDBDevice_ObjC] {
        ssdpDB.lock()
        
        var services = [SSDPDBDevice_ObjC]()
        
        for ssdpDevice in ssdpDB.SSDPObjCDevices {
            if let ssdpDevice = ssdpDevice as? SSDPDBDevice_ObjC {
                if ssdpDevice.isservice && ssdpDevice.uuid == uuid {
                    services.append(ssdpDevice)
                }
            }
        }
        
        ssdpDB.unlock()
        
        return services
    }
    
    private func addRootDevice(device: AbstractUPnPDevice_Swift) {
        dispatch_barrier_async(_concurrentDeviceQueue, { () -> Void in
            self._rootDevices[device.usn] = device
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                NSNotificationCenter.defaultCenter().postNotificationName(UPnPDB_Swift.UPnPDeviceWasAddedNotification(), object: self, userInfo: [UPnPDB_Swift.UPnPDeviceKey(): device])
            })
        })
    }
}

/// Extension used for defining notification constants. Functions are used since class constants are not supported in swift yet
extension UPnPDB_Swift {
    class func UPnPDeviceWasAddedNotification() -> String {
        return "UPnPDeviceWasAddedNotification"
    }
    
    class func UPnPDeviceWasRemovedNotification() -> String {
        return "UPnPDeviceWasRemovedNotification"
    }
    
    class func UPnPDeviceKey() -> String {
        return "UPnPDeviceKey"
    }
}

extension UPnPDB_Swift: SSDPDB_ObjC_Observer {
    func SSDPDBWillUpdate(sender: SSDPDB_ObjC!) {
        
    }
    
    func SSDPDBUpdated(sender: SSDPDB_ObjC!) {
        let ssdpDevices = sender.SSDPObjCDevices.copy() as [SSDPDBDevice_ObjC]
        dispatch_barrier_async(_concurrentDeviceQueue, { () -> Void in
            let rootDevices = self._rootDevices
            var devicesToAdd = [AbstractUPnPDevice_Swift]()
            var devicesToKeep = [AbstractUPnPDevice_Swift]()
            for ssdpDevice in ssdpDevices {
                if ssdpDevice.isdevice {
                    if let foundRootDevice = rootDevices[ssdpDevice.usn] {
                        devicesToKeep.append(foundRootDevice)
                    }
                    else {
                        if let newRootDevice = UPnPDeviceFactory_Swift.createDeviceFrom(ssdpDevice) {
                            devicesToAdd.append(newRootDevice)
                        }
                    }
                }
            }
            
            let rootDevicesSet = NSMutableSet(array: Array(rootDevices.values))
            rootDevicesSet.minusSet(NSSet(array: devicesToKeep))
            let devicesToRemove = rootDevicesSet.allObjects as [AbstractUPnPDevice_Swift] // casting from [AnyObject]
            
            for deviceToRemove in devicesToRemove {
                self._rootDevices.removeValueForKey(deviceToRemove.usn)
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    NSNotificationCenter.defaultCenter().postNotificationName(UPnPDB_Swift.UPnPDeviceWasRemovedNotification(), object: self, userInfo: [UPnPDB_Swift.UPnPDeviceKey(): deviceToRemove])
                })
            }
            
            for deviceToAdd in devicesToAdd {
                self._rootDevices[deviceToAdd.usn] = deviceToAdd
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    NSNotificationCenter.defaultCenter().postNotificationName(UPnPDB_Swift.UPnPDeviceWasAddedNotification(), object: self, userInfo: [UPnPDB_Swift.UPnPDeviceKey(): deviceToAdd])
                })
            }
        })
    }
}
