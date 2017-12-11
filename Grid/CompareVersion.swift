//
//  CompareVersion.swift
//  Grid
//
//  Created by Bryan Lloyd Anderson on 11/9/15.
//  Copyright © 2015 Bryan Lloyd Anderson. All rights reserved.
//

import Foundation
import UIKit

protocol CompareVersionable {
    func compareVersions(_ version: String?)
    func checkVersion()
}

extension CompareVersionable where Self: UIViewController {
    func compareVersions(_ version: String?) {
        let nsObject: AnyObject? = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as AnyObject?
        
        guard let currentVersion = nsObject as? String else { return }
        guard let uVersion = version else { return }
        if uVersion != currentVersion {
            
            DispatchQueue.main.async(execute: {
                let alert = UIAlertController(title: "Grid Update Available ", message: "To get the latest version (\(uVersion)) click ''Install'' below.", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
                alert.addAction(UIAlertAction(title: "Install", style: .default, handler: { action in
                    switch action.style{
                    case .default:
                        
                        let url = URL(string: "itms-services://?action=download-manifest&url=https://grid.lgcypower.com/apps/grid/manifest.plist")
                        UIApplication.shared.openURL(url!)
                        
                    case .cancel:
                        print("cancel")
                        
                    case .destructive:
                        print("destructive")
                    }
                }))
                self.present(alert, animated: true, completion: nil)
            })
        }
        
        
    }
    
    func getData( _ completionHandler: @escaping ((String?, Error?) -> Void)) -> Void {
        
       let backgroundQueue = DispatchQueue.global(qos: DispatchQoS.QoSClass.background)
        
            backgroundQueue.async {
                
                
       
        
        var urlPath = "https://grid.lgcypower.com/grid_version.json"
        var url = URL(string: urlPath)
        var session = URLSession.shared
        var version: String = ""
        
                let request = URLRequest(url: url!, cachePolicy:
                    NSURLRequest.CachePolicy.reloadIgnoringLocalAndRemoteCacheData,
                    timeoutInterval: 10.0)
                
        let task = session.dataTask(with: request, completionHandler: { data, response, error -> Void in
            
            
            do {
                if let myData = data, let jsonResult = try JSONSerialization.jsonObject(with: myData, options: []) as? NSDictionary {
                    print(jsonResult)
                    
                    
                    if let uVersion = jsonResult["version"] as? String {
                        version = uVersion
                    }
                    return completionHandler(version, nil)
                    
                    
                    
                } else {
                    completionHandler(nil, error)
                    
                    
                }
            } catch {
                print(error)
                
            }
            
            
            
            
        })
        
        task.resume()
                 }
        
    }
    
    func checkVersion() {
        self.getData { (version, error) -> Void in
            if error == nil {
                self.compareVersions(version)
            }
        }
    }

    
}
