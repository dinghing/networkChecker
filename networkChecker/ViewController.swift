//
//  ViewController.swift
//  networkChecker
//
//  Created by 丁琪 on 2/3/20.
//  Copyright © 2020 丁琪. All rights reserved.
//

import UIKit
import Network

class ViewController: UIViewController {

    @IBOutlet weak var url: UITextField!
    @IBOutlet weak var result: UITextField!
    
    @IBOutlet weak var resultOfreachable: UITextField!
    @IBOutlet weak var detail: UILabel!
    @IBAction func confirmNetwork(_ sender: Any) {
        // Do any additional setup after loading the view.
        detail.text = ""
        if CheckReachability(hostname: url.text!){
            print("can access the internet")
            result.text = "can access the internet with " + url.text!
        }
        else{
            result.text = "can not access the internet" + url.text!
            print("can not access the internet")
        }
//         if Reachability.isConnectedToNetwork() {
//            print("We're online!")
//            resultOfreachable.text = "can access the internet"
//         }
//         else{
//            print("We're offline!")
//            resultOfreachable.text = "cannot access the internet"
//        }
//
        let _ = getIFAddresses()
//        //print(address)
//        for str in address{
//            //print(str)
//            detail.text! += str
//        }
        
        guard let address = getAddress(for: .cellular) else
        {
            return
        }
        if CheckReachability(address: address){
            print("We're online!")
            resultOfreachable.text = "can access the internet"
         }
         else{
            print("We're offline!")
            resultOfreachable.text = "cannot access the internet"
        }
        detail.text = address
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        detail.numberOfLines = 0
        //Looks for single or multiple taps.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }

    //Calls this function when the tap is recognized.
    @objc func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    enum Network: String {
        case wifi = "en0"
        case cellular = "pdp_ip0"
        case vpn = "utun0" //
    }
    
    func getAddress(for network: Network) -> String? {
        var address: String?
        // Get list of all interfaces on the local machine:
        var ifaddr: UnsafeMutablePointer<ifaddrs>?
        guard getifaddrs(&ifaddr) == 0 else { return nil }
        guard let firstAddr = ifaddr else { return nil }

        // For each interface ...
        for ifptr in sequence(first: firstAddr, next: { $0.pointee.ifa_next }) {
            let interface = ifptr.pointee

            // Check for IPv4 or IPv6 interface:
            let addrFamily = interface.ifa_addr.pointee.sa_family
            if addrFamily == UInt8(AF_INET) || addrFamily == UInt8(AF_INET6) {

                // Check interface name:
                let name = String(cString: interface.ifa_name)
                if name == network.rawValue {
                    // Convert interface address to a human readable string:
                    var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                    getnameinfo(interface.ifa_addr, socklen_t(interface.ifa_addr.pointee.sa_len),
                                &hostname, socklen_t(hostname.count),
                                nil, socklen_t(0), NI_NUMERICHOST)
                    address = String(cString: hostname)
                }
            }
        }
        freeifaddrs(ifaddr)
        return address
    }
    
    func getIFAddresses() -> [String] {
        var addresses = [String]()

        // Get list of all interfaces on the local machine:
        var ifaddr : UnsafeMutablePointer<ifaddrs>?
        guard getifaddrs(&ifaddr) == 0 else { return [] }
        guard let firstAddr = ifaddr else { return [] }

        // For each interface ...
        for ptr in sequence(first: firstAddr, next: { $0.pointee.ifa_next }) {
            let flags = Int32(ptr.pointee.ifa_flags)
            let addr = ptr.pointee.ifa_addr.pointee

            // Check for running IPv4, IPv6 interfaces. Skip the loopback interface.
            if (flags & (IFF_UP|IFF_RUNNING|IFF_LOOPBACK)) == (IFF_UP|IFF_RUNNING) {
                if addr.sa_family == UInt8(AF_INET) || addr.sa_family == UInt8(AF_INET6) {

                    // Convert interface address to a human readable string:
                    var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                    if (getnameinfo(ptr.pointee.ifa_addr, socklen_t(addr.sa_len), &hostname, socklen_t(hostname.count),
                                    nil, socklen_t(0), NI_NUMERICHOST) == 0) {
                        let address = String(cString: hostname)
                        addresses.append(address+"\n")
                    }
                }
            }
        }

        freeifaddrs(ifaddr)
        print(addresses)
        return addresses
    }
}

