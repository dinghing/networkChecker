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

func CheckReachability(address:String)->Bool{
//    var addr = sockaddr_in()
//    addr.sin_len = UInt8(MemoryLayout.size(ofValue: addr))
//    addr.sin_family = sa_family_t(AF_INET)
//    addr.sin_addr.s_addr = inet_addr("10.40.106.37")
    
    var zeroAddress = sockaddr_in(sin_len: 0, sin_family: sa_family_t(AF_INET), sin_port: 0, sin_addr: in_addr(s_addr: inet_addr("10.40.106.37")), sin_zero: (0, 0, 0, 0, 0, 0, 0, 0))
    zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
    zeroAddress.sin_family = sa_family_t(AF_INET)
    
    guard let reachability = withUnsafePointer(to: &zeroAddress, {
        $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
            SCNetworkReachabilityCreateWithAddressPair(kCFAllocatorNull, $0, nil)
        }
    })else{
        print("the addressPair is none")
        return false
    }

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
        
        let needsConnection = flags == .connectionRequired
        
        print(isReachable)
        return isReachable && !needsConnection
    }
}

