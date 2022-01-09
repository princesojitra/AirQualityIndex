//
//  Constants.swift
//  WiproCodingExcercise
//
//  Created by Prince Sojitra on 09/01/22.
//


import UIKit

let appDelegate = UIApplication.shared.delegate as! AppDelegate
let appName = Bundle.main.infoDictionary!["CFBundleName"] as! String
let appVersion = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String
let deviceId = UIDevice.current.identifierForVendor!.uuidString
let systemVersion = UIDevice.current.systemVersion
var indicator:UIActivityIndicatorView?

func activityIndicator() {
    if #available(iOS 13.0, *) {
        let keyWindow = UIApplication.shared.connectedScenes
            .filter({$0.activationState == .foregroundActive})
            .map({$0 as? UIWindowScene})
            .compactMap({$0})
            .first?.windows
            .filter({$0.isKeyWindow}).first
        
        if(indicator == nil) {
            indicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
            indicator?.style = UIActivityIndicatorView.Style.medium
            indicator?.center =  CGPoint(x: UIScreen.main.bounds.width/2, y: UIScreen.main.bounds.height/2)
            indicator?.backgroundColor = .white
            indicator?.hidesWhenStopped = true
            keyWindow?.addSubview(indicator!)
        }
    }
    else{
        // Fallback on earlier versions
        let keyWindow = UIApplication.shared.keyWindow
        if(indicator == nil) {
            indicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
            indicator?.style = UIActivityIndicatorView.Style.gray
            indicator?.center =  CGPoint(x: UIScreen.main.bounds.width/2, y: UIScreen.main.bounds.height/2)
            indicator?.backgroundColor = .white
            indicator?.hidesWhenStopped = true
            keyWindow?.addSubview(indicator!)
        }
    }
}

