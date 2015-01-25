//
//  UPnPEventSubscriptionSerialization.swift
//  ControlPointDemo
//
//  Created by David Robles on 12/28/14.
//  Copyright (c) 2014 David Robles. All rights reserved.
//

import Foundation

class UPnPEventSubscribeRequestSerializer: AFHTTPRequestSerializer {
    class Parameters {
        let callBack: NSURL
        let timeout: Int // in seconds
        
        init(callBack: NSURL, timeout: Int) {
            self.callBack = callBack
            self.timeout = timeout
        }
    }
    
    override func requestBySerializingRequest(request: NSURLRequest!, withParameters parameters: AnyObject!, error: NSErrorPointer) -> NSURLRequest! {
        let requestParameters: Parameters! = parameters as? Parameters
        if requestParameters == nil {
            return nil
        }
        
        var mutableRequest: NSMutableURLRequest = request.mutableCopy() as NSMutableURLRequest
        
        for (field, value) in self.HTTPRequestHeaders {
            if let field = field as? String {
                if request.valueForHTTPHeaderField(field) == nil {
                    if let value = value as? String {
                        mutableRequest.setValue(value, forHTTPHeaderField: field)
                    }
                }
            }
        }
        
        if let callBackString = requestParameters.callBack.absoluteString {
            mutableRequest.setValue("<\(callBackString)>", forHTTPHeaderField: "CALLBACK")
        }
        
        mutableRequest.setValue("upnp:event", forHTTPHeaderField: "NT")
        mutableRequest.setValue("Second-\(requestParameters.timeout)", forHTTPHeaderField: "TIMEOUT")
        
        return mutableRequest
    }
}

class UPnPEventSubscribeResponseSerializer: AFHTTPRequestSerializer {
    
}

class UPnPEventRenewSubscriptionRequestSerializer: AFHTTPRequestSerializer {
    class Parameters {
        let subscriptionID: String
        let timeout: Int // in seconds
        
        init(subscriptionID: String, timeout: Int) {
            self.subscriptionID = subscriptionID
            self.timeout = timeout
        }
    }
    
    override func requestBySerializingRequest(request: NSURLRequest!, withParameters parameters: AnyObject!, error: NSErrorPointer) -> NSURLRequest! {
        let requestParameters: Parameters! = parameters as? Parameters
        if requestParameters == nil {
            return nil
        }
        
        var mutableRequest: NSMutableURLRequest = request.mutableCopy() as NSMutableURLRequest
        
        for (field, value) in self.HTTPRequestHeaders {
            if let field = field as? String {
                if request.valueForHTTPHeaderField(field) == nil {
                    if let value = value as? String {
                        mutableRequest.setValue(value, forHTTPHeaderField: field)
                    }
                }
            }
        }
        
        mutableRequest.setValue("\(requestParameters.subscriptionID)", forHTTPHeaderField: "SID")
        mutableRequest.setValue("Second-\(requestParameters.timeout)", forHTTPHeaderField: "TIMEOUT")
        
        return mutableRequest
    }
}

class UPnPEventRenewSubscriptionResponseSerializer: AFHTTPRequestSerializer {
    
}

class UPnPEventUnsubscribeRequestSerializer: AFHTTPRequestSerializer {
    class Parameters {
        let subscriptionID: String
        
        init(subscriptionID: String) {
            self.subscriptionID = subscriptionID
        }
    }
    
    override func requestBySerializingRequest(request: NSURLRequest!, withParameters parameters: AnyObject!, error: NSErrorPointer) -> NSURLRequest! {
        let requestParameters: Parameters! = parameters as? Parameters
        if requestParameters == nil {
            return nil
        }
        
        var mutableRequest: NSMutableURLRequest = request.mutableCopy() as NSMutableURLRequest
        
        for (field, value) in self.HTTPRequestHeaders {
            if let field = field as? String {
                if request.valueForHTTPHeaderField(field) == nil {
                    if let value = value as? String {
                        mutableRequest.setValue(value, forHTTPHeaderField: field)
                    }
                }
            }
        }
        
        mutableRequest.setValue("\(requestParameters.subscriptionID)", forHTTPHeaderField: "SID")
        
        return mutableRequest
    }
}

class UPnPEventUnsubscribeResponseSerializer: AFHTTPRequestSerializer {
    
}
