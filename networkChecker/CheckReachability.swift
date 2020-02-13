//
//  CheckReachability.swift
//  networkChecker
//
//  Created by 丁琪 on 2/3/20.
//  Copyright © 2020 丁琪. All rights reserved.
//

import Foundation
import SystemConfiguration

func CheckReachability(hostname:String)->Bool{
    let reachability = SCNetworkReachabilityCreateWithName(nil, hostname)!
    
    var flags = SCNetworkReachabilityFlags.connectionAutomatic
    
    if !SCNetworkReachabilityGetFlags(reachability, &flags){
        return false
    }
    
    let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
    let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
    
    return (isReachable && !needsConnection)
}

public class Reachability {
    class func isConnectedToNetwork() -> Bool {
        var zeroAddress = sockaddr_in(sin_len: 0, sin_family: 0, sin_port: 0, sin_addr: in_addr(s_addr: 0), sin_zero: (0, 0, 0, 0, 0, 0, 0, 0))
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        guard let defaultRouteReachability = withUnsafePointer(to: &zeroAddress, {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                SCNetworkReachabilityCreateWithAddress(nil, $0)
            }
        }) else {
            return false
        }
        var flags: SCNetworkReachabilityFlags = SCNetworkReachabilityFlags(rawValue: 0)
        
        if SCNetworkReachabilityGetFlags(defaultRouteReachability , &flags) == false {
            return false
        }
        
        let isReachable = flags == .reachable
//        @constant kSCNetworkFlagsReachable
//            This flag indicates that the specified nodename or address can
//            be reached using the current network configuration.
        //let isReachable1 = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
        
        let needsConnection = flags == .connectionRequired
        
        print(isReachable)
        return isReachable && !needsConnection
    }
}

