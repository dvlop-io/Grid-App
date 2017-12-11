//
//  EventKitExtensions.swift
//  Grid
//
//  Created by Bryan Lloyd Anderson on 1/11/16.
//  Copyright © 2016 Bryan Lloyd Anderson. All rights reserved.
//

import Foundation
import UIKit
import EventKit


func setupEventStore() {
    let eventStore = EKEventStore()
    
    switch EKEventStore.authorizationStatus(for: EKEntityType.event) {
    case .authorized:
        //insert Event
        print("insert event")
        
    case .denied:
        print("access denied")
        
    case .notDetermined:
            print("not determined")
        
        eventStore.requestAccess(to: EKEntityType.event, completion: { (granted, error) -> Void in
            if granted {
                //insert event
                print("insert event now please")
                
            } else {
                print("access denied")
            }
        })
    default:
        print("default")
    }
    
}
