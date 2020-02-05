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

