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
    print(UInt32(kSCNetworkFlagsReachable))
    return (isReachable && !needsConnection)
}

func CheckReachability(address:String)->Bool{
    //ipv6
    var addr6 = sockaddr_in6()
    addr6.sin6_len = UInt8(MemoryLayout.size(ofValue: addr6))
    addr6.sin6_family = sa_family_t(AF_INET6)
    var ip = in6_addr()
    _ = withUnsafeMutablePointer(to: &ip) {
        inet_pton(AF_INET6, address, UnsafeMutablePointer($0))
    }
    addr6.sin6_addr = ip
    
    //ipv4
    var addr = sockaddr_in()
    addr.sin_len = UInt8(MemoryLayout.size(ofValue: addr))
    addr.sin_family = sa_family_t(AF_INET)
    addr.sin_addr.s_addr = inet_addr(address)
    
    var hostaddr = sockaddr_in()
    hostaddr.sin_len = UInt8(MemoryLayout.size(ofValue: hostaddr))
    hostaddr.sin_family = sa_family_t(AF_INET)
    hostaddr.sin_addr.s_addr = inet_addr("8.8.8.8")
    
    let hostAddress = withUnsafePointer(to: &hostaddr) {
        $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
            return $0
        }
    }
    
    guard let reachability = withUnsafePointer(to: &addr6, {
        $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
            SCNetworkReachabilityCreateWithAddressPair(kCFAllocatorDefault, $0, hostAddress)
        }
    })else{
        return false
    }

    var flags = SCNetworkReachabilityFlags.connectionAutomatic
    
    if !SCNetworkReachabilityGetFlags(reachability, &flags){
        return false
    }

    let isReachable = flags.contains(.reachable)
    print("isReachable is ",isReachable)
   // let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
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
        
        var flags: SCNetworkReachabilityFlags = SCNetworkReachabilityFlags.connectionAutomatic
        print("isConnectedToNetwork of flag is",flags.rawValue)

        if SCNetworkReachabilityGetFlags(defaultRouteReachability , &flags) == false {
            return false
        }
        
        let isReachable = flags == .reachable
        
        let needsConnection = flags == .connectionRequired
        
        let out = flags.subtracting(.reachable)
        print("out is ",out)
        print(isReachable)
        return isReachable && !needsConnection
    }
}

